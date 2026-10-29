#!/bin/sh
# Fetch the tools `make check` needs into build/: OpenSysML built from source at the pinned
# develop commit (the binary and the "OpenSysML Libraries" sources come from the same checkout,
# so runs/ are reproducible), the pinned OMG pilot validator and the batch pilot validator built
# against the same pinned jar. The commit is the one place the OpenSysML pin lives; `make runs`
# records it (commit + Go version only) in runs/tool-version.txt, so the Go toolchain that
# builds the binary is pinned too (GOTOOLCHAIN fetches it when the host's go differs).
set -eu
OPENSYSML_REPO=${OPENSYSML_REPO:-https://github.com/Open-MBEE/OpenSysML}
OPENSYSML_COMMIT=${OPENSYSML_COMMIT:-5cd37f288fef171d62737d6045f4caff772b6014}
export GOTOOLCHAIN=${GOTOOLCHAIN:-go1.25.11}
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
# A binary left by an earlier install (or built from another checkout) is only kept when it
# reports the pinned commit and Go toolchain, so a stale build never records a run.
sysml_at_pin() {
  [ -x build/opensysml/sysml ] || return 1
  version=$(build/opensysml/sysml -version 2>/dev/null) || return 1
  commit=$(printf '%s\n' "$version" | awk '/^ *Commit:/ { print $2 }')
  go=$(printf '%s\n' "$version" | awk '/^ *Go version:/ { print $3 }')
  [ -n "$commit" ] && [ "$go" = "$GOTOOLCHAIN" ] || return 1
  case "$OPENSYSML_COMMIT" in "$commit"*) return 0 ;; esac
  return 1
}
if ! sysml_at_pin; then
  rm -f build/opensysml/sysml
  (cd build/opensysml-src && make build-sysml COMMIT="$OPENSYSML_COMMIT")
  cp build/opensysml-src/bin/sysml build/opensysml/sysml
fi
if [ ! -x build/pilot-sysml-validator/validate-sysml-batch ]; then
  (cd build/opensysml-src && ./scripts/download-pilot-sysml-validator.sh)
  rm -rf build/pilot-validator build/pilot-sysml-validator
  cp -r build/opensysml-src/build/pilot-validator build/opensysml-src/build/pilot-sysml-validator build/
fi
