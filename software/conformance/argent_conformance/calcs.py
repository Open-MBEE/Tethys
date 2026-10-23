"""The calc defs the software uses, with a deterministic input grid per calc.

Grid values are the model's own numbers (named in ``source``) plus boundary points. A value given
as a string is a model expression (a quantity literal such as ``"1200.0 [SI::W]"`` or an enumeration
literal); only Real/Integer/Boolean grids can reach a compiled program, so a calc with a string
in its grid is evaluated interpreted only and its compile verdict records why the pin refuses it.
Tolerance: Real results agree within ``tol`` relative (1e-12 absolute near zero); Integer,
Boolean and enumeration results must be identical."""
from dataclasses import dataclass


@dataclass(frozen=True)
class Calc:
    name: str
    params: tuple
    grid: tuple
    kind: str = "real"  # real | integer | boolean | enum
    tol: float = 1e-9
    source: str = ""
    skip: str = ""  # why no grid can be written (record/collection-typed inputs)


CALCS = (
    # model 30 — margin policy
    Calc("TethysMarginPolicy::ContingencyFor", ("maturity", "policy"), (), skip="policy is a MarginPolicyRow record; the policy table is exercised by the wpb-margin-policy run"),
    Calc("TethysMarginPolicy::WithContingency", ("estimate", "maturity", "policy"), (), skip="policy is a MarginPolicyRow record"),
    Calc("TethysMarginPolicy::MarginFraction", ("capability", "demand"), (("115.0 [SI::W]", "100.0 [SI::W]"), ("100.0 [SI::W]", "100.0 [SI::W]"), ("1119.0 [SI::W]", "1000.0 [SI::W]"), ("90.0 [SI::W]", "100.0 [SI::W]")),
         source="capability/demand pairs around the 15 % policy; 1119/1000 is the array margin shape"),
    # model 32 — budgets
    Calc("TethysBudgets::ArrayPower", ("ratedAtOneAu", "distanceAu", "endOfLifeFactor", "cosineLoss"),
         (("1200.0 [SI::W]", 1.0, 1.0, 1.0), ("1200.0 [SI::W]", 1.6, 0.9, 0.95), ("1200.0 [SI::W]", 0.8, 1.0, 1.0)), source="inverse-square points at 1, 1.6 and 0.8 AU"),
    Calc("TethysBudgets::ExpNeg", ("x",), ((0.0,), (0.5,), (1.0,), (2.0,), (10.0,)), source="exponent grid incl. 0"),
    Calc("TethysBudgets::PropellantFor", ("deltaVMPerS", "initialMass", "specificImpulse"), ((1000.0, "5000.0 [SI::kg]", "1600.0 [SI::s]"), (0.0, "5000.0 [SI::kg]", "1600.0 [SI::s]")), source="rocket equation at 1 km/s and 0"),
    Calc("TethysBudgets::MassFlowRate", ("thrustN", "specificImpulseS"), ((0.25, 1600.0), (0.1, 3000.0), (0.0, 1600.0)), source="SEP thrust/Isp points"),
    Calc("TethysBudgets::RootSumSquareDegrees", ("contributors",), (), skip="contributors is a sequence of AngularMeasureValue"),
    Calc("TethysBudgets::Survival", ("failureRate", "duration"), (("1.0e-6 [SI::Hz]", "3600.0 [SI::s]"), ("1.0e-6 [SI::Hz]", "0.0 [SI::s]")), source="unit failure rate over an hour and zero"),
    Calc("TethysBudgets::SetReliability", ("failureRates", "required", "duration"), (), skip="failureRates is a sequence"),
    Calc("TethysBudgets::UnitSetReliability", ("units", "duration"), (), skip="units is a sequence of Unit parts"),
    Calc("TethysBudgets::TugPowerInMode", ("mode",), (("TugMode::safe",), ("TugMode::coast",), ("TugMode::thrust",), ("TugMode::proximityOperations",), ("TugMode::capture",)), source="five tug modes"),
    Calc("TethysBudgets::BusPowerInMode", ("mode",), (("TugMode::safe",), ("TugMode::proximityOperations",)), source="two tug modes"),
    Calc("TethysBudgets::TugHeatInMode", ("mode",), (("TugMode::safe",), ("TugMode::thrust",)), source="two tug modes"),
    Calc("TethysBudgets::UnitsDataRate", ("units",), (), skip="units is a sequence of Unit parts"),
    Calc("TethysBudgets::ReturnableBodyMass", ("xenonAvailable", "systemMargin", "tugAloneXenon", "tugMassAtTarget"), (), skip="body-local attributes read the mission design (forReturnArcs, returnFraction)"),
    Calc("TethysBudgets::XenonForMission", ("body",), (), skip="body is a SmallBody part"),
    Calc("TethysBudgets::DespinPropellant", ("body", "momentArm", "specificImpulse"), (), skip="body is a SmallBody part"),
    Calc("TethysBudgets::RadiatorRejection", ("area", "emissivity", "temperature"), (), skip="area is an AreaValue (unit literal m^2 not expressible on one line at the pin)"),
    # model 52 — link budgets
    Calc("TethysLinkBudgets::Log10", ("x",), ((1.0,), (2.0,), (10.0,), (1000.0,), (0.001,)), source="decades and 2"),
    Calc("TethysLinkBudgets::DecibelsFromRatio", ("ratio",), ((1.0,), (2.0,), (10.0,), (0.5,)), source="0, 3, 10, -3 dB"),
    Calc("TethysLinkBudgets::RatioFromDecibels", ("db",), ((0.0,), (3.0,), (10.0,), (-3.0,)), source="inverse of the above"),
    Calc("TethysLinkBudgets::Wavelength", ("frequencyHz",), ((8.4e9,), (2.2e9,), (32.0e9,)), source="X, S and Ka band"),
    Calc("TethysLinkBudgets::DishGainDbi", ("diameterM", "frequencyHz", "efficiency"), ((34.0, 8.4e9, 0.55), (2.0, 8.4e9, 0.6), (0.5, 2.2e9, 0.5)), source="station, tug and inspector dishes"),
    Calc("TethysLinkBudgets::FreeSpaceLossDb", ("rangeM", "frequencyHz"), ((1.5e11, 8.4e9), (4.0e8, 8.4e9), (2.0e4, 2.2e9)), source="1 AU, lunar distance, proximity link"),
    Calc("TethysLinkBudgets::GainToNoiseTemperatureDbPerK", ("gainDbi", "systemNoiseTemperatureK"), ((68.0, 25.0), (34.0, 200.0), (0.0, 290.0)), source="station, tug, isotropic"),
    Calc("TethysLinkBudgets::LinkMarginDb", ("eirpDbw", "pathLossDb", "otherLossesDb", "gOverTDbPerK", "dataRateBps", "requiredEbN0Db", "implementationLossDb"),
         ((60.0, 270.0, 2.0, 30.0, 1.0e5, 2.5, 1.5), (60.0, 270.0, 2.0, 30.0, 1.0e3, 2.5, 1.5), (80.0, 262.0, 1.0, 50.0, 2.0e6, 4.0, 2.0)), source="downlink at 100 kbps and 1 kbps, Ka return"),
    Calc("TethysLinkBudgets::MarginReport", ("link",), (), skip="link is a LinkBudget part"),
    Calc("TethysLinkBudgets::CharacterisationDataVolume", ("diameterM", "groundSamplingM", "coverageCount", "bitsPerPixel"), ((500.0, 0.5, 2.0, 12.0), (6.8, 0.05, 3.0, 12.0)), source="500 m body, 6.8 m nominal target"),
    Calc("TethysLinkBudgets::RelayDaysRequired", ("volumeBits", "rateBps", "dailyWindowS"), ((1.0e12, 1.0e6, 3600.0), (1.0e12, 1.0e5, 7200.0), (0.0, 1.0e6, 3600.0)), source="1 Tbit at two rates and zero volume"),
    # model 66 — flight timing
    Calc("TethysFlightTiming::TaskDemandInFrame", ("task", "frameIndex"), (), skip="task is a ScheduledTask part; the sw-timing-budgets run covers the schedule"),
    Calc("TethysFlightTiming::TasksDemandInFrame", ("tasks", "frameIndex"), (), skip="tasks is a sequence of ScheduledTask parts"),
    Calc("TethysFlightTiming::Utilisation", ("tasks",), (), skip="tasks is a sequence of ScheduledTask parts"),
    Calc("TethysFlightTiming::TaskResponse", ("task",), (), skip="task is a ScheduledTask part"),
    Calc("TethysFlightTiming::BusSlotsInMode", ("streams", "mode"), (), skip="streams is a sequence of BusSlotAssignment parts; compared per mode as argentSoftwareBudgets.busSlotsByMode below"),
    Calc("TethysFlightTiming::LoadInMode", ("tasks", "mode"), (), skip="tasks is a sequence of ScheduledTask parts; compared per mode as argentSoftwareBudgets.loadByMode below"),
    Calc("TethysFlightTiming::FootprintOf", ("tasks",), (), skip="tasks is a sequence of ScheduledTask parts"),
    # model 69 — ground software
    Calc("TethysGroundSoftware::ValidateCommand", ("request", "command", "argument"), (), skip="record-typed inputs; software-ground-check compares the ground forge against it"),
    Calc("TethysGroundSoftware::DecommutatePacket", ("packet",), (), skip="packet is a PacketDefinition part; software-ground-check compares the ground decom against it"),
    Calc("TethysGroundSoftware::EngineeringUnits", ("rawCount", "scale", "offset"), ((0, 1.0, 0.0), (4095, 0.01, -20.0), (2048, 1.5, 3.0), (65535, 1.0, 0.0)), source="12-bit and 16-bit counts"),
    Calc("TethysGroundSoftware::CheckLimits", ("value", "lowLimit", "highLimit", "warningBand"),
         ((5.0, 0.0, 10.0, 1.0), (9.5, 0.0, 10.0, 1.0), (0.5, 0.0, 10.0, 1.0), (10.0, 0.0, 10.0, 1.0), (10.5, 0.0, 10.0, 1.0), (-0.1, 0.0, 10.0, 1.0), (9.0, 0.0, 10.0, 1.0)),
         kind="enum", source="nominal, both warning bands, both limits exactly, both violations, band edge"),
    Calc("TethysGroundSoftware::OrbitDetermination", ("singlePassUncertainty", "passesInArc"), (("1000.0 [SI::m]", 1), ("1000.0 [SI::m]", 4), ("1000.0 [SI::m]", 9)), source="1 km per pass over 1, 4, 9 passes"),
    Calc("TethysGroundSoftware::ManoeuvreDesign", ("deltaV", "stackMass", "exhaustVelocity", "acceleration"), (), skip="quantity-typed inputs whose units (m/s, m/s^2) have no one-line literal at the pin; software-ground-check compares the ground planner against it"),
    Calc("TethysGroundSoftware::StationVisible", ("stationLongitude", "subPointLongitude", "halfWidth"),
         (("10.0 ['°']", "20.0 ['°']", "60.0 ['°']"), ("10.0 ['°']", "70.0 ['°']", "60.0 ['°']"), ("10.0 ['°']", "71.0 ['°']", "60.0 ['°']"), ("10.0 ['°']", "-50.0 ['°']", "60.0 ['°']"), ("10.0 ['°']", "-51.0 ['°']", "60.0 ['°']")),
         kind="boolean", source="inside, both edges, both outside"),
    Calc("TethysGroundSoftware::PassVolume", ("rateSet", "passDurationHours", "lockUpSeconds"), (), skip="rateSet is a LinkRateSet part"),
    Calc("TethysGroundSoftware::CheckFlightRules", ("thrusting", "relayPassActive", "rangeToTarget", "approachAuthorised", "sunAngle", "coverOpen", "stateOfCharge", "plannedMode", "keepOutRadius", "exclusionHalfAngle", "stateOfChargeFloor"),
         ((False, False, "100.0 [SI::km]", True, "90.0 ['°']", False, 0.8, "TugMode::coast", "2.0 [SI::km]", "20.0 ['°']", 0.4),
          (True, True, "100.0 [SI::km]", True, "90.0 ['°']", False, 0.8, "TugMode::coast", "2.0 [SI::km]", "20.0 ['°']", 0.4),
          (False, False, "1.0 [SI::km]", False, "90.0 ['°']", False, 0.8, "TugMode::coast", "2.0 [SI::km]", "20.0 ['°']", 0.4),
          (False, False, "100.0 [SI::km]", True, "10.0 ['°']", True, 0.8, "TugMode::coast", "2.0 [SI::km]", "20.0 ['°']", 0.4),
          (False, False, "100.0 [SI::km]", True, "90.0 ['°']", False, 0.3, "TugMode::coast", "2.0 [SI::km]", "20.0 ['°']", 0.4)),
         kind="boolean", source="all rules pass, thrust during relay, keep-out, sun exclusion, battery floor"),
    # model 85 — safety
    Calc("TethysSafety::EnvelopeMargin", ("maximumBodyDiameterM", "targetDiameterM"), ((12.0, 6.8), (12.0, 12.0), (12.0, 0.0), (10.0, 11.0)), source="envelope 12 m vs the 6.8 m nominal target, the edge, empty and over"),
)

# Budget figures that must come out identical from the model and the generated tables, with the
# policy they are held against; a failing policy is reported, never resized.
BUDGETS = (
    ("array power margin", "TethysBudgets::powerBudget.thrustingMargin", "TethysBudgets", ">= 0.15 (the margin policy row the power budget is held to)"),
    ("bus slots by mode", "TethysFlightTiming::argentSoftwareBudgets.busSlotsByMode", "TethysFlightTiming", "<= 32 of 64 in every mode (TF-011 reserve)"),
    ("processor load by mode", "TethysFlightTiming::argentSoftwareBudgets.loadByMode", "TethysFlightTiming", ""),
)
