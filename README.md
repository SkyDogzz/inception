*This project has been created as part of the 42 curriculum by skydogzz.*

# Inception

## Description
This project sets up a small Docker-based infrastructure for a WordPress site served by Nginx with a MariaDB backend, plus Redis object caching, an FTP container (vsftpd on Alpine) mounted on WordPress data, Adminer for database access, a static Apache page exposed on a `gateau` subdomain, and a backup service that periodically dumps MariaDB and archives WordPress files. The stack is built with Docker Compose and uses custom Dockerfiles for each service, following the Inception subject rules. It relies on `srcs/docker-compose.yml` for service definitions, `srcs/requirements/*/Dockerfile` for image builds, `srcs/.env` for runtime configuration, and the `Makefile` for common lifecycle commands. Main design choices include a single TLS-terminating Nginx entrypoint, isolated services on a Docker network, and persistent data stored in Docker named volumes. Comparisons: Virtual Machines vs Docker (full OS emulation vs shared-kernel containers), Secrets vs Environment Variables (more secure mounted files vs convenient but visible env vars), Docker Network vs Host Network (isolated DNS-based service discovery vs reduced isolation and port conflicts), Docker Volumes vs Bind Mounts (portable managed storage vs host-path dependent mappings).

## Instructions

### Prerequisites
- Docker Engine + Docker Compose v2 (`docker compose`)
- GNU Make

### Build and run
```sh
make up
```

### Stop and remove
```sh
make down
```

### Useful commands
- `make build`
- `make logs`
- `make ps`
- `make restart`

### Access
- Website: `https://tstephan.42.fr` (subject requirement, mapped to your VM IP)
- Static bonus page: `https://gateau.tstephan.42.fr/`
- If your local compose maps a non-443 host port, use that host port instead.

## Project details and design choices

### Subject compliance notes
- Only TLSv1.2 or TLSv1.3 is allowed, and Nginx is the single entrypoint on port 443.
- Images must be built locally from Alpine or Debian (no pulling service images, no `latest` tag).
- Sensitive values must come from environment variables in `.env`; secrets are recommended for credentials.
- Two WordPress users are required; the admin username must not contain `admin` or `administrator`.
- WordPress and MariaDB must use Docker named volumes stored under `/home/tstephan/data`.
- Services must be connected via a Docker network and configured to restart on crash.

### Comparisons
- Virtual Machines vs Docker: VMs emulate full hardware and require separate guest OSes, while Docker shares the host kernel and isolates processes with cgroups/namespaces, making it lighter and faster to start.
- Secrets vs Environment Variables: environment variables are convenient but visible in process metadata; Docker secrets are stored and mounted more securely and should be used for sensitive data.
- Docker Network vs Host Network: Docker networks provide isolated service-to-service communication with DNS-based service discovery, while host networking removes isolation and can cause port conflicts.
- Docker Volumes vs Bind Mounts: volumes are managed by Docker and are portable across hosts, while bind mounts directly map host paths and are more dependent on host layout and permissions.

## Resources
- Docker documentation: https://docs.docker.com/
- Docker Compose reference: https://docs.docker.com/compose/
- Nginx documentation: https://nginx.org/en/docs/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WordPress documentation: https://wordpress.org/support/
- AI usage: used only for README drafting and wording (Description, Instructions, and Resources sections) and to sanity-check the Inception subject requirements; no code or configuration was generated. All content was reviewed and adapted to this repository.
