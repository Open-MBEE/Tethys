"""The runs the harness reproduces on both sides: the pinned ``runs/sw-*.txt`` state-machine runs
of ``scripts/runs.sh`` (scenario part, machine, performer, horizon) and the host scenario file
derived from each. The machine map names the host's machine for each (performer object, machine
usage) pair the model's trace reports."""
from dataclasses import dataclass


@dataclass(frozen=True)
class Run:
    name: str               # pinned run name, also the host scenario file stem
    scenario: str           # scenario part instantiated on the model side
    machine: str            # state machine definition usage the pinned run names
    performer: str          # object the machine runs on
    advance: int            # horizon in seconds (one host major frame per second)
    stim_dir: str = ""      # directory of the host scenario file (default software/flight/scenarios)
    pinned: str = ""        # pinned run whose Current state: lines are the oracle (default: name)


RUNS = (
    # The verification cases' own run: the Earth-impact exclusion scenario of TethysFdir driven
    # into the host from software/conformance/scenarios (pinned run fdir-earth-impact-aborted).
    Run("vc-final-targeting", "TethysFdir::earthImpactScenario", "TethysFdir::FdirTug::fdir",
        "TethysFdir::earthImpactScenario.tug.fdir", 2592000, stim_dir="software/conformance/scenarios", pinned="fdir-earth-impact-aborted"),
    Run("vc-thrust-arc", "TethysFlightBehaviour::softwareThrusterFault", "TethysFlightBehaviour::SepControlSoftware::controller",
        "TethysFlightBehaviour::softwareThrusterFault.tug.cdh.software.sepControl", 1300000, stim_dir="software/conformance/scenarios", pinned="sw-sep-string-restarting"),
    Run("sw-mode-manager-early-ops", "TethysFlightBehaviour::softwareNominalFlight", "TethysFlightBehaviour::ModeManagementSoftware::modes",
        "TethysFlightBehaviour::softwareNominalFlight.tug.cdh.software.modeManagement", 17280),
    Run("sw-mode-manager-thrust-arc", "TethysFlightBehaviour::softwareNominalFlight", "TethysFlightBehaviour::ModeManagementSoftware::modes",
        "TethysFlightBehaviour::softwareNominalFlight.tug.cdh.software.modeManagement", 2678400),
    Run("sw-mode-manager-proximity-ops", "TethysFlightBehaviour::softwareNominalFlight", "TethysFlightBehaviour::ModeManagementSoftware::modes",
        "TethysFlightBehaviour::softwareNominalFlight.tug.cdh.software.modeManagement", 38016000),
    Run("sw-mode-manager-full-flight", "TethysFlightBehaviour::softwareNominalFlight", "TethysFlightBehaviour::ModeManagementSoftware::modes",
        "TethysFlightBehaviour::softwareNominalFlight.tug.cdh.software.modeManagement", 129600000),
    Run("sw-mode-manager-dispatch", "TethysFlightBehaviour::softwareNominalFlight", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher",
        "TethysFlightBehaviour::softwareNominalFlight.tug.cdh.software.modeManagement", 129600000),
    Run("sw-mode-manager-safe", "TethysFlightBehaviour::softwareCommandLoss", "TethysFlightBehaviour::ModeManagementSoftware::modes",
        "TethysFlightBehaviour::softwareCommandLoss.tug.cdh.software.modeManagement", 1555200),
    Run("sw-mode-manager-recovered", "TethysFlightBehaviour::softwareCommandLoss", "TethysFlightBehaviour::ModeManagementSoftware::modes",
        "TethysFlightBehaviour::softwareCommandLoss.tug.cdh.software.modeManagement", 2160000),
    Run("sw-fdir-command-loss-expired", "TethysFlightBehaviour::softwareCommandLoss", "TethysFlightBehaviour::FdirSoftware::supervisor",
        "TethysFlightBehaviour::softwareCommandLoss.tug.cdh.software.fdir", 1555200),
    Run("sw-fdir-thruster-restarting", "TethysFlightBehaviour::softwareThrusterFault", "TethysFlightBehaviour::FdirSoftware::supervisor",
        "TethysFlightBehaviour::softwareThrusterFault.tug.cdh.software.fdir", 876960),
    Run("sw-sep-string-restarting", "TethysFlightBehaviour::softwareThrusterFault", "TethysFlightBehaviour::SepControlSoftware::controller",
        "TethysFlightBehaviour::softwareThrusterFault.tug.cdh.software.sepControl", 876960),
    Run("sw-capture-controller", "TethysFlightBehaviour::captureNominal", "TethysFlightBehaviour::CaptureControlSoftware::controller",
        "TethysFlightBehaviour::captureNominal.captureControl", 20000),
    Run("sw-capture-controller-inhibited", "TethysFlightBehaviour::capturePrematureContact", "TethysFlightBehaviour::CaptureControlSoftware::controller",
        "TethysFlightBehaviour::capturePrematureContact.captureControl", 20000),
    Run("sw-boot", "TethysFlightBehaviour::bootScenario", "TethysFlightBehaviour::ParameterBootUpdateSoftware::manager",
        "TethysFlightBehaviour::bootScenario.bootUpdate", 3000),
    Run("sw-failover", "TethysFlightBehaviour::failoverScenario", "TethysFlightBehaviour::BehaviouralCdh::redundancy",
        "TethysFlightBehaviour::failoverScenario.cdh", 600),
)

