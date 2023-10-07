set -o errexit
set -o nounset

pushd $(dirname $(readlink -f "${0}")) >/dev/null

ctr=$(buildah from registry.access.redhat.com/ubi9/nodejs-18:1)

buildah run --user 0 ${ctr} sh -c "
cat > /usr/local/bin/entrypoint.sh;
chmod +x /usr/local/bin/entrypoint.sh
" <<<'#!/bin/bash
set -o errexit
set -o nounset
umask 0002
shopt -s extglob
shopt -s dotglob

cp -r ${DIR}/!(package.json) ./

if [ -r "${DIR}/package.json" ]
then
  mv package.json overrides.json
  jq --slurp ".[0] * .[1]" "${DIR}/package.json" overrides.json > package.json
  rm overrides.json
  npm install
fi

npm run fix -- input.js
npm run build -- --input input.js --file output.min.js
mv output.min.js ${DIR}/
'
# Ignore error
# mv: setting attribute 'security.selinux' for 'security.selinux': Permission denied

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

buildah copy --chown 0:0 --chmod 0660 ${ctr} src/package.json package.json
buildah copy --chown 0:0 --chmod 0660 ${ctr} src/rollup.config.js rollup.config.js
buildah copy --chown 0:0 --chmod 0660 ${ctr} src/.eslintrc.json .eslintrc.json
buildah copy --chown 0:0 --chmod 0660 ${ctr} src/.babelrc.json .babelrc.json

buildah run --user 0 ${ctr} dnf install jq -y
buildah run ${ctr} \
  sh -c 'set -o errexit
umask 0002
npm install --global rollup
npm install --global eslint
npm install
'
# npm install --global npm

buildah commit ${ctr} rollup:latest

buildah rm ${ctr}
