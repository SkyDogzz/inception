# User documentation

## Services provided
- Nginx: TLS terminator and reverse proxy for the WordPress site.
- WordPress: PHP application server for the website.
- MariaDB: database backend for WordPress.

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
- If your compose maps a non-443 host port, use that host port instead.

## Locate and manage credentials
- Credentials are stored in `.env` at the repository root.
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

## Data storage locations
- WordPress files and MariaDB data must be stored in Docker named volumes under `/home/<login>/data` on the host.
