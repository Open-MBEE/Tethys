#!/bin/sh
# Fetch the tools `make check` needs into build/: the OpenSysML nightly, an OpenSysML source
# checkout (for its "OpenSysML Libraries" sources), the pinned OMG pilot validator and the
# batch pilot validator built against the same pinned jar.
set -eu
mkdir -p build/opensysml
if [ ! -x build/opensysml/sysml ]; then
  curl -fsSL https://raw.githubusercontent.com/Open-MBEE/OpenSysML/develop/install.sh | sh -s -- --version nightly --tools sysml --prefix "$PWD/build/opensysml"
fi
if [ ! -d build/opensysml-src ]; then
  git clone --depth 1 https://github.com/Open-MBEE/OpenSysML build/opensysml-src
fi
if [ ! -x build/pilot-sysml-validator/validate-sysml-batch ]; then
  (cd build/opensysml-src && ./scripts/download-pilot-sysml-validator.sh)
  rm -rf build/pilot-validator build/pilot-sysml-validator
  cp -r build/opensysml-src/build/pilot-validator build/opensysml-src/build/pilot-sysml-validator build/
fi
