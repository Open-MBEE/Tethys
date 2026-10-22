#!/bin/sh
# Fetch the tools `make check` needs into build/: OpenSysML built from source at the pinned
# develop commit (the binary and the "OpenSysML Libraries" sources come from the same checkout,
# so runs/ are reproducible), the pinned OMG pilot validator and the batch pilot validator built
# against the same pinned jar. The commit is the one place the OpenSysML pin lives; `make runs`
# records it (commit + Go version only) in runs/tool-version.txt.
set -eu
OPENSYSML_REPO=${OPENSYSML_REPO:-https://github.com/Open-MBEE/OpenSysML}
OPENSYSML_COMMIT=${OPENSYSML_COMMIT:-5cd37f288fef171d62737d6045f4caff772b6014}
mkdir -p build/opensysml
if [ ! -d build/opensysml-src ]; then
  git init -q build/opensysml-src
  git -C build/opensysml-src remote add origin "$OPENSYSML_REPO"
fi
if [ "$(git -C build/opensysml-src rev-parse HEAD 2>/dev/null || true)" != "$OPENSYSML_COMMIT" ]; then
  git -C build/opensysml-src fetch -q --depth 1 origin "$OPENSYSML_COMMIT"
  git -C build/opensysml-src checkout -q --detach FETCH_HEAD
  rm -f build/opensysml/sysml
fi
if [ ! -x build/opensysml/sysml ]; then
  (cd build/opensysml-src && make build-sysml COMMIT="$OPENSYSML_COMMIT")
  cp build/opensysml-src/bin/sysml build/opensysml/sysml
fi
if [ ! -x build/pilot-sysml-validator/validate-sysml-batch ]; then
  (cd build/opensysml-src && ./scripts/download-pilot-sysml-validator.sh)
  rm -rf build/pilot-validator build/pilot-sysml-validator
  cp -r build/opensysml-src/build/pilot-validator build/opensysml-src/build/pilot-sysml-validator build/
fi
