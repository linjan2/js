FROM registry.access.redhat.com/ubi9/nodejs-16:1-71

COPY entrypoint.sh /usr/bin/entrypoint.sh
USER 0:0
RUN \
    chmod ug+x /usr/bin/entrypoint.sh && \
    chown 1001:0 /usr/bin/entrypoint.sh

USER 1001:0
RUN \
    npm install --global minify

CMD ["/usr/bin/entrypoint.sh"]

