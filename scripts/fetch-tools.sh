#!/bin/sh
# Fetch the OpenSysML nightly and the pinned OMG pilot validator into build/.
set -eu
mkdir -p build/opensysml
if [ ! -x build/opensysml/sysml ]; then
  curl -fsSL https://raw.githubusercontent.com/Open-MBEE/OpenSysML/develop/install.sh | sh -s -- --version nightly --tools sysml --prefix "$PWD/build/opensysml"
fi
if [ ! -x build/pilot-validator/validate-sysml ]; then
  echo "pilot validator: run OpenSysML's scripts/download-pilot-validator.sh and copy build/pilot-validator here" >&2
  exit 1
fi
