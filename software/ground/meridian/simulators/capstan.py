"""``TethysGroundSoftware::CaptureRigController`` (Meridian Capstan): the thermal-vacuum capture rig
with its rotating mock body, driven for bag deployment and cinch tests. The rig's hazardous
commands follow the dictionary's two-step rule like the flight side's."""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import commands

from .base import Simulator

MODEL_DEFINITION = "TethysGroundSoftware::CaptureRigController"


@dataclass
class CaptureRigController(Simulator):
    """Meridian Capstan."""

    path: str = "testBeds.captureRig"
    spin_period_s: float = 60.0
    bag_deployed: bool = False
    cinched: bool = False
    armed: bool = False
    log: list[str] = field(default_factory=list)

    def spin_up(self, period_s: float) -> None:
        self.spin_period_s = period_s
        self.log.append(f"spin period {period_s} s")

    def command(self, mnemonic: str, approvals: int) -> bool:
        cmd = commands.COMMANDS_BY_MNEMONIC[mnemonic]
        if cmd.hazardous and approvals < 2:
            self.log.append(f"{mnemonic} held: hazardous, {approvals} approval(s)")
            return False
        if cmd.application != "captureControl":
            self.log.append(f"{mnemonic} refused: not a capture-control command")
            return False
        self.log.append(f"{mnemonic} executed")
        if "ARM" in mnemonic:
            self.armed = True
        elif "DEPLOY" in mnemonic:
            self.bag_deployed = self.armed
        elif "CINCH" in mnemonic:
            self.cinched = self.bag_deployed
        return True
