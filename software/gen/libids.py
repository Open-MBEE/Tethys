"""Names for the standard-library element ids the api-json form carries.

KerML fixes the ids of library elements as name-based UUIDs: the library package's id is
``uuid5(NAMESPACE_URL, prefix + package)`` and a member's is ``uuid5(package id, qualified name)``.
The pinned tool spells them that way, so the generator scans the library sources it bundles for
the declared names and derives the same ids, rather than hard-coding a table.
"""

from __future__ import annotations

import os
import re
import uuid

PREFIXES = {
    "Kernel Libraries": "https://www.omg.org/spec/KerML/",
    "Systems Library": "https://www.omg.org/spec/SysML/",
    "Domain Libraries": "https://www.omg.org/spec/SysML/",
    "OpenSysML Libraries": "https://github.com/Open-MBEE/OpenSysML-Extensions-Library/",
}
_PACKAGE = re.compile(r"^\s*(?:standard\s+)?library\s+package\s+(?:<\w+>\s*)?(\w+)", re.M)
_DECL = re.compile(
    r"^\s*(?:abstract\s+)?(?:attribute\s+def|datatype|attribute|part\s+def|item\s+def|enum\s+def|"
    r"enum|class|struct|calc\s+def|constraint\s+def|action\s+def|state\s+def|port\s+def|"
    r"interface\s+def|connection\s+def|occurrence\s+def|metadata\s+def|function|feature)\s+"
    r"(?:<(\w+)>\s*)?(\w+)?", re.M)


def library_ids(stdlib_root: str) -> dict[str, str]:
    """Map the id of every top-level-package member of the bundled libraries to ``Pkg::Name``."""
    out: dict[str, str] = {}
    for section, prefix in PREFIXES.items():
        root = os.path.join(stdlib_root, section)
        if not os.path.isdir(root):
            continue
        for dirpath, _, files in os.walk(root):
            for fn in sorted(files):
                if not fn.endswith((".kerml", ".sysml")):
                    continue
                with open(os.path.join(dirpath, fn), encoding="utf-8") as f:
                    text = f.read()
                m = _PACKAGE.search(text)
                if not m:
                    continue
                pkg = m.group(1)
                pkg_id = uuid.uuid5(uuid.NAMESPACE_URL, prefix + pkg)
                out[str(pkg_id)] = pkg
                for d in _DECL.finditer(text):
                    for name in (d.group(1), d.group(2)):
                        if name:
                            qn = f"{pkg}::{name}"
                            out[str(uuid.uuid5(pkg_id, qn))] = qn
    return out
