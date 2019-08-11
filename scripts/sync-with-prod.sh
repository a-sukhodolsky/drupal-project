#!/usr/bin/env bash
set -e

action="Sync with Prod"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

./scripts/sync-with-prod-files.sh

./scripts/sync-with-prod-db.sh

###

echo "*** Done: ${action}"