# (owner part usage, machine usage) -> host machine name. The owner is the last segment of the
# element the trace's object refers to, so the map holds across the scenario parts that exhibit
# the same software. The tug's own `modes` (SoftwareFlightScenario::tug) is the system-level
# exhibit of TugModes; the host runs the software's copy under modeManagement.
MACHINE_MAP = {
    ("modeManagement", "modes"): "TugModes",
    ("modeManagement", "dispatcher"): "ModeManagementDispatcher",
    ("fdir", "supervisor"): "FdirSupervisor",
    ("tug", "fdir"): "FdirSupervisor",
    ("fdir", "fdir"): "FdirSupervisor",  # the FdirTug's own exhibit: the traced object is the state usage itself
    ("tug", "modes"): "TugModes",
    ("fdir", "responseRelay"): "FdirResponseRelay",
    ("sepControl", "controller"): "SepStringController",
    ("powerManagement", "manager"): "PowerManager",
    ("thermalControl", "controller"): "ThermalController",
    ("telecom", "manager"): "TelecomManager",
    ("inspectorHandling", "handler"): "InspectorHandler",
    ("captureControl", "controller"): "CaptureController",
    ("cdh", "redundancy"): "RedundancyManager",
    ("parameterBootUpdate", "manager"): "BootUpdateManager",
    ("bootUpdate", "manager"): "BootUpdateManager",
}

HOST_MACHINES = ("SepStringController", "PowerManager", "ThermalController", "TelecomManager", "InspectorHandler",
                 "CaptureController", "RedundancyManager", "BootUpdateManager", "TugModes", "ModeManagementDispatcher",
                 "FdirSupervisor", "FdirResponseRelay")

# Divergences adjudicated in docs/findings/WP-SW-13.md; keyed by (run name or "*", host machine).
ADJUDICATED: dict[tuple[str, str], str] = {
    ("vc-final-targeting", "TugModes"): "F-SW1305: the pinned run instantiates a second FdirSupervisor for the scenario's general "
                                        "`tug` part that no uplink reaches; its command-loss timer requests safe mode at t=604800",
    ("*", "InspectorHandler"): "F-SW1304: the host's on-board sequence 3 sends InspectorCheckoutGo/InspectorReleaseGo/"
                               "InspectorImagingGo as step items; the model's InspectorReleaseSequence (61) sends nothing",
}
