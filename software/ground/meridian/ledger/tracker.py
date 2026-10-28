"""``TethysGroundSoftware::AnomalyTracker`` (Meridian Ledger): every alarm or fault event the
telemetry server raises opens an anomaly, which runs ``AnomalyLifecycle`` (opened → triaged →
investigating → closed) and is dispositioned by an authority no lower than the model requires
(TM-010: a safe-mode recovery is the flight director's).

The tracker also carries the programme's open items as the model states them — the failing TF-011
bus reserve and the power margin below policy from the generated and evaluated budgets, the open
SA-001/SA-002 release gate from the assurance plan — and never closes them itself.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import events, ground, schedule
from argent_tables.ground import AnomalyDisposition, DecisionAuthority

from ..statemachine import TableStateMachine

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.moc.anomalyTracker"
MODEL_DEFINITION = "TethysGroundSoftware::AnomalyTracker"
SAFE_MODE_RECOVERY_AUTHORITY = DecisionAuthority.FLIGHT_DIRECTOR
FULL_MODES = ("proximityOperations", "capture", "despin")
BUS_RESERVE_FRACTION = 0.5


@dataclass
class Anomaly:
    """``TethysGroundSoftware::AnomalyReport`` with its lifecycle."""

    anomaly_id: int
    trigger_mnemonic: str
    lifecycle: TableStateMachine
    procedure: str = ""
    disposition: AnomalyDisposition | None = None
    authority: DecisionAuthority | None = None
    safe_mode_recovery: bool = False

    @property
    def state(self) -> str:
        return self.lifecycle.state_name


@dataclass(frozen=True)
class ProgrammeGate:
    """An open item the ground surfaces exactly as the model states it."""

    name: str
    status: str
    detail: str
    passing: bool


@dataclass
class AnomalyTracker:
    """Meridian Ledger."""

    anomalies: list[Anomaly] = field(default_factory=list)
    model = ground.COMPONENTS_BY_PATH["moc.anomalyTracker"]
    fault_event_count = events.FAULT_EVENT_COUNT

    @property
    def product_name(self) -> str:
        return self.model.product_name

    def open(self, trigger_mnemonic: str, safe_mode_recovery: bool = False) -> Anomaly:
        anomaly = Anomaly(len(self.anomalies) + 1, trigger_mnemonic, TableStateMachine(ground.ANOMALY_LIFECYCLE), safe_mode_recovery=safe_mode_recovery)
        self.anomalies.append(anomaly)
        return anomaly

    def open_from_event(self, event_id: int) -> Anomaly:
        event = events.EVENTS_BY_ID[event_id]
        if not event.is_fault:
            raise ValueError(f"{event.mnemonic} is not a fault event")
        return self.open(event.mnemonic, safe_mode_recovery=event.level == "safe")

    def triage(self, anomaly: Anomaly, procedure: str) -> None:
        anomaly.procedure = procedure
        anomaly.lifecycle.accept("AnomalyTriaged")

    def assign(self, anomaly: Anomaly) -> None:
        anomaly.lifecycle.accept("AnomalyAssigned")

    def disposition(self, anomaly: Anomaly, disposition: AnomalyDisposition, authority: DecisionAuthority) -> bool:
        """TM-010: a safe-mode recovery is never dispositioned below the flight director."""
        if anomaly.safe_mode_recovery and authority not in (DecisionAuthority.FLIGHT_DIRECTOR, DecisionAuthority.MISSION_MANAGER):
            return False
        if not anomaly.lifecycle.accept("AnomalyDispositioned"):
            return False
        anomaly.disposition, anomaly.authority = disposition, authority
        return True

    @staticmethod
    def bus_reserve_gate() -> ProgrammeGate:
        """TF-011 from the generated bus schedule: slots used in the full modes against the 50 % reserve."""
        allowed = int(schedule.BUS_FRAME_SLOTS * BUS_RESERVE_FRACTION)
        used = max(load.slots_used for load in schedule.BUS_MODE_LOADS if load.mode in FULL_MODES)
        return ProgrammeGate("TF-011 busReserve", "violated" if used > allowed else "satisfied",
                             f"{used} of {schedule.BUS_FRAME_SLOTS} AABP-1 slots used in {'/'.join(FULL_MODES)}, {allowed} allowed", used <= allowed)

    @staticmethod
    def power_margin_gate(margin_fraction: float, policy_fraction: float) -> ProgrammeGate:
        """The thrusting power margin against the active margin policy, both evaluated in the model."""
        return ProgrammeGate("TS-123 powerBudgetCloses (thrusting)", "violated" if margin_fraction < policy_fraction else "satisfied",
                             f"margin {margin_fraction:.1%} against a {policy_fraction:.0%} policy", margin_fraction >= policy_fraction)

    @staticmethod
    def release_gate(all_complete: bool, independent_vv_status: str) -> ProgrammeGate:
        return ProgrammeGate("SA-001/SA-002 releaseReadiness", "open" if not all_complete else "closed",
                             f"level-A plan complete: {all_complete}; independent V&V {independent_vv_status}", all_complete)
