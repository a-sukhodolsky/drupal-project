#!/usr/bin/env bash

LOOKING_FOR_TYPE=$1

# Detect OS type
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     OS_TYPE=linux;;
    Darwin*)    OS_TYPE=macos;;
    CYGWIN*)    OS_TYPE=cygwin;;
    MINGW*)     OS_TYPE=minGw; echo "WARNING: This tool has not been tested on this OS type." 1>&2;;
    *)          echo "Unknown or unsupported OS type: ${unameOut}" 1>&2; exit 1;
esac

if [[ ! -z "${LOOKING_FOR_TYPE}" ]]; then
    if [[ ${OS_TYPE} != ${LOOKING_FOR_TYPE} ]]; then
        OS_TYPE=""
    fi
fi

echo ${OS_TYPE}
