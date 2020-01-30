#!/bin/bash
set -e

if [ -z "$SERVER_URL" ]; then
  echo >&2 'SERVER_URL not set'
  exit 1
fi

if [ -z "$LOCATION" ]; then
  echo >&2 'LOCATION not set'
  exit 1
fi

if [ -z "$EXTRA_ARGS" ]; then
  EXTRA_ARGS=""
fi

if [ -n "$NAME" ]; then
  EXTRA_ARGS="$EXTRA_ARGS --name $NAME"
fi

if [ -n "$KEY" ]; then
  EXTRA_ARGS="$EXTRA_ARGS --key $KEY"
fi

if [ -n "$SHAPER" ]; then
  EXTRA_ARGS="$EXTRA_ARGS --shaper $SHAPER"
fi

service apache2 start
service php7.2-fpm start
a2enmod proxy_fcgi setenvif
a2enconf php7.2-fpm
service apache2 restart

# exec replaces the shell process by the python process and is required to
# propagate signals (i.e. SIGTERM)
exec python /wptagent/wptagent.py --server "${SERVER_URL}" --location "${LOCATION}" ${EXTRA_ARGS} --xvfb --dockerized
