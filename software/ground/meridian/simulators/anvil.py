"""``TethysGroundSoftware::HardwareInTheLoopTestBed`` (Meridian Anvil): the flatsat's engineering-model
avionics with the flight software; the remote interface units are simulated from the ICD register
maps (``argent_tables.interfaces.REGISTERS``)."""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import interfaces

from .mirror import FlightSoftwareInTheLoopSimulator

MODEL_DEFINITION = "TethysGroundSoftware::HardwareInTheLoopTestBed"


@dataclass
class HardwareInTheLoopTestBed(FlightSoftwareInTheLoopSimulator):
    """Meridian Anvil: Mirror plus the register maps of the remote interface units."""

    path: str = "testBeds.flatsat"
    registers: dict[tuple[str, int], int] = field(default_factory=dict)

    def read(self, register_map: str, address: int) -> int:
        self.register_definition(register_map, address)
        return self.registers.get((register_map, address), 0)

    def write(self, register_map: str, address: int, value: int) -> None:
        reg = self.register_definition(register_map, address)
        if "read" == reg.access.lower():
            raise PermissionError(f"{register_map}[{address:#x}] is read-only")
        if value < 0 or value >= 1 << reg.width_bits:
            raise ValueError(f"{value} does not fit {reg.width_bits} bits")
        self.registers[(register_map, address)] = value

    @staticmethod
    def register_definition(register_map: str, address: int) -> interfaces.Register:
        for r in interfaces.REGISTERS:
            if r.map == register_map and r.address == address:
                return r
        raise KeyError(f"{register_map} has no register at {address:#x}")
