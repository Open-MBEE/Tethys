"""``TethysGroundSoftware::Simulator``: a test bed run by suite software, with a packet port."""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import ground


@dataclass
class Simulator:
    path: str
    packets: list[bytes] = field(default_factory=list)

    @property
    def table(self) -> ground.GroundComponent:
        return ground.COMPONENTS_BY_PATH[self.path]

    @property
    def product_name(self) -> str:
        return self.table.product_name

    @property
    def flight_software_in_the_loop(self) -> bool:
        return self.table.flight_software_in_the_loop

    @property
    def hardware_in_the_loop(self) -> bool:
        return self.table.hardware_in_the_loop

    fidelity: str = ""
