#!/usr/bin/env bash
set -e

action="Sync with Prod: Database"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

echo "* Create dump..."
ssh -p ${PROD_SSH_PORT} ${PROD_SSH_USER}@${PROD_SSH_HOST} "${PROD_HOST_DIR_ROOT}/scripts/local-backup-db.sh latest.sql"

echo "* Download dump..."
rsync -vczh --progress -e "ssh -p ${PROD_SSH_PORT}" ${PROD_SSH_USER}@${PROD_SSH_HOST}:${PROD_HOST_DIR_BACKUP}/latest.sql.gz ${HOST_DIR_BACKUP}/

./scripts/local-restore-db.sh

###

echo "*** Done: ${action}"
