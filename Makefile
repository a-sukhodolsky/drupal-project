
# Create local environment files.
$(shell cp -n \.\/\.docker\/docker-compose\.override\.default\.yml \.\/\.docker\/docker-compose\.override\.yml)
$(shell cp -n \.env\.default \.env)

include .env

# Define function to highlight messages.
# @see https://gist.github.com/leesei/136b522eb9bb96ba45bd
cyan = \033[38;5;6m
bold = \033[1m
reset = \033[0m
message = @echo "${cyan}${bold}${1}${reset}"

# Detect whether input device is a TTY, use -T option for "docker exec" otherwise.
docker-compose-no-tty = $(shell bash -c "if [[ ! -t 0 ]]; then echo '-T'; fi")

docker-compose-exec = docker-compose exec ${docker-compose-no-tty} ${1} ${2} ${3}
docker-compose-up = PHP_TAG_OS=${PHP_TAG_OS} PHP_TAG_DEV=${PHP_TAG_DEV} docker-compose up -d ${1}

# Define 3 users with different permissions within the container.
# docker-www-data is applicable only for php container.
docker_user_root = --user=0:0
docker_user_www-data = --user=82:82
docker_user_wodby =
docker_user =

docker-compose-exec-drush = $(call docker-compose-exec,${docker_user_www-data},php,drush --root=/var/www/html/web ${1})

COMPOSER_ROOT ?= /var/www/html
DRUPAL_ROOT ?= /var/www/html/web

OS_TYPE := $(shell ./scripts/misc-detect-os-type.sh)
ifeq (${OS_TYPE},macos)
PHP_TAG_OS = -macos
PHP_TAG_DEV = -dev
endif

container = php
cmd =

ifeq (${container},php)
user = www-data
else
user =
endif

ifeq (${user},root)
docker_user = ${docker_user_root}
else ifeq (${user},www-data)
docker_user = ${docker_user_www-data}
endif

default: init

.PHONY: init
init:
	$(call message,$(PROJECT_NAME): Initialized)

.PHONY: reset-env
reset-env: down
	$(call message,$(PROJECT_NAME): Removing environment files...)
	rm .env .docker/docker-compose.override.yml

.PHONY: reset-data
reset-data: down
	$(call message,$(PROJECT_NAME): Removing data files...)
	sudo rm -rf .docker/${MYSQL_DATA_DIR} .docker/.solr

.PHONY: reset-files
reset-files:
	$(call message,$(PROJECT_NAME): Removing content files...)
	sudo rm -rf files
	git checkout files

.PHONY: reset-all
reset-all: reset-env reset-data reset-files

.PHONY: pull
pull:
	$(call message,$(PROJECT_NAME): Downloading / updating Docker images...)
	docker-compose pull

.PHONY: up-solr
up-solr:
	$(call message,${PROJECT_NAME}: Starting Docker container: Solr...)
	@mkdir -p .docker/.solr
	$(call docker-compose-up,solr)
	@./scripts/init-solr.sh

.PHONY: up-db
up-db:
	$(call message,${PROJECT_NAME}: Starting Docker container: DB...)
	mkdir -p .docker/${MYSQL_DATA_DIR}
	$(call docker-compose-up,mariadb)

.PHONY: up-php
up-php: up-solr up-db
	$(call message,${PROJECT_NAME}: Starting Docker container: PHP...)
	$(call docker-compose-up,php)

.PHONY: up
up: up-solr up-db
	$(call message,${PROJECT_NAME}: Starting Docker containers...)
	$(call message,${PROJECT_NAME}: Environment: ${ENVIRONMENT})
	$(call message,${PROJECT_NAME}: Detected os type: ${OS_TYPE})
	$(call docker-compose-up)

.PHONY: stop
stop:
	$(call message,$(PROJECT_NAME): Stopping Docker containers...)
	docker-compose stop

.PHONY: down
down:
	$(call message,$(PROJECT_NAME): Removing Docker network & containers...)
	docker-compose down -v

.PHONY: restart
restart:
	$(call message,$(PROJECT_NAME): Restarting Docker containers...)
	@$(MAKE) -s down
	@$(MAKE) -s up

.PHONY: exec-sh
exec-sh:
	$(call docker-compose-exec,${docker_user},${container},sh)

.PHONY: exec
exec:
	$(call docker-compose-exec,${docker_user},${container},sh -c "${cmd}")

.PHONY: exec-sh-wodby
exec-sh-wodby:
	$(call docker-compose-exec,${docker_user_wodby},${container},sh)

.PHONY: exec-wodby
exec-wodby:
	$(call docker-compose-exec,${docker_user_wodby},${container},sh -c "${cmd}")

.PHONY: exec-sh-root
exec-sh-root:
	$(call docker-compose-exec,${docker_user_root},${container},sh)

.PHONY: exec-root
exec-root:
	$(call docker-compose-exec,${docker_user_root},${container},sh -c "${cmd}")

.PHONY: drush
drush:
	$(call docker-compose-exec-drush,${cmd})

.PHONY: drush-cr
drush-cr:
	$(call docker-compose-exec-drush,cr)

.PHONY: drush-cr-ext
drush-cr-ext: drush-cr
	$(call docker-compose-exec-drush,php-eval 'node_access_rebuild();')
	./scripts/solr-reindex.sh

docker-compose-exec-composer = $(call docker-compose-exec,${docker_user_wodby},php,composer ${1})

.PHONY: composer
composer:
	$(call docker-compose-exec-composer,${cmd})

.PHONY: composer-install
composer-install:
	$(call docker-compose-exec-composer,install)

.PHONY: composer-install-verbose
composer-install-verbose:
	$(call docker-compose-exec-composer,install -vvv)

.PHONY: composer-update
composer-update:
	$(call docker-compose-exec-composer,update --with-dependencies)

.PHONY: composer-update-verbose
composer-update-verbose:
	$(call docker-compose-exec-composer,update --with-dependencies -vvv)

.PHONY: cp-to
# Use container name instead od container id
#docker cp ${source} $$(docker inspect -f '{{.Name}}' $$(docker-compose ps -q ${container}) | cut -c2-):${target}
cp-to:
	docker cp ${source} $$(docker-compose ps -q ${container}):${target}

.PHONY: files\:owner
# Change ownership of files/config directory.
# Usage:
# - make files:owner www-data
# - write updates
# - make files:owner wodby
files-owner:
	$(eval owner = www-data)
	$(call docker-compose-exec,${docker_user_root},php,chown -R ${owner}: temp)
	$(call docker-compose-exec,${docker_user_root},php,chown -R ${owner}: files)

.PHONY: config-owner
# Usage:
# - make config-owner owner=www-data
# - make drush cmd=config-export
# - make config-owner
# - git pull
config-owner:
	$(eval owner = wodby)
	$(call docker-compose-exec,${docker_user_root},php,chown -R ${owner}: config/sync)

.PHONY: sync
sync:
	./scripts/sync-with-prod.sh

.PHONY: backup
backup:
	@./scripts/local-backup-db.sh
	@./scripts/local-backup-files.sh
