"""``TethysGroundSoftware::PassPlanner`` (Meridian Almanac): from the stations' visibility of the tug
(``StationVisible``) and the MLS-2 rate set of the planned mode (``argent_tables.telemetry.MODE_RATE_SETS``)
it allocates the day's passes (``TethysOperations::DailyPassPlan``) and checks that the activities
allocated to each pass fit its volume (``PassVolume``).
"""

from __future__ import annotations

from dataclasses import dataclass

from argent_tables import ground, telemetry

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.moc.passPlanner"
MODEL_DEFINITION = "TethysGroundSoftware::PassPlanner"


def station_visible(station_longitude_deg: float, sub_point_longitude_deg: float, half_width_deg: float) -> bool:
    """``StationVisible``: the sub-point longitude within the station's half-width."""
    return station_longitude_deg - half_width_deg <= sub_point_longitude_deg <= station_longitude_deg + half_width_deg


def pass_volume_bits(downlink_bit_s: float, pass_duration_h: float, lock_up_s: float) -> float:
    """``PassVolume``: the downlink rate over the pass after lock-up, in bits."""
    return downlink_bit_s * (pass_duration_h * 3600.0 - lock_up_s)


@dataclass(frozen=True)
class PlannedPass:
    name: str
    station: str
    duration_h: float
    volume_bits: float
    activities: tuple[str, ...]
    allocated_bits: float

    @property
    def fits(self) -> bool:
        return self.allocated_bits <= self.volume_bits


@dataclass(frozen=True)
class DailyPassPlan:
    """``TethysGroundSoftware::PlannedDailyPassPlan``: the day's passes at one rate set."""

    mode: str
    passes: tuple[PlannedPass, ...]

    def volume(self, pass_name: str) -> float:
        return next(p.volume_bits for p in self.passes if p.name == pass_name)

    @property
    def imagery_fits(self) -> bool:
        return all(p.fits for p in self.passes)


@dataclass
class PassPlanner:
    """Meridian Almanac."""

    visibility_half_width_deg: float = ground.VISIBILITY_HALF_WIDTH.value
    lock_up_s: float = ground.LOCK_UP.value
    model = ground.COMPONENTS_BY_PATH["moc.passPlanner"]

    @property
    def product_name(self) -> str:
        return self.model.product_name

    def sees(self, station: str, sub_point_longitude_deg: float) -> bool:
        return station_visible(ground.STATIONS_BY_NAME[station].longitude, sub_point_longitude_deg, self.visibility_half_width_deg)

    def visible_stations(self, sub_point_longitude_deg: float) -> list[str]:
        return [s.name for s in ground.STATIONS if self.sees(s.name, sub_point_longitude_deg)]

    def rate_set(self, mode: str) -> telemetry.ModeRateSet:
        return telemetry.RATE_SET_BY_MODE[mode]

    def plan_day(self, mode: str = ground.PLANNED_MODE) -> DailyPassPlan:
        """The baseline three-pass day of ``DailyPassPlan`` at the planned mode's downlink rate."""
        rate = self.rate_set(mode).downlink_bit_s
        volumes = {a.name: a.volume for a in ground.DOWNLINK_ACTIVITIES}
        passes = []
        for p in ground.STATION_PASSES:
            acts = tuple(a.activity for a in ground.PASS_ALLOCATIONS if a.station_pass == p.name)
            passes.append(PlannedPass(p.name, p.station, p.duration, pass_volume_bits(rate, p.duration, self.lock_up_s), acts,
                                      sum(volumes[a] for a in acts)))
        return DailyPassPlan(mode, tuple(passes))
