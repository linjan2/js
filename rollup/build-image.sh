set -o errexit
set -o nounset

pushd $(dirname $(readlink -f "${0}")) >/dev/null

ctr=$(buildah from registry.access.redhat.com/ubi9/nodejs-16:1-71)

buildah run --user 0 ${ctr} sh -c "
cat > /usr/local/bin/entrypoint.sh;
chmod +x /usr/local/bin/entrypoint.sh
" <<<'#!/bin/sh
set -o errexit
set -o nounset
umask 0002
npm run fix -- "${DIR}/input.js"
npm run build -- --input "${DIR}/input.js" --file "${DIR}/output.min.js"
'

buildah config \
  --entrypoint '' --cmd 'entrypoint.sh' \
  --env NODE_ENV=development \
  --env DIR=. \
  ${ctr}
  # --env HISTFILE=/tmp/.bash_history \
  # --env NPM_CONFIG_CACHE=/tmp/.npm \
  # --env NPM_CONFIG_PREFIX=/tmp \
  # --env NPM_CONFIG_GLOBALCONFIG=${VOLUME_CACHE_DIR}/npmrc \
  # --env NPM_CONFIG_USERCONFIG=${VOLUME_CACHE_DIR}/.npmrc \
  # --env NPM_CONFIG_INIT_MODULE=${VOLUME_CACHE_DIR}/.npm-init.js \

buildah copy ${ctr} src/package.json ./package.json
buildah copy ${ctr} src/rollup.config.js ./rollup.config.js
buildah copy ${ctr} src/.eslintrc.json ./.eslintrc.json
buildah copy ${ctr} src/.babelrc.json ./.babelrc.json

buildah run \
  ${ctr} \
  sh -c 'set -o errexit
umask 0002
npm install --global rollup
npm install --global eslint
npm install --save-dev @rollup/plugin-node-resolve
npm install --save-dev @rollup/plugin-commonjs
npm install --save-dev @rollup/plugin-terser
npm install --save-dev @rollup/plugin-babel
npm install --save-dev @babel/preset-env
npm install --save-dev @babel/core
'

buildah commit ${ctr} rollup:latest

buildah rm ${ctr}
