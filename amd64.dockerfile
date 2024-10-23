# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM 11notes/node:stable as build
  ENV BUILD_VERSION=2.58
  ENV BUILD_ROOT=/RedisInsight
  ENV BUILD_RELEASE=/opt/redis-insight

  USER root

  RUN set -ex; \
    apk add --no-cache \
      python3 \
      make \
      g++ \
      yarn \
      npm \
      git; \
    npm install -g corepack; \
    corepack enable; \
    mkdir -p ${BUILD_RELEASE}; \
    git clone https://github.com/RedisInsight/RedisInsight.git -b ${BUILD_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    mv ./tsconfig.json ${BUILD_RELEASE}; \
    mv ./package.json ${BUILD_RELEASE}; \
    mv ./yarn.lock ${BUILD_RELEASE}; \
    mv ./configs ${BUILD_RELEASE}; \
    mv ./scripts ${BUILD_RELEASE}; \
    mv ./redisinsight ${BUILD_RELEASE}; \
    cd ${BUILD_RELEASE}; \
    yes " " | SKIP_POSTINSTALL=1 yarn install || echo "catch yarn exit code";

  RUN set -ex; \
    cd ${BUILD_RELEASE}; \
    yarn --cwd ./redisinsight/api install;

  RUN set -ex; \
    cd ${BUILD_RELEASE}; \
    yarn build:ui;

  RUN set -ex; \
    cd ${BUILD_RELEASE}; \
    npm install @nestjs/common --legacy-peer-deps; \
    npm install @nestjs/core --legacy-peer-deps; \
    yarn build:statics;

  RUN set -ex; \
    cd ${BUILD_RELEASE}; \
    yarn build:api;

  RUN set -ex; \
    cd ${BUILD_RELEASE}; \
    yarn --cwd ./redisinsight/api install --production; \
    cp -R ./redisinsight/api/.yarnclean.prod ./redisinsight/api/.yarnclean;

  RUN set -ex; \
    cd ${BUILD_RELEASE}; \
    yarn --cwd ./redisinsight/api autoclean --force;


# :: Header
  FROM 11notes/node:stable
  COPY --from=build /opt/redis-insight/redisinsight/api/dist /opt/redis-insight/api/dist
  COPY --from=build /opt/redis-insight/redisinsight/api/node_modules /opt/redis-insight/api/node_modules
  COPY --from=build /opt/redis-insight/redisinsight/ui/dist /opt/redis-insight/ui/dist
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  ENV APP_ROOT=/redis-insight
  ENV NODE_ENV=production
  ENV RI_SERVE_STATICS=false
  ENV RI_APP_FOLDER_ABSOLUTE_PATH=/redis-insight/var

# :: Run
  USER root

  # :: install application
    RUN set -ex; \
      apk --no-cache --update upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/var
      

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin;

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        /opt/redis-insight \
        ${APP_ROOT};

# :: Volumes
	VOLUME ["${APP_ROOT}/var"]

# :: Ports
  EXPOSE 5540

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
	USER docker
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]