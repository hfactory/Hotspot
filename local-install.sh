#!/bin/bash

function error {
    echo "Error: $@" >&2
}

function error_exit {
    error "$@"
    exit 1
}

VERSION=$(grep "version :=" build.sbt | sed 's/.*"\(.*\)"/\1/')

APPSTORE="../TestAppStore/Hotspot"
if [ -n "$1" ]; then
    APPSTORE=$1
fi

LIBDIR="${APPSTORE}/lib"

[ -d "${LIBDIR}" ] || mkdir -p "${LIBDIR}" || error_exit "App store lib does not exist or is not a directory: ${LIBDIR}"

echo "Installing Serve App assemblies of version ${VERSION}..."
cp target/scala-2.10/hotspot-assembly-${VERSION}.jar "${LIBDIR}" || exit 1
cp lib/* "${LIBDIR}"
cp -r web-resources "${APPSTORE}"
echo "Edit or create ${APPSTORE}/conf/Hotspot.conf."
