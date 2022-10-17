docker-phpldapadmin
---
A docker image for up-to-date [phpLDAPadmin](https://github.com/leenooks/phpLDAPadmin) running on php7.4-fpm behind an
up-to-date nginx server. I didn't want to make this, but I either couldn't find - or didn't trust - an image for this.

This image is based on nginxinc's unprivileged nginx image so that nginx in your container doesn't run as root. It adds
PHP 7.1 FPM as the runtime environment from the standard debian package repository (which I think is better than using
a mode up-to-date PHP but having to use a [PPA repository](https://launchpad.net/~ondrej/+archive/ubuntu/php) to get
it). It then downloads an official release of phpLDAPadmin from GitHub and configures it and nginx both based on
environment variables.

### env vars for nginx
You can take a look at the [nginx config template](./files/default.conf.template) to see which env vars are being used
but here's the list:
| name | default | purpose |
| --- | --- | --- |
| `NGINX_SERVER_NAME` | `_` | the value of nginx's `server_name` in the default server configuration |
| `NGINX_SERVER_PORT` | `8080` | the port to listen on which must be higher than 1024 since we don't run as root |

### env vars for phpLDAPadmin
You can take a look at the [config.php template](./files/config.php.template) to see which env vars are being used but
here's the list:
| name | default | purpose |
| --- | --- | --- |
| `PHP_LDAP_ENCRYPT_SALT` | `pink_fluffy_bunnies` | phpLDAPadmin can encrypt the content of sensitive cookies if you set this
   to a big random string |
| `PHP_LDAP_TIMEZONE` | `America/New_York` | The local timezone to use when phpLDAPadmin gets the current time |
| `PHP_LDAP_SERVER_NAME` | `My LDAP Server` | The display name of your LDAP server |
| `PHP_LDAP_SERVER_HOST` | `ldap` | examples: `ldap.example.com`, `ldaps://ldap.example.com`, `ldapi://%2fusr%local%2fvar%2frun%2fldapi` (Unix socket at /usr/local/var/run/ldap). The default value is chosen so that this image can be used in docker-compose with an ldap server named `ldap` |
| `PHP_LDAP_SERVER_PORT` | `389` | The port on which the LDAP server is listening |
| `PHP_LDAP_BASE_DNS` | `array('')` | A PHP array of base Distinguished Names (DNs) of your LDAP Server. The default value makes phpLDAPadmin auto-detect it |
| `PHP_LDAP_SERVER_TLS` | `true` | Whether or not to connect to your LDAP server with TLS |

### What if I want to configure something that has no env var?
1. Fork this repository into your GitHub account
1. Create a new branch in your fork
1. Update the template files to use env vars in the format `${NGINX_SOMETHING}` or `${PHP_LDAP_SOMETHING}`
1. Update [entrypoint.sh] to set a default value for your env var
1. Update this README.md to add your env var to the tables above
1. Commit your changes and push your branch to GitHub
1. Come back to this repository and create a pull request from your branch in your repo
