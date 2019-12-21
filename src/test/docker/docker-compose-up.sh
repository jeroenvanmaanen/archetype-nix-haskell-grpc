#!/bin/bash

set -e

SED_EXT=-r
case $(uname) in
Darwin*)
        SED_EXT=-E
esac
export SED_EXT

DOCKER="$(cd "$(dirname "$0")" ; pwd)"
TEST_DIR="$(dirname "${DOCKER}")"
SRC_DIR="$(dirname "${TEST_DIR}")"
PROJECT="$(dirname "${SRC_DIR}")"
FOO="${PROJECT}"
DOCKER_REPOSITORY='jeroenvm'

: ${SILENT:=true}
. "${SRC_DIR}/bin/verbose.sh"

: ${EXTRA_VOLUMES:=}
source "${DOCKER}/etc/settings-local.sh"

VOLUMES=''
if [[ -n "${EXTRA_VOLUMES}" ]]
then
    VOLUMES="
    volumes:${EXTRA_VOLUMES}"
fi

FOO_SUFFIX=''
FOO_VOLUMES=' No volumes'
if [[ ".$1" = '.--dev' ]]
then
    shift
    FOO_SUFFIX='-dev'
    FOO_VOLUMES=" Mount local volume for development
    volumes:
    -
      type: bind
      source: ${FOO}
      target: ${FOO}
    working_dir: ${FOO}"
fi

BASE="${DOCKER}/docker-compose"
TEMPLATE="${BASE}-template.yml"
TARGET="${BASE}.yml"
VARIABLES="$(tr '$\012' '\012$' < "${TEMPLATE}" | sed -e '/^[{][A-Za-z_][A-Za-z0-9_]*[}]/!d' -e 's/^[{]//' -e 's/[}].*//')"

function re-protect() {
    sed "${SED_EXT}" -e 's/([[]|[]]|[|*?^$()/])/\\\1/g' -e 's/$/\\/g' -e '$s/\\$//'
}

function substitute() {
    local VARIABLE="$1"
    local VALUE="$(eval "echo \"\${${VARIABLE}}\"" | re-protect)"
    log "VALUE=[${VALUE}]"
    if [[ -n "$(eval "echo \"\${${VARIABLE}+true}\"")" ]]
    then
        sed "${SED_EXT}" -e "s/[\$][{]${VARIABLE}[}]/${VALUE}/g" "${TARGET}" > "${TARGET}~"
        mv "${TARGET}~" "${TARGET}"
    fi
}

cp "${TEMPLATE}" "${TARGET}"
for VARIABLE in ${VARIABLES}
do
    log "VARIABLE=[${VARIABLE}]"
    substitute "${VARIABLE}"
done
"${SILENT}" || diff -u "${TEMPLATE}" "${TARGET}" || true

(
    cd "${DOCKER}"
    docker-compose -p foo up
)