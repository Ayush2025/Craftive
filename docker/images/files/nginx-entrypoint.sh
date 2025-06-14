#!/usr/bin/env bash

#########################################
## Air Gapped config
#########################################

if [[ $CRAFTIVE_FLAGS == *"enable-air-gapped-conf"* ]]; then
    export INCLUDE_PROXIES=""
    export CRAFTIVE_FLAGS="$CRAFTIVE_FLAGS disable-google-fonts-provider disable-dashboard-templates-section"
else
    export INCLUDE_PROXIES="include /etc/nginx/nginx-proxies.conf;"
fi

#########################################
## App Frontend config
#########################################

update_flags() {
  if [ -n "$CRAFTIVE_FLAGS" ]; then
    sed -i \
      -e "s|^//var craftiveFlags = .*;|var craftiveFlags = \"$CRAFTIVE_FLAGS\";|g" \
      "$1"
  fi
}

update_flags /var/www/app/js/config.js



#########################################
## Nginx Config
#########################################

export CRAFTIVE_BACKEND_URI=${CRAFTIVE_BACKEND_URI:-http://craftive-backend:6060}
export CRAFTIVE_EXPORTER_URI=${CRAFTIVE_EXPORTER_URI:-http://craftive-exporter:6061}
CRAFTIVE_DEFAULT_INTERNAL_RESOLVER="$(awk 'BEGIN{ORS=" "} $1=="nameserver" { sub(/%.*$/,"",$2); print ($2 ~ ":")? "["$2"]": $2}' /etc/resolv.conf)"
export CRAFTIVE_INTERNAL_RESOLVER=${CRAFTIVE_INTERNAL_RESOLVER:-$CRAFTIVE_DEFAULT_INTERNAL_RESOLVER}
export CRAFTIVE_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE=${CRAFTIVE_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE:-367001600} # Default to 350MiB

envsubst "\$CRAFTIVE_BACKEND_URI,\$CRAFTIVE_EXPORTER_URI,\$CRAFTIVE_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE,\$INCLUDE_PROXIES" \
         < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

envsubst "\$CRAFTIVE_INTERNAL_RESOLVER" \
         < /etc/nginx/overrides.d/resolvers.conf.template > /etc/nginx/overrides.d/resolvers.conf

exec "$@";
