#!/usr/bin/env bash
set -e

action="Restore database from dump"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

dump=$1

if [[ -z ${dump} ]]; then
    dump=${HOST_DIR_BACKUP}/latest.sql.gz
fi

echo "* Dump file: ${dump}"

echo "* Drop all tables in current database..."
make drush cmd="sql-drop -y"

echo "* Import database dump..."
make exec cmd="zcat ${dump} | drush sql-cli"

###

echo "*** Done: ${action}"
