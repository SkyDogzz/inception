# User documentation

## Services provided
- Nginx: TLS terminator and reverse proxy for the WordPress site.
- WordPress: PHP application server for the website.
- MariaDB: database backend for WordPress.
- Adminer: lightweight database UI for MariaDB.
- Redis: object cache backend for WordPress (via redis-cache plugin).
- FTP: vsftpd service on Alpine, mounted on the WordPress volume.
- Backup: scheduled MariaDB dumps and WordPress file archives stored in a dedicated backups volume.

## Start and stop the project
```sh
make up
```

```sh
make down
```

## Access the website and admin panel
- Website: `https://<login>.42.fr` (subject requirement, points to your VM IP)
- WordPress admin: `https://<login>.42.fr/wp-admin`
- Adminer: `https://<login>.42.fr/adminer/`
- Static bonus page (Apache httpd): `https://<login>.42.fr/gateau/`
- FTP (local VM only): host `127.0.0.1`, port `21`, passive ports `30000-30009`
- If your compose maps a non-443 host port, use that host port instead.

## Locate and manage credentials
- Credentials are stored in `.env` at the repository root.
- FTP credentials are `FTP_USER` and `FTP_PASSWORD`.
- Do not commit real secrets; use Docker secrets if required by your evaluation.
- Update values in `.env`, then apply changes with:
```sh
make restart
```

## Check that services are running correctly
- List containers:
```sh
make ps
```
- View logs:
```sh
make logs
```
- Inspect a service interactively (example: WordPress):
```sh
make sh SERVICE=wordpress
```

## Backups
- Schedule and retention are configured in `.env` (`BACKUP_CRON`, `BACKUP_RETENTION_DAYS`).
- Backups are stored under `/home/<login>/data/backups` on the host.

## Data storage locations
- WordPress files and MariaDB data must be stored in Docker named volumes under `/home/<login>/data` on the host.
