# ---------------------------------------------
# Docker Compose Utilities Makefile 🐳
# ---------------------------------------------
SHELL := /bin/bash

ENV_FILE ?= .env
DC := docker compose --env-file $(ENV_FILE) -f srcs/docker-compose.yml

SERVICE ?= app

ARGS ?=

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo ""
	@echo "Docker Compose Makefile Commands"
	@echo ""
	@echo "  make up              → Start services (detached)"
	@echo "  make down            → Stop and remove containers"
	@echo "  make restart         → Restart stack"
	@echo "  make ps              → List containers"
	@echo "  make logs            → Follow logs (use ARGS='--tail=200 -f')"
	@echo "  make build           → Build images"
	@echo "  make pull            → Pull images"
	@echo "  make start           → Start existing containers"
	@echo "  make stop            → Stop containers"
	@echo "  make rm              → Remove stopped containers"
	@echo "  make config          → Print resolved compose config"
	@echo ""
	@echo "  make init-data       → Create data folders + chmod 777"
	@echo "  make wipe-data       → ⚠️ Remove /home/tstephan/data/*/*"
	@echo "  make reset           → ⚠️ Nuke + wipe-data + up + logs -f"
	@echo ""
	@echo "  make sh              → Shell into service (SERVICE=...)"
	@echo "  make exec CMD='...'  → Exec command in service (SERVICE=...)"
	@echo ""
	@echo "  make clean           → Down + remove volumes + orphans"
	@echo "  make nuke            → ⚠️ Remove EVERYTHING for this project (images, volumes)"
	@echo ""

# ---------------------------
# Core lifecycle
# ---------------------------
.PHONY: up
up:
	$(DC) up -d

.PHONY: down
down:
	$(DC) down

.PHONY: restart
restart:
	$(DC) down
	$(DC) up -d

.PHONY: ps
ps:
	$(DC) ps

.PHONY: logs
logs:
	$(DC) logs $(ARGS)

.PHONY: build
build:
	./scripts/check-env-ports.sh $(ENV_FILE)
	$(DC) build $(ARGS)

.PHONY: pull
pull:
	$(DC) pull $(ARGS)

.PHONY: start
start:
	$(DC) start

.PHONY: stop
stop:
	$(DC) stop

.PHONY: rm
rm:
	$(DC) rm -f $(ARGS)

.PHONY: config
config:
	$(DC) config

.PHONY: sh
sh:
	$(DC) exec $(SERVICE) sh || $(DC) exec $(SERVICE) bash

.PHONY: exec
exec:
	@if [ -z "$(CMD)" ]; then \
		echo "😳 You must provide CMD, like: make exec SERVICE=app CMD='ls -la'"; \
		exit 1; \
	fi
	$(DC) exec $(SERVICE) $(CMD)

.PHONY: clean
clean:
	$(DC) down -v --remove-orphans

.PHONY: nuke
nuke:
	@echo "⚠️ NUKE MODE: removing containers, volumes, and images for this compose project..."
	$(DC) down -v --remove-orphans --rmi local

# ---------------------------
# Local data setup + full reset 🧹
# ---------------------------
.PHONY: init-data
init-data:
	@sudo mkdir -p /home/tstephan/data/wordpress /home/tstephan/data/mariadb /home/tstephan/data/backups
	@sudo chmod 777 /home/tstephan/data/wordpress /home/tstephan/data/mariadb /home/tstephan/data/backups

.PHONY: wipe-data
wipe-data:
	sudo find /home/tstephan/data -mindepth 1 -delete

.PHONY: logs-follow
logs-follow:
	$(DC) logs -f || true

.PHONY: reset
reset: nuke wipe-data init-data up logs-follow
