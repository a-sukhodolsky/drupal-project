#!/usr/bin/env bash
set -e

action="Sync with Prod: Backup"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

rsync -avhyP --append ${PROD_SSH_USER}@${PROD_SSH_HOST}:${PROD_HOST_DIR_BACKUP} .

###

echo "*** Done: ${action}"
