#!/usr/bin/env bash
set -e

action="Backup database"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

filename=${1}
if [[ -z ${filename} ]]; then
  filename=${PROJECT_NAME}_${ENVIRONMENT}_$(date +"%F_%H-%M-%S_%z").sql
fi

# @todo Get cache tables automatically
make drush cmd="sql-dump --result-file=\"${CONTAINER_DIR_BACKUP}/${filename}\" --gzip --ordered-dump --structure-tables-list=cache_bootstrap,cache_config,cache_container,cache_data,cache_default,cache_discovery,cache_discovery_migration,cache_dynamic_page_cache,cache_entity,cache_menu,cache_migrate,cache_page,cache_render,cache_toolbar"

###

echo "*** Done: ${action}"
