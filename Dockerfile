FROM docker/compose:1.9.0
MAINTAINER Fabian Stegemann

ENV DOCKER_MACHINE_VERSION v0.8.2
ENV DOCKER_VERSION 1.12.3

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="docker-deployment-worker" \
      org.label-schema.description="Provides the docker tools, runs `docker-compose -f docker-compose.deploy.yml up` by default." \
      org.label-schema.url="https://github.com/zetaron/docker-deployment-worker" \
      org.label-schema.vcs-url="https://github.com/zetaron/docker-deployment-worker" \
      org.label-schema.version="1.0.0" \
      org.label-schema.docker.cmd="docker run -d -v $SECRET_VOLUME_NAME:/var/cache/secrets:ro -v $DEPLOYMENT_CACHE_VOLUME_NAME:/var/cache/deployment zetaron/docker-deployment-worker:1.0.0"

WORKDIR /var/cache/deployment

RUN apk add --no-cache \
        curl

RUN curl -L "https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION}/docker-machine-$(uname -s)-$(uname -m)" > /usr/bin/docker-machine \
    && chmod +x /usr/bin/docker-machine

RUN mkdir -p /opt/ \
    && cd /opt/ \
    && curl -L "https://get.docker.com/builds/$(uname -s)/$(uname -m)/docker-${DOCKER_VERSION}.tgz" -o /opt/docker-${DOCKER_VERSION}.tgz \
    && tar zxvf docker-${DOCKER_VERSION}.tgz \
    && mv docker/* /usr/bin \
    && rm -rf /opt/

COPY secret-wrapper /usr/bin/secret-wrapper

ENTRYPOINT ["/usr/bin/secret-wrapper", "docker-compose", "-f docker-compose.deploy.yml"]
CMD ["up"]
