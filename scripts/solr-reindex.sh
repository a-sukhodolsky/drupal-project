#!/usr/bin/env bash
set -e

action="Reindex Solr indexes"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

make drush cmd="search-api-mark-all"
make drush cmd="search-api-index"

###

echo "*** Done: ${action}"
