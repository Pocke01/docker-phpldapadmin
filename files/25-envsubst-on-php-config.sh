#! /bin/sh

# before things start up, we need to configure phpLDAPadmin's config/config.php
# using the template in /usr/share/nginx/config.php.template
config_file=${PHP_LDAP_ROOT}/config/config.php

if [ ! -f "$config_file" ]; then
  envsubst < /srv/docker-phpLDAPadmin/config.php.template > "$config_file"
  echo "Wrote phpLDAPadmin config file to: $config_file"
else
  echo "$config_file already exists - skipping"
fi

