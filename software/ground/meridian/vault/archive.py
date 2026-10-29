"""``TethysGroundSoftware::DataArchive`` (Meridian Vault): catalogues every product level with a
checksum (``checksumWidth`` bits), keeps each by its retention rule (``RETENTION_RULES``) and
distributes the released levels; raw frames (level l0) stay in house.
"""

from __future__ import annotations

import zlib
from dataclasses import dataclass, field

from argent_tables import ground

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.sds.dataArchive"
MODEL_DEFINITION = "TethysGroundSoftware::DataArchive"
RULES_BY_LEVEL = {r.level: r for r in ground.RETENTION_RULES}


@dataclass(frozen=True)
class CatalogueEntry:
    name: str
    level: str
    volume_b: int
    checksum: int
    retention_days: float
    distributed: bool
    ingested_day: float


@dataclass
class DataArchive:
    """Meridian Vault."""

    catalogue: list[CatalogueEntry] = field(default_factory=list)
    model = ground.COMPONENTS_BY_PATH["sds.dataArchive"]
    checksum_width = ground.CHECKSUM_WIDTH
    rules = ground.RETENTION_RULES

    @property
    def product_name(self) -> str:
        return self.model.product_name

    @property
    def distributed_levels(self) -> int:
        return sum(1 for r in self.rules if r.distributed)

    @property
    def catalogued(self) -> int:
        return len(self.catalogue)

    @staticmethod
    def checksum(data: bytes) -> int:
        return zlib.crc32(data) & ((1 << ground.CHECKSUM_WIDTH) - 1)

    def ingest(self, name: str, level: str, data: bytes, day: float = 0.0) -> CatalogueEntry:
        rule = RULES_BY_LEVEL[level]
        entry = CatalogueEntry(name, level, len(data), self.checksum(data), rule.retention, rule.distributed, day)
        self.catalogue.append(entry)
        return entry

    def distributable(self) -> list[CatalogueEntry]:
        return [e for e in self.catalogue if e.distributed]

    def retained(self, day: float) -> list[CatalogueEntry]:
        return [e for e in self.catalogue if day - e.ingested_day <= e.retention_days]

    def verify(self, entry: CatalogueEntry, data: bytes) -> bool:
        return self.checksum(data) == entry.checksum
