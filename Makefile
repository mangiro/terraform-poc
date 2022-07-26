# App configs
APP_CMD ?= python
APP_ARGS ?= --bind 0.0.0.0:8000 --workers 1

# Test configs
TEST_CMD ?= pytest
TEST_ARGS ?= -p no:cacheprovider

# Deploy configs
ENV ?= local
PROJECT_FOLDER ?= $(shell pwd)
PACKER_USER ?= ec2-user
PACKER_KEY ?= testec2

.SILENT:
.PHONY: web test clean deploy

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

# Get into the infrastructure container
docker-infra: import-envs
	docker exec -it $(INFRA_CONTAINER_NAME) bash

# App commands:
web: inside-app-container
	$(APP_CMD) -m gunicorn.app.wsgiapp src.terraform_poc.app $(APP_ARGS)

test: inside-app-container
	$(TEST_CMD) $(TEST_ARGS)

# Infra commands:
deploy: inside-infra-container clean
	set +x
	zip -r app.zip *
	cd $(PROJECT_FOLDER)/deployment/; \
		./deploy.sh build-ami; \
		./deploy.sh deploy-ami
	echo "AMI successfully builded and deployed at $(ENV) stage."

clean: inside-infra-container
	cd $(PROJECT_FOLDER)/deployment/; ./deploy.sh clean

# Util
inside-app-container: inside-docker
ifneq ($(CURRENT_CONTAINER), APP)
	echo "This command needs to be run inside the '$(APP_CONTAINER_NAME)' container\n"
	exit 1
endif

inside-infra-container: inside-docker
ifneq ($(CURRENT_CONTAINER), INFRA)
	echo "This command needs to be run inside the '$(INFRA_CONTAINER_NAME)' container\n"
	exit 1
endif

inside-docker:
ifeq (,$(wildcard /.dockerenv))
	echo "This command needs to be run inside a docker container"
	echo "Execute: 'make docker-app' or 'make docker-infra' first\n"
	exit 1
endif
