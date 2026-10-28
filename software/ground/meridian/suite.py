"""``TethysGroundSoftware::MeridianOperationsSuite``: the suite over the ground segment — operations
centre (``moc``), flight dynamics (``fdf``), science data system (``sds``) and the simulated test
beds, twelve components named by the generated ``GROUND_COMPONENTS`` table."""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import ground

from .almanac.planner import PassPlanner
from .compass.planner import ProximityPlanner
from .forge.builder import CommandBuilder
from .ledger.tracker import AnomalyTracker
from .lantern.server import TelemetryServer
from .modelbridge import ModelBridge
from .sextant.tool import FlightDynamicsTool
from .simulators import CaptureRigController, DynamicsSimulator, FlightSoftwareInTheLoopSimulator, HardwareInTheLoopTestBed
from .vault.archive import DataArchive
from .warden.checker import FlightRuleChecker

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite"


@dataclass
class SoftwareOperationsCentre:
    command_builder: CommandBuilder = field(default_factory=CommandBuilder)
    sequencer: FlightRuleChecker = field(default_factory=FlightRuleChecker)
    telemetry_server: TelemetryServer = field(default_factory=TelemetryServer)
    pass_planner: PassPlanner = field(default_factory=PassPlanner)
    anomaly_tracker: AnomalyTracker = field(default_factory=AnomalyTracker)
    proximity_planner: ProximityPlanner = field(default_factory=ProximityPlanner)


@dataclass
class SimulatedTestBedSet:
    flatsat: HardwareInTheLoopTestBed = field(default_factory=HardwareInTheLoopTestBed)
    capture_rig: CaptureRigController = field(default_factory=CaptureRigController)
    dynamics_simulator: DynamicsSimulator = field(default_factory=DynamicsSimulator)
    trajectory_tool: FlightSoftwareInTheLoopSimulator = field(default_factory=FlightSoftwareInTheLoopSimulator)


@dataclass
class MeridianOperationsSuite:
    """The suite; ``bridge`` is the model connection Sextant (and any model evaluation) uses."""

    bridge: ModelBridge = field(default_factory=ModelBridge)
    moc: SoftwareOperationsCentre = field(default_factory=SoftwareOperationsCentre)
    sds_archive: DataArchive = field(default_factory=DataArchive)
    test_beds: SimulatedTestBedSet = field(default_factory=SimulatedTestBedSet)

    @property
    def fdf_flight_dynamics_tool(self) -> FlightDynamicsTool:
        return FlightDynamicsTool(self.bridge)

    @property
    def components(self) -> list:
        """The twelve components in the model's ``components`` order."""
        return [self.moc.command_builder, self.moc.sequencer, self.moc.telemetry_server, self.moc.pass_planner,
                self.moc.anomaly_tracker, self.moc.proximity_planner, self.fdf_flight_dynamics_tool, self.sds_archive,
                self.test_beds.flatsat, self.test_beds.capture_rig, self.test_beds.dynamics_simulator, self.test_beds.trajectory_tool]

    @property
    def component_count(self) -> int:
        return len(self.components)

    @property
    def product_names(self) -> list[str]:
        return [c.product_name for c in self.components]

    @property
    def simulator_count(self) -> int:
        return sum(1 for c in ground.GROUND_COMPONENTS if c.simulator)
