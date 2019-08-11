#!/usr/bin/env bash
set -e

action="Backup files"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

filename=${PROJECT_NAME}_${ENVIRONMENT}_$(date +"%F_%H-%M-%S_%z").files.tar

tar -cf ${HOST_DIR_BACKUP}/${filename} ${HOST_DIR_FILES}
echo "* Created backup file: ${filename}"

###

echo "*** Done: ${action}"
