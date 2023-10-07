set -o errexit
set -o nounset

TEMP="$(mktemp -d)"

if [ ${#} -eq 0 ]
then
  cat > "${TEMP}/input.js"
else
  cp "${@:1:1}" "${TEMP}/input.js"
  cp --no-clobber "${@:2}" "${TEMP}/"
fi

chmod --recursive g+rwX "${TEMP}"

VOLUME=/opt/app-root/src/workdir
podman run --rm --env "DIR=${VOLUME}" --volume "${TEMP}:${VOLUME}:Z,rw" localhost/rollup:latest >&2

cat ${TEMP}/output.min.js
