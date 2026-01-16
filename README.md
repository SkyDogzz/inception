# Inception

Docker Compose stack for a WordPress site fronted by Nginx with a MariaDB backend.

## Requirements

- Docker Engine + Docker Compose v2 (`docker compose`)
- GNU Make

## Services

- `nginx`: TLS terminator, serves WordPress content on port `4443`.
- `wordpress`: PHP/WordPress container.
- `db`: MariaDB storage for WordPress.

## Ports

- `4443:443` (Nginx HTTPS)

## Volumes

- `wp_data`: WordPress application files (`/var/www/html`).
- `MARIADB_DATA_DIR`: MariaDB data directory (defaults to `./data/mariadb`).

## Configuration

Environment variables are loaded from `.env`.

Required variables (defaults are in `.env`):

- `MARIADB_DATA_DIR`
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `WP_URL`
- `WP_TITLE`
- `WP_ADMIN_USER`
- `WP_ADMIN_PASSWORD`
- `WP_ADMIN_EMAIL`

## Makefile commands

All actions below are available via the Makefile.

### Core lifecycle

- `make up` → Start services in the background (`docker compose up -d`).
- `make down` → Stop and remove containers (`docker compose down`).
- `make restart` → Recreate the stack (down + up -d).
- `make ps` → List running containers for this compose project.
- `make logs` → Stream logs for the stack. Use `ARGS` to pass flags (example: `make logs ARGS="--tail=200 -f"`).
- `make build` → Build images. Use `ARGS` to pass build flags.
- `make pull` → Pull images. Use `ARGS` to pass pull flags.
- `make start` → Start existing stopped containers.
- `make stop` → Stop running containers.
- `make rm` → Remove stopped containers. Use `ARGS` for extra flags.
- `make config` → Print the fully resolved compose configuration.

### Dev utilities

- `make sh` → Open a shell in a service container. Defaults to `SERVICE=app`.
  - Override example: `make sh SERVICE=wordpress`
- `make exec CMD='...'` → Execute a command inside a service container.
  - Example: `make exec SERVICE=wordpress CMD='wp --info'`

### Cleanup

- `make clean` → `down -v --remove-orphans` (removes containers, volumes, and orphans).
- `make nuke` → Removes containers, volumes, and local images for this compose project.

## Make variables

The Makefile exposes a few variables for overrides:

- `SERVICE` → Target service for `make sh` and `make exec` (default: `app`).
- `CMD` → Required command for `make exec`.
- `ARGS` → Extra flags passed to `logs`, `build`, `pull`, and `rm`.

## Quick start

```sh
make up
```

Then open:

- `https://127.0.0.1:4443`

## Notes

- If you change `.env`, restart the stack with `make restart` to apply changes.
- The `make nuke` target is destructive; use it only when you want to wipe local images/volumes for this project.
