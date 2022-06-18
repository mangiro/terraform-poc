.SILENT:

import-envs:
ifneq (,$(wildcard ./.env))
    include .env
    export
else
	echo "Environment config file not exists: .env"
	echo "Copy example config: cp .env.example .env\n"
	exit 1
endif

# Get into the application container
docker-app: import-envs
	docker exec -it $(APP_CONTAINER_NAME) bash
