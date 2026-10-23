"""Streaming reader for the pinned OpenSysML ``-convert api-json`` element form.

The whole-model JSON is several hundred megabytes, so the reader never holds it: it walks the
top-level element array object by object, keeps a reduced record of every element under the
packages the generator reads, and drops the rest.  Element ids are the tool's qualified ids
(``Package__member__nested``; anonymous members are ``___N``), which the record index relies on.
"""

from __future__ import annotations

import json
import os
import subprocess
import tempfile
from dataclasses import dataclass, field

KEEP_KEYS = (
    "@type", "@id", "declaredName", "sysx:sourceLine", "sysx:memberIndex", "owner",
    "value", "referent", "operator", "argument", "redefines", "source", "target",
    "triggerAction", "guardExpression", "effectAction", "payloadParameter", "payloadArgument",
    "receiverArgument", "succession", "isVariant", "direction", "typedFeature", "type",
    "kind", "targetFeature", "sysx:sourceMember", "body", "sysx:sourceText", "general",
    "specific", "subclassifier", "superclassifier", "connectorEnd", "referencedFeature",
    "referencingFeature", "ownedMemberElement", "memberElement", "importedNamespace",
    "importedMembership", "parameter", "result", "ownedRelationship", "visibility",
)
# sourceText is the whole body for usages; it is only kept for expressions, where it names guards.
TEXT_TYPES = {
    "OperatorExpression", "FeatureReferenceExpression", "FeatureChainExpression",
    "InvocationExpression", "LiteralInteger", "LiteralRational", "LiteralString",
    "LiteralBoolean", "LiteralInfinity", "NullExpression", "SelectExpression",
    "CollectExpression", "IndexExpression", "MetadataAccessExpression", "ConstructorExpression",
    "TriggerInvocationExpression", "InstantiationExpression",
}


def _ref(v):
    if isinstance(v, dict):
        return v.get("@id")
    if isinstance(v, list):
        return [x.get("@id") if isinstance(x, dict) else x for x in v]
    return v


@dataclass
class Element:
    id: str
    type: str
    name: str | None
    line: int
    index: int
    owner: str | None
    props: dict = field(default_factory=dict)

    def get(self, key, default=None):
        return self.props.get(key, default)

    @property
    def text(self):
        return self.props.get("sysx:sourceText")


class ModelIndex:
    """The reduced element records of the selected packages, indexed by id and by owner."""

    def __init__(self):
        self.elements: dict[str, Element] = {}
        self.children: dict[str, list[Element]] = {}
        self.typing: dict[str, list[str]] = {}
        self.generals: dict[str, list[str]] = {}
        self.redefined: dict[str, str] = {}

    def add(self, obj: dict):
        eid = obj["@id"]
        props = {}
        for k in KEEP_KEYS:
            if k in obj:
                v = obj[k]
                if k == "sysx:sourceText" and obj.get("@type") not in TEXT_TYPES:
                    continue
                props[k] = _ref(v) if k not in ("declaredName", "body", "sysx:sourceText", "operator", "kind", "direction", "visibility", "isVariant", "@type", "@id", "sysx:sourceLine", "sysx:memberIndex") else v
        el = Element(eid, obj.get("@type", ""), obj.get("declaredName"), obj.get("sysx:sourceLine", 0), obj.get("sysx:memberIndex", -1), props.get("owner"), props)
        self.elements[eid] = el
        if el.owner:
            self.children.setdefault(el.owner, []).append(el)
        if el.type == "FeatureTyping" and props.get("typedFeature") and props.get("type"):
            self.typing.setdefault(props["typedFeature"], []).append(props["type"])
        if el.type == "Redefinition" and props.get("specific") and props.get("general"):
            self.redefined[props["specific"]] = props["general"]
        if el.type == "Subclassification" and props.get("specific") and props.get("general"):
            self.generals.setdefault(props["specific"], []).append(props["general"])

    def finish(self):
        for lst in self.children.values():
            lst.sort(key=lambda e: (e.line, e.index, e.id))

    def __getitem__(self, eid):
        return self.elements[eid]

    def kids(self, eid, type_=None):
        lst = self.children.get(eid, [])
        return [e for e in lst if type_ is None or e.type == type_] if type_ else lst

    def named(self, eid):
        return [e for e in self.children.get(eid, []) if e.name]

    def member(self, eid, name):
        return self.elements.get(f"{eid}__{name}")

    def types_of(self, eid):
        return self.typing.get(eid, [])

    def supertypes(self, eid):
        """The classifier and every general classifier of an element, nearest first."""
        out, todo = [], list(self.typing.get(eid, [])) or [eid]
        while todo:
            t = todo.pop(0)
            if t in out:
                continue
            out.append(t)
            todo.extend(self.generals.get(t, []))
        return out


def convert(sysml: str, files: list[str], out_path: str) -> None:
    """Run the pinned tool's ``-convert api-json`` over the model files into ``out_path``."""
    subprocess.run([sysml, "-convert", "api-json", "-o", out_path, *files], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def read(path: str, packages: tuple[str, ...]) -> ModelIndex:
    """Stream the api-json file at ``path``, keeping the elements of ``packages``."""
    prefixes = tuple(p + "__" for p in packages) + packages
    idx = ModelIndex()
    buf: list[str] = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            if line.startswith("  {"):
                buf = [line[2:]]
                continue
            if line.startswith("  }"):
                buf.append("}")
                text = "".join(buf)
                buf = []
                i = text.find('"@id": "')
                if i < 0:
                    continue
                j = text.find('"', i + 8)
                eid = text[i + 8:j]
                if eid.startswith(prefixes):
                    idx.add(json.loads(text))
                continue
            if buf:
                buf.append(line)
    idx.finish()
    return idx


def load(sysml: str, files: list[str], packages: tuple[str, ...], cache: str | None = None) -> ModelIndex:
    """Convert (or reuse ``cache``) and read the selected packages."""
    if cache and os.path.exists(cache):
        return read(cache, packages)
    fd, tmp = tempfile.mkstemp(suffix=".api.json", dir=os.path.dirname(cache) if cache else None)
    os.close(fd)
    try:
        convert(sysml, files, tmp)
        if cache:
            os.replace(tmp, cache)
            return read(cache, packages)
        return read(tmp, packages)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)
