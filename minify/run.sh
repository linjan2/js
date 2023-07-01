set -o errexit
set -o nounset

FILE="${1}"
BASENAME="$(basename ${FILE})"
TEMP="$(mktemp -d)"
cp --verbose "${FILE}" "${TEMP}/${BASENAME}" >&2
chmod --recursive g+rwX "${TEMP}"

VOLUME=/opt/app-root/src/workdir
podman run --rm --env "FILE=${VOLUME}/${BASENAME}" --volume "${TEMP}:${VOLUME}:Z,rw" localhost/minify:latest
  # minify "${INPUT}" > "${OUTPUT}"
