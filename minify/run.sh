set -o errexit
set -o nounset
: $1

FILE="${1}"
BASENAME="$(basename ${FILE})"
TEMP="$(mktemp -d)"
cp --verbose "${FILE}" "${TEMP}/${BASENAME}" >&2
chmod --recursive g+rwX "${TEMP}"

VOLUME=/opt/app-root/src/workdir
podman run --rm --volume "${TEMP}:${VOLUME}:Z,rw" localhost/minify:latest "${VOLUME}/${BASENAME}"
  # minify "${INPUT}" > "${OUTPUT}"
