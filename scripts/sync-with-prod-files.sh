#!/usr/bin/env bash
set -e

action="Sync with Prod: Files"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

rsync -avczh --delete --progress ${PROD_SSH_USER}@${PROD_SSH_HOST}:${PROD_HOST_DIR_FILES} .

###

echo "*** Done: ${action}"
