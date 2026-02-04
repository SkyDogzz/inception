# Developer documentation

## Environment setup from scratch

### Prerequisites
- Docker Engine + Docker Compose v2 (`docker compose`)
- GNU Make

### Configuration files
- `.env`: environment variables for the stack (database credentials, site URL, admin user).
- `docker-compose.yml`: service topology and volumes.
- `config/`: service Dockerfiles and configuration.

### Secrets
- This repository stores credentials in `.env` for local development.
- For evaluation, replace sensitive values with Docker secrets where required by the subject.

### Subject-specific configuration
- Set the domain to `"<login>.42.fr"` and point it to your VM IP.
- Create two WordPress users; the admin username must not contain `admin` or `administrator`.
- Ensure TLS is restricted to v1.2/v1.3 and only port 443 is exposed.
- Ensure Docker named volumes are stored under `/home/<login>/data` on the host.

## Build and launch

### Using the Makefile
```sh
make build
make up
```

### Using Docker Compose directly
```sh
docker compose build
docker compose up -d
```

## Managing containers and volumes

### Common operations
- `make ps`
- `make logs`
- `make restart`
- `make down`

### Inspect volumes
```sh
docker volume ls
```

### Remove containers and volumes (destructive)
```sh
make clean
```

## Data persistence and storage locations
- MariaDB and WordPress data must live in Docker named volumes located under `/home/<login>/data` on the host.
- Configure volume driver options in `docker-compose.yml` if you need to bind named volumes to that path.
- Backup archives are stored in the `backup_data` volume under `/home/<login>/data/backups`.

## Backup service
- Configure scheduling with `BACKUP_CRON` and retention with `BACKUP_RETENTION_DAYS` in `.env`.
- You can trigger a one-off backup by running:
```sh
make exec SERVICE=backup CMD="/usr/local/bin/backup.sh"
```
