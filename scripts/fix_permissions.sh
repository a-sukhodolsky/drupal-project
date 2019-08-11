#!/usr/bin/env bash
set -e

# Usage:
# $ sudo ./fix_permissions.sh
# $ sudo ./fix_permissions.sh my_username

action="Fix file-system permissions"
echo "*** Action: ${action}..."

cd $(cd $(dirname "$0") && git rev-parse --show-toplevel)
source ./.env

###

echo '* Setting directories permissions to 777...'
find ./files -type d -print0 | xargs -0 chmod 777
find ./config -type d -print0 | xargs -0 chmod 777
find ./backup -type d -print0 | xargs -0 chmod 777

echo '* Setting files permissions to 666...'
find ./files -type f -print0 | xargs -0 chmod 666
find ./config -type f -print0 | xargs -0 chmod 666
find ./backup -type f -print0 | xargs -0 chmod 666

# Set files owner and special permissions for production environment
if [[ ${ENVIRONMENT} = "prod" ]]; then
  echo "* Setting special permissions for production environment..."
  chmod 444 ./web/sites/default/settings.php
  chmod 444 ./web/sites/default/settings.local.php
  chmod 444 ./web/sites/default/services.yml
  chmod 555 ./web/sites/default
  chmod 444 ./files/private/.htaccess
  chmod 444 ./files/public/.htaccess
fi

###

echo "*** Done: ${action}"
