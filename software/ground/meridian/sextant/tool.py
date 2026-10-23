"""``TethysGroundSoftware::FlightDynamicsTool`` (Meridian Sextant): orbit determination
(``OrbitDetermination``) and low-thrust arc design (``ManoeuvreDesign``) are the model's calculations,
evaluated through the pinned OpenSysML client against the pinned ``sysml-grpc`` — nothing here
re-implements them.
"""

from __future__ import annotations

from dataclasses import dataclass

from argent_tables import ground

from ..modelbridge import ModelBridge, magnitude

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.fdf.flightDynamicsTool"
MODEL_DEFINITION = "TethysGroundSoftware::FlightDynamicsTool"
CONTEXT = "TethysGroundSoftware"


@dataclass(frozen=True)
class Ephemeris:
    """``TethysGroundSoftware::Ephemeris``."""

    span_d: float
    step_s: float
    position_uncertainty_km: float


@dataclass(frozen=True)
class DeltaVLedger:
    """``TethysGroundSoftware::DeltaVLedger``."""

    delta_v_planned_m_s: float
    delta_v_executed_m_s: float
    xenon_committed_kg: float
    arc_duration_s: float


@dataclass
class FlightDynamicsTool:
    """Meridian Sextant: a thin client of the model."""

    bridge: ModelBridge
    model = ground.COMPONENTS_BY_PATH["fdf.flightDynamicsTool"]

    @property
    def product_name(self) -> str:
        return self.model.product_name

    def orbit_determination(self, single_pass_uncertainty_km: float, passes_in_arc: int) -> float:
        """``OrbitDetermination``: position uncertainty in km."""
        value = self.bridge.eval(f"OrbitDetermination({single_pass_uncertainty_km!r} [km], {int(passes_in_arc)})", context=CONTEXT)
        return float(magnitude(value))

    def manoeuvre_design(self, delta_v_m_s: float, stack_mass_kg: float, exhaust_velocity_m_s: float, acceleration_m_s2: float) -> DeltaVLedger:
        """``ManoeuvreDesign``: the arc duration (its return) and the xenon it needs (its attribute)."""
        call = f"ManoeuvreDesign({delta_v_m_s!r} ['m/s'], {stack_mass_kg!r} [kg], {exhaust_velocity_m_s!r} ['m/s'], {acceleration_m_s2!r} ['m/s²'])"
        duration = float(magnitude(self.bridge.eval(call, context=CONTEXT)))
        xenon = float(magnitude(self.bridge.eval(f"{stack_mass_kg!r} [kg] * ({delta_v_m_s!r} ['m/s'] / {exhaust_velocity_m_s!r} ['m/s'])", context=CONTEXT)))
        return DeltaVLedger(delta_v_m_s, 0.0, xenon, duration)

    def argent_od(self) -> float:
        """The model's own ``argentOd`` on the instantiated suite."""
        return float(magnitude(self.bridge.eval(f"{MODEL_PART}.argentOd.positionUncertainty", subject="TethysGroundSoftware::meridianOperationsSuite")))

    def return_arc(self) -> tuple[float, float]:
        """The model's own ``returnArc``: (arc duration s, xenon kg) on the instantiated suite."""
        d = self.bridge.eval(f"{MODEL_PART}.returnArc.arcDuration", subject="TethysGroundSoftware::meridianOperationsSuite")
        x = self.bridge.eval(f"{MODEL_PART}.returnArc.xenon", subject="TethysGroundSoftware::meridianOperationsSuite")
        return float(magnitude(d)), float(magnitude(x))
