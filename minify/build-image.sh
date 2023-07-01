set -o errexit
set -o nounset

ctr=$(buildah from registry.access.redhat.com/ubi9/nodejs-16:1-71)

buildah run --user 0 ${ctr} sh -c "
cat > /usr/local/bin/entrypoint.sh;
chmod +x /usr/local/bin/entrypoint.sh
" <<<'#!/bin/sh
set -o errexit
set -o nounset
umask 0002
minify "${FILE}"
'

buildah config \
  --entrypoint '' --cmd 'entrypoint.sh' \
  --env NODE_ENV=development \
  --env FILE=index.html \
  ${ctr}
  # --env NPM_CONFIG_GLOBALCONFIG=${VOLUME_CACHE_DIR}/npmrc \
  # --env NPM_CONFIG_USERCONFIG=${VOLUME_CACHE_DIR}/.npmrc \
  # --env NPM_CONFIG_PREFIX=${VOLUME_CACHE_DIR} \
  # --env NPM_CONFIG_CACHE=${VOLUME_CACHE_DIR}/.npm \
  # --env NPM_CONFIG_INIT_MODULE=${VOLUME_CACHE_DIR}/.npm-init.js \

buildah run ${ctr} sh -c '
set -o errexit
umask 0002
npm install --global minify
'

buildah commit ${ctr} minify:latest

buildah rm ${ctr}
