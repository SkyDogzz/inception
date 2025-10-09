all: up logs

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

re: down all logs
