#!/bin/sh
set -o errexit
set -o nounset
umask 0002
if [ "${1:-}" = "--help" -o "${1:-}" = "-h" ]
then
    cat <<EOF
    Usage:
        echo $(basename "${0}") FILE > FILE.min
EOF
else
    minify "${@}"
fi

