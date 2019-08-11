#!/usr/bin/env bash
set -e

action="Init Solr"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

make exec container=solr cmd="make check-ready wait_seconds=5 max_try=20 -f /usr/local/bin/actions.mk"

if ! make exec container=solr cmd="make ping core=${SOLR_CORE} -f /usr/local/bin/actions.mk"; then
  make exec container=solr cmd="make create core=${SOLR_CORE} -f /usr/local/bin/actions.mk"
fi

###

echo "*** Done: ${action}"
