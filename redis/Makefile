up:
	docker-compose --env-file redis.env up -d

down:
	docker-compose --env-file redis.env down

gen-pass:
	openssl rand -base64 32 | tr -d "=+/" | cut -c1-25