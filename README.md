![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Redis Insight
![size](https://img.shields.io/docker/image-size/11notes/redis-insight/2.58?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/redis-insight/2.58?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/redis-insight?color=2b75d6)

**Redis Insight on the stable node branch based on Alpine*

# SYNOPSIS
What can I do with this? Manage all your Redis nodes directly via a web interface.

# VOLUMES
* **/redis-insight/var** - Directory of configuratin files and settings

# COMPOSE
```yaml
services:
  redis:
    image: "11notes/redis:7.4.0"
    container_name: "redis"
    environment:
      DEBUG: true
      REDIS_PASSWORD: GreenHorsesRunLikeCheese
      TZ: Europe/Zurich
    command:
      - SET mykey1 myvalue1
      - SET mykey2 myvalue2
    volumes:
      - "redis-etc:/redis/etc"
      - "redis-var:/redis/var"
    networks:
      - "backend"
    restart: always
  redis-insight:
    image: "11notes/redis-insight:2.54"
    container_name: "redis-insight"
    environment:
      TZ: Europe/Zurich
    ports:
      - "5540:5540/tcp"
    volumes:
      - "redis-insight-var:/redis-insight/var"
    networks:
      - "backend"
      - "frontend"
    restart: always
volumes:
  redis-etc:
  redis-var:
  redis-insight-var:
networks:
  backend:
    internal: true
  frontend:
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /redis-insight | home directory of user docker |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# PARENT IMAGE
* [11notes/node:stable](https://hub.docker.com/r/11notes/node)

# SOURCE
* [11notes/docker-redis-insight](https://github.com/11notes/docker-redis-insight)

# BUILT WITH
* [redisinsight](https://github.com/RedisInsight/RedisInsight)
* [alpine](https://alpinelinux.org)

# TIPS
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes. You can find all my repositories on [github](https://github.com/11notes).
    