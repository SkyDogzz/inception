#!/usr/bin/env python3
import os
import shlex
import subprocess
import sys
import time
from pathlib import Path


REQUIRED_VARS = [
    "MYSQL_DATABASE",
    "MYSQL_USER",
    "MYSQL_PASSWORD",
    "WP_URL",
    "WP_TITLE",
    "WP_ADMIN_USER",
    "WP_ADMIN_PASSWORD",
    "WP_ADMIN_EMAIL",
]


def find_env(start: Path) -> Path:
    cur = start.resolve()
    while True:
        candidate = cur / ".env"
        if candidate.exists():
            return candidate
        if cur.parent == cur:
            raise FileNotFoundError("Could not find .env in parent directories.")
        cur = cur.parent


def load_env(env_path: Path) -> dict:
    data = {}
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        data[key] = value
    return data


def run(cmd, cwd: Path) -> None:
    subprocess.run(cmd, cwd=str(cwd), check=True)


def docker_compose_exec(cwd: Path, service: str, cmd: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["docker", "compose", "exec", "-T", service, "sh", "-c", cmd],
        cwd=str(cwd),
        check=True,
    )


def wp_cmd(args) -> str:
    base = ["wp", "--path=/var/www/html", "--allow-root"]
    parts = base + args
    return " ".join(shlex.quote(p) for p in parts)


def ensure_wp_cli(cwd: Path) -> None:
    cmd = (
        "command -v wp >/dev/null 2>&1 || "
        "(curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar "
        "-o /usr/local/bin/wp && chmod +x /usr/local/bin/wp)"
    )
    docker_compose_exec(cwd, "wordpress", cmd)


def ensure_wp_config(cwd: Path, env: dict) -> None:
    args = [
        "config",
        "create",
        f"--dbname={env['MYSQL_DATABASE']}",
        f"--dbuser={env['MYSQL_USER']}",
        f"--dbpass={env['MYSQL_PASSWORD']}",
        "--dbhost=db",
        "--skip-check",
    ]
    cmd = (
        "if [ ! -f /var/www/html/wp-config.php ]; then "
        + wp_cmd(args)
        + "; fi"
    )
    docker_compose_exec(cwd, "wordpress", cmd)


def wait_for_db(cwd: Path, retries: int = 30, delay_s: float = 2.0) -> None:
    check = wp_cmd(["db", "check"])
    for _ in range(retries):
        try:
            docker_compose_exec(cwd, "wordpress", check)
            return
        except subprocess.CalledProcessError:
            time.sleep(delay_s)
    raise RuntimeError("Database did not become ready in time.")


def install_wordpress(cwd: Path, env: dict) -> None:
    is_installed = wp_cmd(["core", "is-installed"])
    try:
        docker_compose_exec(cwd, "wordpress", is_installed)
        return
    except subprocess.CalledProcessError:
        pass

    args = [
        "core",
        "install",
        f"--url={env['WP_URL']}",
        f"--title={env['WP_TITLE']}",
        f"--admin_user={env['WP_ADMIN_USER']}",
        f"--admin_password={env['WP_ADMIN_PASSWORD']}",
        f"--admin_email={env['WP_ADMIN_EMAIL']}",
        "--skip-email",
    ]
    docker_compose_exec(cwd, "wordpress", wp_cmd(args))


def main() -> int:
    try:
        env_path = find_env(Path(__file__).parent)
    except FileNotFoundError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    env = load_env(env_path)
    missing = [k for k in REQUIRED_VARS if k not in env or not env[k]]
    if missing:
        print(
            "Missing required variables in .env: " + ", ".join(missing),
            file=sys.stderr,
        )
        return 1

    project_root = env_path.parent

    run(["docker", "compose", "up", "-d"], cwd=project_root)
    ensure_wp_cli(project_root)
    ensure_wp_config(project_root, env)
    wait_for_db(project_root)
    install_wordpress(project_root, env)
    print("WordPress setup complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
