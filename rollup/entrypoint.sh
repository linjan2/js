#!/bin/bash
set -o errexit
set -o nounset

umask 0002

shopt -s dotglob

WORKDIR="${PWD}"
cd /app/src

if [ -r "${WORKDIR}/package.json" ]
then
  # merge package.json files
  cp "${WORKDIR}/package.json" overrides.json
  jq --slurp ".[0] * .[1]" package.json overrides.json > package2.json
  mv package2.json package.json
  rm overrides.json
  # install any additional dependencies
  npm install
fi

cp --no-clobber "${WORKDIR}"/* ./

npm run fix -- input.js
npm run build -- --input input.js --file output.min.js

cat output.min.js

