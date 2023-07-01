set -o errexit
set -o nounset

# pushd $(dirname $(readlink -f "${0}")) >/dev/null

TEMP="$(mktemp -d)"
cat > "${TEMP}/input.js"
chmod --recursive g+rwX "${TEMP}"

VOLUME=/opt/app-root/src/workdir
podman run --rm --env "DIR=${VOLUME}" --volume "${TEMP}:${VOLUME}:Z,rw" localhost/rollup:latest >&2

cat ${TEMP}/output.min.js
