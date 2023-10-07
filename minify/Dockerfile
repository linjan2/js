FROM registry.access.redhat.com/ubi9/nodejs-16:1-71

WORKDIR /app

RUN \
    npm install --global minify

COPY --chown=1001:0 entrypoint.sh /usr/bin/entrypoint.sh
COPY --chown=1001:0 .minify.json /app/

RUN \
    chmod ug+x /usr/bin/entrypoint.sh

USER 1001:0

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

