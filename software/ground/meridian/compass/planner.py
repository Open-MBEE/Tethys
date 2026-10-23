"""``TethysGroundSoftware::ProximityPlanner`` (Meridian Compass): relative-navigation products, the
keep-out check of FR-002 (``TethysOperations::ApproachKeepOut``) on every planned approach, the
go/no-go checklist and the abort criteria the capture sequence is uplinked with.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import ground

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.moc.proximityPlanner"
MODEL_DEFINITION = "TethysGroundSoftware::ProximityPlanner"
KEEP_OUT_RADIUS_M = ground.PROXIMITY_LIMITS["keep_out_radius"].value
ABORT_RANGE_RATE_M_S = ground.PROXIMITY_LIMITS["abort_range_rate"].value
ABORT_RANGE_UNCERTAINTY_M = ground.PROXIMITY_LIMITS["abort_range_uncertainty"].value


def approach_keep_out(range_to_target_m: float, keep_out_radius_m: float, approach_authorised: bool) -> bool:
    """``ApproachKeepOut`` (FR-002)."""
    return range_to_target_m >= keep_out_radius_m or approach_authorised


@dataclass(frozen=True)
class RelativeNavigationProduct:
    """``TethysGroundSoftware::RelativeNavigationProduct``."""

    name: str
    range_m: float
    range_rate_m_s: float
    range_uncertainty_m: float

    @classmethod
    def from_table(cls, name: str) -> "RelativeNavigationProduct":
        p = ground.PROXIMITY_PRODUCTS_BY_NAME[name]
        return cls(name, p.range.value, p.range_rate.value, p.range_uncertainty.value)


@dataclass
class GoNoGoChecklist:
    """``TethysGroundSoftware::GoNoGoChecklist``: ``go`` when every item is go."""

    items: dict[str, bool] = field(default_factory=dict)

    @property
    def items_total(self) -> int:
        return len(self.items)

    @property
    def items_go(self) -> int:
        return sum(1 for v in self.items.values() if v)

    @property
    def go(self) -> bool:
        return self.items_go == self.items_total


@dataclass
class ProximityPlanner:
    """Meridian Compass."""

    keep_out_radius_m: float = KEEP_OUT_RADIUS_M
    model = ground.COMPONENTS_BY_PATH["moc.proximityPlanner"]

    @property
    def product_name(self) -> str:
        return self.model.product_name

    def keep_out_kept(self, product: RelativeNavigationProduct, approach_authorised: bool) -> bool:
        return approach_keep_out(product.range_m, self.keep_out_radius_m, approach_authorised)

    @staticmethod
    def abort_criteria_hold(product: RelativeNavigationProduct) -> bool:
        """``abortCriteriaHold``: closing slower than the abort rate, range known better than the abort uncertainty."""
        return product.range_rate_m_s > ABORT_RANGE_RATE_M_S and product.range_uncertainty_m < ABORT_RANGE_UNCERTAINTY_M

    def checklist(self, standoff: RelativeNavigationProduct, final_approach: RelativeNavigationProduct,
                  sequence_cleared: bool, release_gate_open: bool | None = None) -> GoNoGoChecklist:
        """The twelve-item go/no-go of the model's ``checklist``, each item a planning check; the
        release-gate item reports the programme gate as it is when one is given."""
        items = {
            "standoff outside keep-out": self.keep_out_kept(standoff, approach_authorised=False),
            "final approach authorised": self.keep_out_kept(final_approach, approach_authorised=True),
            "abort range rate margin": final_approach.range_rate_m_s > ABORT_RANGE_RATE_M_S,
            "abort range uncertainty margin": final_approach.range_uncertainty_m < ABORT_RANGE_UNCERTAINTY_M,
            "standoff range uncertainty known": standoff.range_uncertainty_m < self.keep_out_radius_m,
            "standoff stationary": abs(standoff.range_rate_m_s) <= -ABORT_RANGE_RATE_M_S,
            "capture sequence cleared": sequence_cleared,
            "capture sequence stored on board": any(s.name == "DespinSequence" for s in ground.ON_BOARD_SEQUENCES),
            "keep-out radius from FR-002": self.keep_out_radius_m == ground.FLIGHT_RULES_BY_ID["FR-002"].parameters[0].value,
            "sun exclusion rule loaded": "FR-003" in ground.FLIGHT_RULES_BY_ID,
            "battery floor rule loaded": "FR-004" in ground.FLIGHT_RULES_BY_ID,
            "relay rule loaded": "FR-001" in ground.FLIGHT_RULES_BY_ID,
        }
        if release_gate_open is not None:
            items["flight software release gate closed"] = not release_gate_open
        return GoNoGoChecklist(items)
