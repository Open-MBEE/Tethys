"""``TethysGroundSoftware::DynamicsSimulator`` (Meridian Orrery): the six-degree-of-freedom
proximity-operations simulator reduced to the relative range the planner needs: a straight-line
closing from standoff at a commanded range rate, reporting ``RelativeNavigationProduct`` rows."""

from __future__ import annotations

from dataclasses import dataclass

from ..compass.planner import RelativeNavigationProduct
from .base import Simulator

MODEL_DEFINITION = "TethysGroundSoftware::DynamicsSimulator"


@dataclass
class DynamicsSimulator(Simulator):
    """Meridian Orrery."""

    path: str = "testBeds.dynamicsSimulator"
    range_m: float = 2000.0
    range_rate_m_s: float = 0.0
    range_uncertainty_m: float = 5.0
    time_s: float = 0.0

    def command_rate(self, range_rate_m_s: float) -> None:
        self.range_rate_m_s = range_rate_m_s

    def step(self, dt_s: float) -> RelativeNavigationProduct:
        self.range_m = max(0.0, self.range_m + self.range_rate_m_s * dt_s)
        self.time_s += dt_s
        self.range_uncertainty_m = max(0.5, self.range_uncertainty_m * (self.range_m / 2000.0) ** 0.5) if self.range_m < 2000.0 else self.range_uncertainty_m
        return self.product()

    def product(self) -> RelativeNavigationProduct:
        return RelativeNavigationProduct("orrery", self.range_m, self.range_rate_m_s, self.range_uncertainty_m)
