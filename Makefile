# ---------------------------------------------
# Docker Compose Utilities Makefile 🖤🐳
# ---------------------------------------------

SHELL := /bin/bash

# Compose command (modern Docker)
DC := docker compose -f srcs/docker-compose.yml

# Project (optional; helps when you run multiple stacks)
# PROJ := myproject
# DC := docker compose -p $(PROJ)

# Compose files (optional; add more with -f)
# FILES := -f docker-compose.yml -f docker-compose.override.yml
# DC := docker compose $(FILES)

# Service name for "make sh" / "make exec" (override: make sh SERVICE=api)
SERVICE ?= app

# Extra args passthrough (override: make logs ARGS="--tail=200 -f")
ARGS ?=

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo ""
	@echo "🦇 Docker Compose Makefile Commands 🖤"
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
# Core lifecycle 🖤
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

# ---------------------------
# Handy dev tools 😳🖤
# ---------------------------
.PHONY: sh
sh:
	$(DC) exec $(SERVICE) sh || $(DC) exec $(SERVICE) bash

.PHONY: exec
exec:
	@if [ -z "$(CMD)" ]; then \
		echo "😳🖤 You must provide CMD, like: make exec SERVICE=app CMD='ls -la'"; \
		exit 1; \
	fi
	$(DC) exec $(SERVICE) $(CMD)

# ---------------------------
# Cleanup rituals 🕯️
# ---------------------------
.PHONY: clean
clean:
	$(DC) down -v --remove-orphans

.PHONY: nuke
nuke:
	@echo "⚠️🖤 NUKE MODE: removing containers, volumes, and images for this compose project..."
	$(DC) down -v --remove-orphans --rmi local

# ---------------------------
# Local data setup + full reset 🧹
# ---------------------------
.PHONY: init-data
init-data:
	@mkdir -p /home/tstephan/data/wordpress /home/tstephan/data/mariadb /home/tstephan/data/backups
	@chmod 777 /home/tstephan/data/wordpress /home/tstephan/data/mariadb /home/tstephan/data/backups

.PHONY: wipe-data
wipe-data:
	sudo rm -rf /home/tstephan/data/*/*

.PHONY: logs-follow
logs-follow:
	$(DC) logs -f || true

.PHONY: reset
reset: nuke wipe-data up logs-follow
