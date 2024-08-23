#!/bin/ash
  if [ -z "${1}" ]; then
    set -- "node" \
      /opt/redis-insight/api/dist/src/main
  fi

  exec "$@"