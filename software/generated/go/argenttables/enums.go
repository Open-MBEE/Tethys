// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   TethysTugStructure::TugMode
//   TethysModes::InspectorMode
//   TethysOperations::ApidClass
//   TethysFdir::FdirLevel
//   TethysFdir::FaultResponse
//   TethysFlightSoftware::SoftwareLayer
//   TethysFlightSoftware::SchedulingPolicy
//   TethysFlightSoftware::SoftwareCriticality
//   TethysFlightDictionary::ApplicationName
//   TethysFlightDictionary::CommandCriticality
//   TethysFlightDictionary::EventSeverity
//   TethysFlightDictionary::TelemetryKind
//   TethysFlightBehaviour::LoadShedTier
//   TethysFlightBehaviour::ImageSlot
//   TethysSoftwareIcds::BusErrorResponse
//   TethysSoftwareIcds::RegisterAccess
//   TethysFlightDictionary::Opcode
//   TethysFlightDictionary::EventDefinition::eventId
//   TethysFlightDictionary::ParameterRow::parameterId

package argenttables

// ModeMask is one bit per TugMode literal, in literal order (16 modes fit uint16).
type ModeMask uint16

// ModeBit is the mask bit of one mode.
func ModeBit(m TugMode) ModeMask { return ModeMask(1) << uint(m) }

// F boxes an optional float: a nil *float64 is a value the model leaves unbound.
func F(v float64) *float64 { return &v }

// TugMode is TethysTugStructure::TugMode.
type TugMode int

const (
	TugModeLaunch              TugMode = 0
	TugModeEarlyOperations     TugMode = 1
	TugModeCoast               TugMode = 2
	TugModeThrust              TugMode = 3
	TugModeApproach            TugMode = 4
	TugModeProximityOperations TugMode = 5
	TugModeRetreat             TugMode = 6
	TugModeCapture             TugMode = 7
	TugModeDespin              TugMode = 8
	TugModeStackCoast          TugMode = 9
	TugModeStackThrust         TugMode = 10
	TugModeDroHold             TugMode = 11
	TugModeDockedPassive       TugMode = 12
	TugModeDisposal            TugMode = 13
	TugModeSafe                TugMode = 14
	TugModeAbortHold           TugMode = 15
)

const TugModeCount = 16

var TugModeNames = [TugModeCount]string{"launch", "earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}

// InspectorMode is TethysModes::InspectorMode.
type InspectorMode int

const (
	InspectorModeStowed         InspectorMode = 0
	InspectorModeCheckout       InspectorMode = 1
	InspectorModeStationKeeping InspectorMode = 2
	InspectorModeImaging        InspectorMode = 3
	InspectorModeRetreat        InspectorMode = 4
	InspectorModeSafe           InspectorMode = 5
	InspectorModeRetired        InspectorMode = 6
)

const InspectorModeCount = 7

var InspectorModeNames = [InspectorModeCount]string{"stowed", "checkout", "stationKeeping", "imaging", "retreat", "safe", "retired"}

// ApidClass is TethysOperations::ApidClass.
type ApidClass int

const (
	ApidClassHousekeeping ApidClass = 0
	ApidClassGuidance     ApidClass = 1
	ApidClassPropulsion   ApidClass = 2
	ApidClassCapture      ApidClass = 3
	ApidClassRelay        ApidClass = 4
	ApidClassImaging      ApidClass = 5
)

const ApidClassCount = 6

var ApidClassNames = [ApidClassCount]string{"housekeeping", "guidance", "propulsion", "capture", "relay", "imaging"}

// FdirLevel is TethysFdir::FdirLevel.
type FdirLevel int

const (
	FdirLevelUnit      FdirLevel = 0
	FdirLevelSubsystem FdirLevel = 1
	FdirLevelSystem    FdirLevel = 2
)

const FdirLevelCount = 3

var FdirLevelNames = [FdirLevelCount]string{"unit", "subsystem", "system"}

// FaultResponse is TethysFdir::FaultResponse.
type FaultResponse int

const (
	FaultResponseRetry       FaultResponse = 0
	FaultResponseSwitchover  FaultResponse = 1
	FaultResponseLoadShed    FaultResponse = 2
	FaultResponseSafeMode    FaultResponse = 3
	FaultResponseAbortReturn FaultResponse = 4
)

const FaultResponseCount = 5

var FaultResponseNames = [FaultResponseCount]string{"retry", "switchover", "loadShed", "safeMode", "abortReturn"}

// SoftwareLayer is TethysFlightSoftware::SoftwareLayer.
type SoftwareLayer int

const (
	SoftwareLayerBoardSupport SoftwareLayer = 0
	SoftwareLayerExecutive    SoftwareLayer = 1
	SoftwareLayerCoreService  SoftwareLayer = 2
	SoftwareLayerApplication  SoftwareLayer = 3
)

const SoftwareLayerCount = 4

var SoftwareLayerNames = [SoftwareLayerCount]string{"boardSupport", "executive", "coreService", "application"}

// SchedulingPolicy is TethysFlightSoftware::SchedulingPolicy.
type SchedulingPolicy int

const (
	SchedulingPolicyCyclicFixedWindows      SchedulingPolicy = 0
	SchedulingPolicyFixedPriorityPreemptive SchedulingPolicy = 1
)

const SchedulingPolicyCount = 2

var SchedulingPolicyNames = [SchedulingPolicyCount]string{"cyclicFixedWindows", "fixedPriorityPreemptive"}

// SoftwareCriticality is TethysFlightSoftware::SoftwareCriticality.
type SoftwareCriticality int

const (
	SoftwareCriticalitySafetyCritical  SoftwareCriticality = 0
	SoftwareCriticalityMissionCritical SoftwareCriticality = 1
	SoftwareCriticalityNonCritical     SoftwareCriticality = 2
)

const SoftwareCriticalityCount = 3

var SoftwareCriticalityNames = [SoftwareCriticalityCount]string{"safetyCritical", "missionCritical", "nonCritical"}

// ApplicationName is TethysFlightDictionary::ApplicationName.
type ApplicationName int

const (
	ApplicationNameCdh                 ApplicationName = 0
	ApplicationNameGnc                 ApplicationName = 1
	ApplicationNameSepControl          ApplicationName = 2
	ApplicationNamePowerManagement     ApplicationName = 3
	ApplicationNameThermalControl      ApplicationName = 4
	ApplicationNameTelecom             ApplicationName = 5
	ApplicationNameInspectorHandling   ApplicationName = 6
	ApplicationNameCaptureControl      ApplicationName = 7
	ApplicationNameAutonomy            ApplicationName = 8
	ApplicationNameFdir                ApplicationName = 9
	ApplicationNameModeManagement      ApplicationName = 10
	ApplicationNameParameterBootUpdate ApplicationName = 11
)

const ApplicationNameCount = 12

var ApplicationNameNames = [ApplicationNameCount]string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "captureControl", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}

// CommandCriticality is TethysFlightDictionary::CommandCriticality.
type CommandCriticality int

const (
	CommandCriticalityRoutine   CommandCriticality = 0
	CommandCriticalityCritical  CommandCriticality = 1
	CommandCriticalityHazardous CommandCriticality = 2
)

const CommandCriticalityCount = 3

var CommandCriticalityNames = [CommandCriticalityCount]string{"routine", "critical", "hazardous"}

// EventSeverity is TethysFlightDictionary::EventSeverity.
type EventSeverity int

const (
	EventSeverityInfo     EventSeverity = 0
	EventSeverityWarning  EventSeverity = 1
	EventSeverityFault    EventSeverity = 2
	EventSeverityCritical EventSeverity = 3
)

const EventSeverityCount = 4

var EventSeverityNames = [EventSeverityCount]string{"info", "warning", "fault", "critical"}

// TelemetryKind is TethysFlightDictionary::TelemetryKind.
type TelemetryKind int

const (
	TelemetryKindHousekeeping TelemetryKind = 0
	TelemetryKindEngineering  TelemetryKind = 1
)

const TelemetryKindCount = 2

var TelemetryKindNames = [TelemetryKindCount]string{"housekeeping", "engineering"}

// LoadShedTier is TethysFlightBehaviour::LoadShedTier.
type LoadShedTier int

const (
	LoadShedTierNone     LoadShedTier = 0
	LoadShedTierTierOne  LoadShedTier = 1
	LoadShedTierTierTwo  LoadShedTier = 2
	LoadShedTierSurvival LoadShedTier = 3
)

const LoadShedTierCount = 4

var LoadShedTierNames = [LoadShedTierCount]string{"none", "tierOne", "tierTwo", "survival"}

// ImageSlot is TethysFlightBehaviour::ImageSlot.
type ImageSlot int

const (
	ImageSlotPrimary ImageSlot = 0
	ImageSlotBackup  ImageSlot = 1
	ImageSlotSafe    ImageSlot = 2
)

const ImageSlotCount = 3

var ImageSlotNames = [ImageSlotCount]string{"primary", "backup", "safe"}

// BusErrorResponse is TethysSoftwareIcds::BusErrorResponse.
type BusErrorResponse int

const (
	BusErrorResponseDiscardAndCount BusErrorResponse = 0
	BusErrorResponseRequestRetry    BusErrorResponse = 1
	BusErrorResponseRaiseFault      BusErrorResponse = 2
)

const BusErrorResponseCount = 3

var BusErrorResponseNames = [BusErrorResponseCount]string{"discardAndCount", "requestRetry", "raiseFault"}

// RegisterAccess is TethysSoftwareIcds::RegisterAccess.
type RegisterAccess int

const (
	RegisterAccessReadOnly  RegisterAccess = 0
	RegisterAccessReadWrite RegisterAccess = 1
	RegisterAccessWriteOnly RegisterAccess = 2
)

const RegisterAccessCount = 3

var RegisterAccessNames = [RegisterAccessCount]string{"readOnly", "readWrite", "writeOnly"}

// Opcode is TethysFlightDictionary::Opcode.
type Opcode int

const (
	OpcodeCDH_NOOP                         Opcode = 257
	OpcodeCDH_RESET_PROCESSOR              Opcode = 258
	OpcodeCDH_SELECT_PRIME_COMPUTER        Opcode = 259
	OpcodeCDH_SET_CLOCK                    Opcode = 260
	OpcodeCDH_ADJUST_CLOCK                 Opcode = 261
	OpcodeCDH_DUMP_MEMORY                  Opcode = 262
	OpcodeCDH_LOAD_MEMORY                  Opcode = 263
	OpcodeCDH_START_RECORDING              Opcode = 264
	OpcodeCDH_STOP_RECORDING               Opcode = 265
	OpcodeCDH_DOWNLINK_FILE                Opcode = 266
	OpcodeCDH_DELETE_FILE                  Opcode = 267
	OpcodeCDH_SET_DOWNLINK_PRIORITY        Opcode = 268
	OpcodeCDH_SET_WATCHDOG_PERIOD          Opcode = 269
	OpcodeCDH_CLEAR_COUNTERS               Opcode = 270
	OpcodeCDH_SET_APP_RATE_CDH             Opcode = 271
	OpcodeCDH_SET_APP_RATE_GNC             Opcode = 272
	OpcodeCDH_SET_APP_RATE_SEP             Opcode = 273
	OpcodeCDH_SET_APP_RATE_EPS             Opcode = 274
	OpcodeCDH_SET_APP_RATE_THM             Opcode = 275
	OpcodeCDH_SET_APP_RATE_COM             Opcode = 276
	OpcodeCDH_SET_APP_RATE_INS             Opcode = 277
	OpcodeCDH_SET_APP_RATE_CAP             Opcode = 278
	OpcodeCDH_SET_APP_RATE_AUT             Opcode = 279
	OpcodeCDH_SET_APP_RATE_FDR             Opcode = 280
	OpcodeCDH_SET_APP_RATE_MOD             Opcode = 281
	OpcodeCDH_SET_APP_RATE_PBU             Opcode = 282
	OpcodeGNC_SET_ATTITUDE_TARGET          Opcode = 513
	OpcodeGNC_SET_RATE_TARGET              Opcode = 514
	OpcodeGNC_SLEW_TO                      Opcode = 515
	OpcodeGNC_HOLD_ATTITUDE                Opcode = 516
	OpcodeGNC_SELECT_STAR_TRACKER          Opcode = 517
	OpcodeGNC_SELECT_IMU                   Opcode = 518
	OpcodeGNC_DESATURATE_WHEELS            Opcode = 519
	OpcodeGNC_SET_WHEEL_SPEED              Opcode = 520
	OpcodeGNC_ENABLE_RCS_CONTROL           Opcode = 521
	OpcodeGNC_DISABLE_RCS_CONTROL          Opcode = 522
	OpcodeGNC_UPLOAD_EPHEMERIS             Opcode = 523
	OpcodeGNC_SET_GUIDANCE_MODE            Opcode = 524
	OpcodeGNC_START_TCM                    Opcode = 525
	OpcodeGNC_ABORT_TCM                    Opcode = 526
	OpcodeGNC_SET_POINTING_TOLERANCE       Opcode = 527
	OpcodeGNC_RESET_ESTIMATOR              Opcode = 528
	OpcodeGNC_RCS_THRUSTER_ENABLE_01       Opcode = 529
	OpcodeGNC_RCS_THRUSTER_DISABLE_01      Opcode = 530
	OpcodeGNC_RCS_THRUSTER_ENABLE_02       Opcode = 531
	OpcodeGNC_RCS_THRUSTER_DISABLE_02      Opcode = 532
	OpcodeGNC_RCS_THRUSTER_ENABLE_03       Opcode = 533
	OpcodeGNC_RCS_THRUSTER_DISABLE_03      Opcode = 534
	OpcodeGNC_RCS_THRUSTER_ENABLE_04       Opcode = 535
	OpcodeGNC_RCS_THRUSTER_DISABLE_04      Opcode = 536
	OpcodeGNC_RCS_THRUSTER_ENABLE_05       Opcode = 537
	OpcodeGNC_RCS_THRUSTER_DISABLE_05      Opcode = 538
	OpcodeGNC_RCS_THRUSTER_ENABLE_06       Opcode = 539
	OpcodeGNC_RCS_THRUSTER_DISABLE_06      Opcode = 540
	OpcodeGNC_RCS_THRUSTER_ENABLE_07       Opcode = 541
	OpcodeGNC_RCS_THRUSTER_DISABLE_07      Opcode = 542
	OpcodeGNC_RCS_THRUSTER_ENABLE_08       Opcode = 543
	OpcodeGNC_RCS_THRUSTER_DISABLE_08      Opcode = 544
	OpcodeGNC_WHEEL_ON_1                   Opcode = 545
	OpcodeGNC_WHEEL_OFF_1                  Opcode = 546
	OpcodeGNC_WHEEL_ON_2                   Opcode = 547
	OpcodeGNC_WHEEL_OFF_2                  Opcode = 548
	OpcodeGNC_WHEEL_ON_3                   Opcode = 549
	OpcodeGNC_WHEEL_OFF_3                  Opcode = 550
	OpcodeGNC_WHEEL_ON_4                   Opcode = 551
	OpcodeGNC_WHEEL_OFF_4                  Opcode = 552
	OpcodeSEP_START_THRUST_ARC             Opcode = 769
	OpcodeSEP_STOP_THRUST                  Opcode = 770
	OpcodeSEP_SET_THROTTLE                 Opcode = 771
	OpcodeSEP_SELECT_THRUSTER              Opcode = 772
	OpcodeSEP_PRIME_FEED                   Opcode = 773
	OpcodeSEP_VENT_FEED                    Opcode = 774
	OpcodeSEP_SET_FLOW_RATE                Opcode = 775
	OpcodeSEP_THRUSTER_RESTART             Opcode = 776
	OpcodeSEP_OPEN_LATCH_VALVE             Opcode = 777
	OpcodeSEP_CLOSE_LATCH_VALVE            Opcode = 778
	OpcodeSEP_GIMBAL_SET                   Opcode = 779
	OpcodeSEP_GIMBAL_HOME                  Opcode = 780
	OpcodeSEP_SET_DISCHARGE_LIMIT          Opcode = 781
	OpcodeSEP_TANK_HEATER_SETPOINT         Opcode = 782
	OpcodeSEP_PPU_ON_1                     Opcode = 783
	OpcodeSEP_PPU_OFF_1                    Opcode = 784
	OpcodeSEP_PPU_ON_2                     Opcode = 785
	OpcodeSEP_PPU_OFF_2                    Opcode = 786
	OpcodeSEP_PPU_ON_3                     Opcode = 787
	OpcodeSEP_PPU_OFF_3                    Opcode = 788
	OpcodeSEP_CATHODE_HEATER_ON_1          Opcode = 789
	OpcodeSEP_CATHODE_HEATER_OFF_1         Opcode = 790
	OpcodeSEP_CATHODE_HEATER_ON_2          Opcode = 791
	OpcodeSEP_CATHODE_HEATER_OFF_2         Opcode = 792
	OpcodeSEP_CATHODE_HEATER_ON_3          Opcode = 793
	OpcodeSEP_CATHODE_HEATER_OFF_3         Opcode = 794
	OpcodeEPS_SET_BATTERY_CHARGE_LIMIT     Opcode = 1025
	OpcodeEPS_SET_LOAD_SHED_LEVEL          Opcode = 1026
	OpcodeEPS_SELECT_BATTERY               Opcode = 1027
	OpcodeEPS_SADA_SET_ANGLE               Opcode = 1028
	OpcodeEPS_SADA_TRACK_SUN               Opcode = 1029
	OpcodeEPS_SADA_HOLD                    Opcode = 1030
	OpcodeEPS_SET_BUS_VOLTAGE_LIMITS       Opcode = 1031
	OpcodeEPS_BALANCE_CELLS                Opcode = 1032
	OpcodeEPS_RESET_SWITCH_TRIPS           Opcode = 1033
	OpcodeEPS_SET_ARRAY_STRING_MASK        Opcode = 1034
	OpcodeEPS_SWITCH_ON_01                 Opcode = 1035
	OpcodeEPS_SWITCH_OFF_01                Opcode = 1036
	OpcodeEPS_SWITCH_ON_02                 Opcode = 1037
	OpcodeEPS_SWITCH_OFF_02                Opcode = 1038
	OpcodeEPS_SWITCH_ON_03                 Opcode = 1039
	OpcodeEPS_SWITCH_OFF_03                Opcode = 1040
	OpcodeEPS_SWITCH_ON_04                 Opcode = 1041
	OpcodeEPS_SWITCH_OFF_04                Opcode = 1042
	OpcodeEPS_SWITCH_ON_05                 Opcode = 1043
	OpcodeEPS_SWITCH_OFF_05                Opcode = 1044
	OpcodeEPS_SWITCH_ON_06                 Opcode = 1045
	OpcodeEPS_SWITCH_OFF_06                Opcode = 1046
	OpcodeEPS_SWITCH_ON_07                 Opcode = 1047
	OpcodeEPS_SWITCH_OFF_07                Opcode = 1048
	OpcodeEPS_SWITCH_ON_08                 Opcode = 1049
	OpcodeEPS_SWITCH_OFF_08                Opcode = 1050
	OpcodeEPS_SWITCH_ON_09                 Opcode = 1051
	OpcodeEPS_SWITCH_OFF_09                Opcode = 1052
	OpcodeEPS_SWITCH_ON_10                 Opcode = 1053
	OpcodeEPS_SWITCH_OFF_10                Opcode = 1054
	OpcodeEPS_SWITCH_ON_11                 Opcode = 1055
	OpcodeEPS_SWITCH_OFF_11                Opcode = 1056
	OpcodeEPS_SWITCH_ON_12                 Opcode = 1057
	OpcodeEPS_SWITCH_OFF_12                Opcode = 1058
	OpcodeEPS_SWITCH_ON_13                 Opcode = 1059
	OpcodeEPS_SWITCH_OFF_13                Opcode = 1060
	OpcodeEPS_SWITCH_ON_14                 Opcode = 1061
	OpcodeEPS_SWITCH_OFF_14                Opcode = 1062
	OpcodeEPS_SWITCH_ON_15                 Opcode = 1063
	OpcodeEPS_SWITCH_OFF_15                Opcode = 1064
	OpcodeEPS_SWITCH_ON_16                 Opcode = 1065
	OpcodeEPS_SWITCH_OFF_16                Opcode = 1066
	OpcodeEPS_SWITCH_ON_17                 Opcode = 1067
	OpcodeEPS_SWITCH_OFF_17                Opcode = 1068
	OpcodeEPS_SWITCH_ON_18                 Opcode = 1069
	OpcodeEPS_SWITCH_OFF_18                Opcode = 1070
	OpcodeEPS_SWITCH_ON_19                 Opcode = 1071
	OpcodeEPS_SWITCH_OFF_19                Opcode = 1072
	OpcodeEPS_SWITCH_ON_20                 Opcode = 1073
	OpcodeEPS_SWITCH_OFF_20                Opcode = 1074
	OpcodeEPS_SWITCH_ON_21                 Opcode = 1075
	OpcodeEPS_SWITCH_OFF_21                Opcode = 1076
	OpcodeEPS_SWITCH_ON_22                 Opcode = 1077
	OpcodeEPS_SWITCH_OFF_22                Opcode = 1078
	OpcodeEPS_SWITCH_ON_23                 Opcode = 1079
	OpcodeEPS_SWITCH_OFF_23                Opcode = 1080
	OpcodeEPS_SWITCH_ON_24                 Opcode = 1081
	OpcodeEPS_SWITCH_OFF_24                Opcode = 1082
	OpcodeTHM_SET_CONTROL_MODE             Opcode = 1281
	OpcodeTHM_LOUVER_SET                   Opcode = 1282
	OpcodeTHM_LOUVER_AUTO                  Opcode = 1283
	OpcodeTHM_SET_SURVIVAL_SETPOINTS       Opcode = 1284
	OpcodeTHM_SET_DEADBAND                 Opcode = 1285
	OpcodeTHM_ENABLE_ALL_HEATERS           Opcode = 1286
	OpcodeTHM_DISABLE_ALL_HEATERS          Opcode = 1287
	OpcodeTHM_SET_HEATER_POWER_CAP         Opcode = 1288
	OpcodeTHM_HEATER_ENABLE_01             Opcode = 1289
	OpcodeTHM_HEATER_DISABLE_01            Opcode = 1290
	OpcodeTHM_HEATER_ENABLE_02             Opcode = 1291
	OpcodeTHM_HEATER_DISABLE_02            Opcode = 1292
	OpcodeTHM_HEATER_ENABLE_03             Opcode = 1293
	OpcodeTHM_HEATER_DISABLE_03            Opcode = 1294
	OpcodeTHM_HEATER_ENABLE_04             Opcode = 1295
	OpcodeTHM_HEATER_DISABLE_04            Opcode = 1296
	OpcodeTHM_HEATER_ENABLE_05             Opcode = 1297
	OpcodeTHM_HEATER_DISABLE_05            Opcode = 1298
	OpcodeTHM_HEATER_ENABLE_06             Opcode = 1299
	OpcodeTHM_HEATER_DISABLE_06            Opcode = 1300
	OpcodeTHM_HEATER_ENABLE_07             Opcode = 1301
	OpcodeTHM_HEATER_DISABLE_07            Opcode = 1302
	OpcodeTHM_HEATER_ENABLE_08             Opcode = 1303
	OpcodeTHM_HEATER_DISABLE_08            Opcode = 1304
	OpcodeTHM_HEATER_ENABLE_09             Opcode = 1305
	OpcodeTHM_HEATER_DISABLE_09            Opcode = 1306
	OpcodeTHM_HEATER_ENABLE_10             Opcode = 1307
	OpcodeTHM_HEATER_DISABLE_10            Opcode = 1308
	OpcodeTHM_HEATER_ENABLE_11             Opcode = 1309
	OpcodeTHM_HEATER_DISABLE_11            Opcode = 1310
	OpcodeTHM_HEATER_ENABLE_12             Opcode = 1311
	OpcodeTHM_HEATER_DISABLE_12            Opcode = 1312
	OpcodeTHM_HEATER_ENABLE_13             Opcode = 1313
	OpcodeTHM_HEATER_DISABLE_13            Opcode = 1314
	OpcodeTHM_HEATER_ENABLE_14             Opcode = 1315
	OpcodeTHM_HEATER_DISABLE_14            Opcode = 1316
	OpcodeTHM_HEATER_ENABLE_15             Opcode = 1317
	OpcodeTHM_HEATER_DISABLE_15            Opcode = 1318
	OpcodeTHM_HEATER_ENABLE_16             Opcode = 1319
	OpcodeTHM_HEATER_DISABLE_16            Opcode = 1320
	OpcodeTHM_HEATER_SETPOINT_01           Opcode = 1321
	OpcodeTHM_HEATER_SETPOINT_02           Opcode = 1322
	OpcodeTHM_HEATER_SETPOINT_03           Opcode = 1323
	OpcodeTHM_HEATER_SETPOINT_04           Opcode = 1324
	OpcodeTHM_HEATER_SETPOINT_05           Opcode = 1325
	OpcodeTHM_HEATER_SETPOINT_06           Opcode = 1326
	OpcodeTHM_HEATER_SETPOINT_07           Opcode = 1327
	OpcodeTHM_HEATER_SETPOINT_08           Opcode = 1328
	OpcodeTHM_HEATER_SETPOINT_09           Opcode = 1329
	OpcodeTHM_HEATER_SETPOINT_10           Opcode = 1330
	OpcodeTHM_HEATER_SETPOINT_11           Opcode = 1331
	OpcodeTHM_HEATER_SETPOINT_12           Opcode = 1332
	OpcodeTHM_HEATER_SETPOINT_13           Opcode = 1333
	OpcodeTHM_HEATER_SETPOINT_14           Opcode = 1334
	OpcodeTHM_HEATER_SETPOINT_15           Opcode = 1335
	OpcodeTHM_HEATER_SETPOINT_16           Opcode = 1336
	OpcodeCOM_TRANSMITTER_ON               Opcode = 1537
	OpcodeCOM_TRANSMITTER_OFF              Opcode = 1538
	OpcodeCOM_SELECT_TRANSPONDER           Opcode = 1539
	OpcodeCOM_SELECT_ANTENNA               Opcode = 1540
	OpcodeCOM_SET_DOWNLINK_RATE            Opcode = 1541
	OpcodeCOM_SET_UPLINK_RATE              Opcode = 1542
	OpcodeCOM_RANGING_ON                   Opcode = 1543
	OpcodeCOM_RANGING_OFF                  Opcode = 1544
	OpcodeCOM_HGA_POINT                    Opcode = 1545
	OpcodeCOM_HGA_TRACK_EARTH              Opcode = 1546
	OpcodeCOM_HGA_STOW                     Opcode = 1547
	OpcodeCOM_SET_PASS_WINDOW              Opcode = 1548
	OpcodeCOM_SET_CODING                   Opcode = 1549
	OpcodeCOM_SET_TRANSMIT_POWER           Opcode = 1550
	OpcodeCOM_DOWNLINK_RATE_PRESET_1       Opcode = 1551
	OpcodeCOM_DOWNLINK_RATE_PRESET_2       Opcode = 1552
	OpcodeCOM_DOWNLINK_RATE_PRESET_3       Opcode = 1553
	OpcodeCOM_DOWNLINK_RATE_PRESET_4       Opcode = 1554
	OpcodeCOM_DOWNLINK_RATE_PRESET_5       Opcode = 1555
	OpcodeCOM_DOWNLINK_RATE_PRESET_6       Opcode = 1556
	OpcodeINS_ARM_RELEASE                  Opcode = 1793
	OpcodeINS_SAFE_RELEASE                 Opcode = 1794
	OpcodeINS_RELEASE_INSPECTOR            Opcode = 1795
	OpcodeINS_FORWARD_COMMAND              Opcode = 1796
	OpcodeINS_START_IMAGING_SESSION        Opcode = 1797
	OpcodeINS_STOP_IMAGING_SESSION         Opcode = 1798
	OpcodeINS_SET_IMAGE_COMPRESSION        Opcode = 1799
	OpcodeINS_SELECT_RELAY_RATE            Opcode = 1800
	OpcodeINS_STORE_IMAGE_SEGMENT          Opcode = 1801
	OpcodeINS_DOWNLINK_IMAGE               Opcode = 1802
	OpcodeINS_RETIRE_INSPECTOR             Opcode = 1803
	OpcodeINS_SET_RELAY_WINDOW             Opcode = 1804
	OpcodeINS_ENABLE_RELAY                 Opcode = 1805
	OpcodeINS_DISABLE_RELAY                Opcode = 1806
	OpcodeCAP_ARM_CAPTURE                  Opcode = 2049
	OpcodeCAP_DISARM_CAPTURE               Opcode = 2050
	OpcodeCAP_DEPLOY_BAG                   Opcode = 2051
	OpcodeCAP_CLOSE_BAG                    Opcode = 2052
	OpcodeCAP_CINCH_BAG                    Opcode = 2053
	OpcodeCAP_START_DESPIN                 Opcode = 2054
	OpcodeCAP_STOP_DESPIN                  Opcode = 2055
	OpcodeCAP_SET_DESPIN_TORQUE            Opcode = 2056
	OpcodeCAP_LATCH_BODY                   Opcode = 2057
	OpcodeCAP_RELEASE_BODY                 Opcode = 2058
	OpcodeCAP_ABORT_CAPTURE                Opcode = 2059
	OpcodeCAP_SET_APPROACH_RATE            Opcode = 2060
	OpcodeCAP_ENABLE_PROXIMITY_SENSORS     Opcode = 2061
	OpcodeCAP_DISABLE_PROXIMITY_SENSORS    Opcode = 2062
	OpcodeCAP_SET_CONTACT_FORCE_LIMIT      Opcode = 2063
	OpcodeCAP_SET_BODY_MASS_ESTIMATE       Opcode = 2064
	OpcodeCAP_PETAL_OPEN_1                 Opcode = 2065
	OpcodeCAP_PETAL_CLOSE_1                Opcode = 2066
	OpcodeCAP_PETAL_OPEN_2                 Opcode = 2067
	OpcodeCAP_PETAL_CLOSE_2                Opcode = 2068
	OpcodeCAP_PETAL_OPEN_3                 Opcode = 2069
	OpcodeCAP_PETAL_CLOSE_3                Opcode = 2070
	OpcodeCAP_PETAL_OPEN_4                 Opcode = 2071
	OpcodeCAP_PETAL_CLOSE_4                Opcode = 2072
	OpcodeAUT_LOAD_SEQUENCE                Opcode = 2305
	OpcodeAUT_START_SEQUENCE               Opcode = 2306
	OpcodeAUT_STOP_SEQUENCE                Opcode = 2307
	OpcodeAUT_PAUSE_SEQUENCE               Opcode = 2308
	OpcodeAUT_RESUME_SEQUENCE              Opcode = 2309
	OpcodeAUT_SET_SEQUENCE_PARAMETER       Opcode = 2310
	OpcodeAUT_ENABLE_AUTONOMY              Opcode = 2311
	OpcodeAUT_DISABLE_AUTONOMY             Opcode = 2312
	OpcodeAUT_SET_RULE_ENABLE              Opcode = 2313
	OpcodeAUT_CLEAR_RULE_HISTORY           Opcode = 2314
	OpcodeAUT_SET_WAYPOINT                 Opcode = 2315
	OpcodeAUT_CLEAR_WAYPOINTS              Opcode = 2316
	OpcodeAUT_SET_PLAN_HORIZON             Opcode = 2317
	OpcodeAUT_ENGINE_ENABLE_1              Opcode = 2318
	OpcodeAUT_ENGINE_DISABLE_1             Opcode = 2319
	OpcodeAUT_ENGINE_ENABLE_2              Opcode = 2320
	OpcodeAUT_ENGINE_DISABLE_2             Opcode = 2321
	OpcodeAUT_ENGINE_ENABLE_3              Opcode = 2322
	OpcodeAUT_ENGINE_DISABLE_3             Opcode = 2323
	OpcodeAUT_ENGINE_ENABLE_4              Opcode = 2324
	OpcodeAUT_ENGINE_DISABLE_4             Opcode = 2325
	OpcodeFDR_ENABLE_MONITOR               Opcode = 2561
	OpcodeFDR_DISABLE_MONITOR              Opcode = 2562
	OpcodeFDR_SET_LIMIT                    Opcode = 2563
	OpcodeFDR_RESET_LIMIT                  Opcode = 2564
	OpcodeFDR_CLEAR_FAULT                  Opcode = 2565
	OpcodeFDR_ACKNOWLEDGE_FAULT            Opcode = 2566
	OpcodeFDR_MASK_RESPONSE                Opcode = 2567
	OpcodeFDR_UNMASK_RESPONSE              Opcode = 2568
	OpcodeFDR_FORCE_SAFE_MODE              Opcode = 2569
	OpcodeFDR_SET_COMMAND_LOSS_TIMER       Opcode = 2570
	OpcodeFDR_RESET_COMMAND_LOSS_TIMER     Opcode = 2571
	OpcodeFDR_ABORT_TO_RETREAT             Opcode = 2572
	OpcodeFDR_SET_FLAMEOUT_RETRIES         Opcode = 2573
	OpcodeFDR_SET_BATTERY_LOW_FRACTION     Opcode = 2574
	OpcodeFDR_SET_IMPACT_PROBABILITY_LIMIT Opcode = 2575
	OpcodeFDR_SET_EXCLUSION_RADIUS         Opcode = 2576
	OpcodeFDR_MONITOR_RESPONSE_01          Opcode = 2577
	OpcodeFDR_MONITOR_RESPONSE_02          Opcode = 2578
	OpcodeFDR_MONITOR_RESPONSE_03          Opcode = 2579
	OpcodeFDR_MONITOR_RESPONSE_04          Opcode = 2580
	OpcodeFDR_MONITOR_RESPONSE_05          Opcode = 2581
	OpcodeFDR_MONITOR_RESPONSE_06          Opcode = 2582
	OpcodeFDR_MONITOR_RESPONSE_07          Opcode = 2583
	OpcodeFDR_MONITOR_RESPONSE_08          Opcode = 2584
	OpcodeFDR_MONITOR_RESPONSE_09          Opcode = 2585
	OpcodeFDR_MONITOR_RESPONSE_10          Opcode = 2586
	OpcodeFDR_MONITOR_RESPONSE_11          Opcode = 2587
	OpcodeFDR_MONITOR_RESPONSE_12          Opcode = 2588
	OpcodeMOD_SET_MODE                     Opcode = 2817
	OpcodeMOD_CONFIRM_MODE                 Opcode = 2818
	OpcodeMOD_CANCEL_PENDING_MODE          Opcode = 2819
	OpcodeMOD_LOAD_MODE_TABLE              Opcode = 2820
	OpcodeMOD_ENABLE_AUTO_TRANSITION       Opcode = 2821
	OpcodeMOD_DISABLE_AUTO_TRANSITION      Opcode = 2822
	OpcodeMOD_HOLD_MODE                    Opcode = 2823
	OpcodeMOD_RESUME_MODE                  Opcode = 2824
	OpcodeMOD_SET_TRANSITION_TIMEOUT       Opcode = 2825
	OpcodePBU_LOAD_TABLE                   Opcode = 3073
	OpcodePBU_DUMP_TABLE                   Opcode = 3074
	OpcodePBU_ACTIVATE_TABLE               Opcode = 3075
	OpcodePBU_VERIFY_TABLE                 Opcode = 3076
	OpcodePBU_SET_PARAMETER                Opcode = 3077
	OpcodePBU_GET_PARAMETER                Opcode = 3078
	OpcodePBU_START_BOOT_UPDATE            Opcode = 3079
	OpcodePBU_ABORT_BOOT_UPDATE            Opcode = 3080
	OpcodePBU_SELECT_BOOT_IMAGE            Opcode = 3081
	OpcodePBU_COMMIT_BOOT_IMAGE            Opcode = 3082
	OpcodePBU_TABLE_RESET_01               Opcode = 3083
	OpcodePBU_TABLE_RESET_02               Opcode = 3084
	OpcodePBU_TABLE_RESET_03               Opcode = 3085
	OpcodePBU_TABLE_RESET_04               Opcode = 3086
	OpcodePBU_TABLE_RESET_05               Opcode = 3087
	OpcodePBU_TABLE_RESET_06               Opcode = 3088
	OpcodePBU_TABLE_RESET_07               Opcode = 3089
	OpcodePBU_TABLE_RESET_08               Opcode = 3090
	OpcodePBU_TABLE_RESET_09               Opcode = 3091
	OpcodePBU_TABLE_RESET_10               Opcode = 3092
	OpcodePBU_TABLE_RESET_11               Opcode = 3093
	OpcodePBU_TABLE_RESET_12               Opcode = 3094
)

const OpcodeCount = 344

// EventId is TethysFlightDictionary::EventDefinition::eventId.
type EventId int

const (
	EventIdCDH_EVT_STARTED                 EventId = 101
	EventIdCDH_EVT_STOPPED                 EventId = 102
	EventIdCDH_EVT_CMD_ACCEPTED            EventId = 103
	EventIdCDH_EVT_CMD_REJECTED            EventId = 104
	EventIdCDH_EVT_TABLE_LOADED            EventId = 105
	EventIdCDH_EVT_TABLE_INVALID           EventId = 106
	EventIdCDH_EVT_WATCHDOG_MISSED         EventId = 107
	EventIdCDH_EVT_MODE_CHANGE_SEEN        EventId = 108
	EventIdCDH_EVT_PROCESSOR_RESET         EventId = 109
	EventIdCDH_EVT_PRIME_SWITCHED          EventId = 110
	EventIdCDH_EVT_CLOCK_SET               EventId = 111
	EventIdCDH_EVT_RECORDER_FULL           EventId = 112
	EventIdCDH_EVT_FILE_DOWNLINKED         EventId = 113
	EventIdCDH_EVT_MEMORY_SCRUB_ERROR      EventId = 114
	EventIdGNC_EVT_STARTED                 EventId = 201
	EventIdGNC_EVT_STOPPED                 EventId = 202
	EventIdGNC_EVT_CMD_ACCEPTED            EventId = 203
	EventIdGNC_EVT_CMD_REJECTED            EventId = 204
	EventIdGNC_EVT_TABLE_LOADED            EventId = 205
	EventIdGNC_EVT_TABLE_INVALID           EventId = 206
	EventIdGNC_EVT_WATCHDOG_MISSED         EventId = 207
	EventIdGNC_EVT_MODE_CHANGE_SEEN        EventId = 208
	EventIdGNC_EVT_SLEW_COMPLETE           EventId = 209
	EventIdGNC_EVT_STAR_TRACKER_LOST       EventId = 210
	EventIdGNC_EVT_IMU_FAULT               EventId = 211
	EventIdGNC_EVT_WHEEL_SATURATION        EventId = 212
	EventIdGNC_EVT_DESAT_COMPLETE          EventId = 213
	EventIdGNC_EVT_TCM_COMPLETE            EventId = 214
	EventIdGNC_EVT_ESTIMATOR_DIVERGED      EventId = 215
	EventIdGNC_EVT_EPHEMERIS_STALE         EventId = 216
	EventIdSEP_EVT_STARTED                 EventId = 301
	EventIdSEP_EVT_STOPPED                 EventId = 302
	EventIdSEP_EVT_CMD_ACCEPTED            EventId = 303
	EventIdSEP_EVT_CMD_REJECTED            EventId = 304
	EventIdSEP_EVT_TABLE_LOADED            EventId = 305
	EventIdSEP_EVT_TABLE_INVALID           EventId = 306
	EventIdSEP_EVT_WATCHDOG_MISSED         EventId = 307
	EventIdSEP_EVT_MODE_CHANGE_SEEN        EventId = 308
	EventIdSEP_EVT_ARC_STARTED             EventId = 309
	EventIdSEP_EVT_ARC_COMPLETE            EventId = 310
	EventIdSEP_EVT_FLAMEOUT                EventId = 311
	EventIdSEP_EVT_RESTART_OK              EventId = 312
	EventIdSEP_EVT_RESTART_FAILED          EventId = 313
	EventIdSEP_EVT_TANK_LOW                EventId = 314
	EventIdSEP_EVT_PPU_OVERCURRENT         EventId = 315
	EventIdSEP_EVT_GIMBAL_STALL            EventId = 316
	EventIdEPS_EVT_STARTED                 EventId = 401
	EventIdEPS_EVT_STOPPED                 EventId = 402
	EventIdEPS_EVT_CMD_ACCEPTED            EventId = 403
	EventIdEPS_EVT_CMD_REJECTED            EventId = 404
	EventIdEPS_EVT_TABLE_LOADED            EventId = 405
	EventIdEPS_EVT_TABLE_INVALID           EventId = 406
	EventIdEPS_EVT_WATCHDOG_MISSED         EventId = 407
	EventIdEPS_EVT_MODE_CHANGE_SEEN        EventId = 408
	EventIdEPS_EVT_LOAD_SHED               EventId = 409
	EventIdEPS_EVT_BATTERY_LOW             EventId = 410
	EventIdEPS_EVT_BUS_UNDERVOLTAGE        EventId = 411
	EventIdEPS_EVT_SWITCH_TRIP             EventId = 412
	EventIdEPS_EVT_ARRAY_STRING_LOST       EventId = 413
	EventIdEPS_EVT_SADA_STALL              EventId = 414
	EventIdEPS_EVT_CHARGE_COMPLETE         EventId = 415
	EventIdTHM_EVT_STARTED                 EventId = 501
	EventIdTHM_EVT_STOPPED                 EventId = 502
	EventIdTHM_EVT_CMD_ACCEPTED            EventId = 503
	EventIdTHM_EVT_CMD_REJECTED            EventId = 504
	EventIdTHM_EVT_TABLE_LOADED            EventId = 505
	EventIdTHM_EVT_TABLE_INVALID           EventId = 506
	EventIdTHM_EVT_WATCHDOG_MISSED         EventId = 507
	EventIdTHM_EVT_MODE_CHANGE_SEEN        EventId = 508
	EventIdTHM_EVT_ZONE_COLD               EventId = 509
	EventIdTHM_EVT_ZONE_HOT                EventId = 510
	EventIdTHM_EVT_ZONE_RED                EventId = 511
	EventIdTHM_EVT_HEATER_FAILED           EventId = 512
	EventIdTHM_EVT_SURVIVAL_ACTIVE         EventId = 513
	EventIdTHM_EVT_POWER_CAP_HIT           EventId = 514
	EventIdCOM_EVT_STARTED                 EventId = 601
	EventIdCOM_EVT_STOPPED                 EventId = 602
	EventIdCOM_EVT_CMD_ACCEPTED            EventId = 603
	EventIdCOM_EVT_CMD_REJECTED            EventId = 604
	EventIdCOM_EVT_TABLE_LOADED            EventId = 605
	EventIdCOM_EVT_TABLE_INVALID           EventId = 606
	EventIdCOM_EVT_WATCHDOG_MISSED         EventId = 607
	EventIdCOM_EVT_MODE_CHANGE_SEEN        EventId = 608
	EventIdCOM_EVT_CARRIER_ACQUIRED        EventId = 609
	EventIdCOM_EVT_CARRIER_LOST            EventId = 610
	EventIdCOM_EVT_PASS_START              EventId = 611
	EventIdCOM_EVT_PASS_END                EventId = 612
	EventIdCOM_EVT_TX_OVERTEMP             EventId = 613
	EventIdCOM_EVT_HGA_POINTING_ERROR      EventId = 614
	EventIdCOM_EVT_RELAY_ACQUIRED          EventId = 615
	EventIdCOM_EVT_RELAY_LOST              EventId = 616
	EventIdINS_EVT_STARTED                 EventId = 701
	EventIdINS_EVT_STOPPED                 EventId = 702
	EventIdINS_EVT_CMD_ACCEPTED            EventId = 703
	EventIdINS_EVT_CMD_REJECTED            EventId = 704
	EventIdINS_EVT_TABLE_LOADED            EventId = 705
	EventIdINS_EVT_TABLE_INVALID           EventId = 706
	EventIdINS_EVT_WATCHDOG_MISSED         EventId = 707
	EventIdINS_EVT_MODE_CHANGE_SEEN        EventId = 708
	EventIdINS_EVT_RELEASE_ARMED           EventId = 709
	EventIdINS_EVT_RELEASED                EventId = 710
	EventIdINS_EVT_IMAGE_RECEIVED          EventId = 711
	EventIdINS_EVT_SEGMENT_LOST            EventId = 712
	EventIdINS_EVT_INSPECTOR_SAFE          EventId = 713
	EventIdINS_EVT_INSPECTOR_RETIRED       EventId = 714
	EventIdINS_EVT_CONTACT_LOST            EventId = 715
	EventIdCAP_EVT_STARTED                 EventId = 801
	EventIdCAP_EVT_STOPPED                 EventId = 802
	EventIdCAP_EVT_CMD_ACCEPTED            EventId = 803
	EventIdCAP_EVT_CMD_REJECTED            EventId = 804
	EventIdCAP_EVT_TABLE_LOADED            EventId = 805
	EventIdCAP_EVT_TABLE_INVALID           EventId = 806
	EventIdCAP_EVT_WATCHDOG_MISSED         EventId = 807
	EventIdCAP_EVT_MODE_CHANGE_SEEN        EventId = 808
	EventIdCAP_EVT_CAPTURE_ARMED           EventId = 809
	EventIdCAP_EVT_BAG_DEPLOYED            EventId = 810
	EventIdCAP_EVT_BAG_CLOSED              EventId = 811
	EventIdCAP_EVT_CONTACT                 EventId = 812
	EventIdCAP_EVT_CONTACT_FORCE_HIGH      EventId = 813
	EventIdCAP_EVT_DESPIN_COMPLETE         EventId = 814
	EventIdCAP_EVT_LATCHED                 EventId = 815
	EventIdCAP_EVT_CAPTURE_ABORTED         EventId = 816
	EventIdCAP_EVT_PETAL_STALL             EventId = 817
	EventIdCAP_EVT_PROXIMITY_SENSOR_FAULT  EventId = 818
	EventIdAUT_EVT_STARTED                 EventId = 901
	EventIdAUT_EVT_STOPPED                 EventId = 902
	EventIdAUT_EVT_CMD_ACCEPTED            EventId = 903
	EventIdAUT_EVT_CMD_REJECTED            EventId = 904
	EventIdAUT_EVT_TABLE_LOADED            EventId = 905
	EventIdAUT_EVT_TABLE_INVALID           EventId = 906
	EventIdAUT_EVT_WATCHDOG_MISSED         EventId = 907
	EventIdAUT_EVT_MODE_CHANGE_SEEN        EventId = 908
	EventIdAUT_EVT_SEQUENCE_STARTED        EventId = 909
	EventIdAUT_EVT_SEQUENCE_COMPLETE       EventId = 910
	EventIdAUT_EVT_SEQUENCE_FAILED         EventId = 911
	EventIdAUT_EVT_RULE_FIRED              EventId = 912
	EventIdAUT_EVT_WAYPOINT_REACHED        EventId = 913
	EventIdAUT_EVT_PLAN_INFEASIBLE         EventId = 914
	EventIdFDR_EVT_STARTED                 EventId = 1001
	EventIdFDR_EVT_STOPPED                 EventId = 1002
	EventIdFDR_EVT_CMD_ACCEPTED            EventId = 1003
	EventIdFDR_EVT_CMD_REJECTED            EventId = 1004
	EventIdFDR_EVT_TABLE_LOADED            EventId = 1005
	EventIdFDR_EVT_TABLE_INVALID           EventId = 1006
	EventIdFDR_EVT_WATCHDOG_MISSED         EventId = 1007
	EventIdFDR_EVT_MODE_CHANGE_SEEN        EventId = 1008
	EventIdFDR_EVT_MONITOR_TRIP            EventId = 1009
	EventIdFDR_EVT_RESPONSE_TAKEN          EventId = 1010
	EventIdFDR_EVT_SAFE_MODE_ENTERED       EventId = 1011
	EventIdFDR_EVT_COMMAND_LOSS            EventId = 1012
	EventIdFDR_EVT_ABORT_RETREAT           EventId = 1013
	EventIdFDR_EVT_FAULT_CLEARED           EventId = 1014
	EventIdFDR_EVT_IMPACT_PROBABILITY_HIGH EventId = 1015
	EventIdFDR_EVT_EXCLUSION_VIOLATION     EventId = 1016
	EventIdMOD_EVT_STARTED                 EventId = 1101
	EventIdMOD_EVT_STOPPED                 EventId = 1102
	EventIdMOD_EVT_CMD_ACCEPTED            EventId = 1103
	EventIdMOD_EVT_CMD_REJECTED            EventId = 1104
	EventIdMOD_EVT_TABLE_LOADED            EventId = 1105
	EventIdMOD_EVT_TABLE_INVALID           EventId = 1106
	EventIdMOD_EVT_WATCHDOG_MISSED         EventId = 1107
	EventIdMOD_EVT_MODE_CHANGE_SEEN        EventId = 1108
	EventIdMOD_EVT_MODE_ENTERED            EventId = 1109
	EventIdMOD_EVT_MODE_PENDING            EventId = 1110
	EventIdMOD_EVT_MODE_REJECTED           EventId = 1111
	EventIdMOD_EVT_TRANSITION_TIMEOUT      EventId = 1112
	EventIdMOD_EVT_AUTO_TRANSITION         EventId = 1113
	EventIdPBU_EVT_STARTED                 EventId = 1201
	EventIdPBU_EVT_STOPPED                 EventId = 1202
	EventIdPBU_EVT_CMD_ACCEPTED            EventId = 1203
	EventIdPBU_EVT_CMD_REJECTED            EventId = 1204
	EventIdPBU_EVT_TABLE_LOADED            EventId = 1205
	EventIdPBU_EVT_TABLE_INVALID           EventId = 1206
	EventIdPBU_EVT_WATCHDOG_MISSED         EventId = 1207
	EventIdPBU_EVT_MODE_CHANGE_SEEN        EventId = 1208
	EventIdPBU_EVT_TABLE_ACTIVATED         EventId = 1209
	EventIdPBU_EVT_TABLE_CRC_MISMATCH      EventId = 1210
	EventIdPBU_EVT_BOOT_UPDATE_STARTED     EventId = 1211
	EventIdPBU_EVT_BOOT_UPDATE_COMPLETE    EventId = 1212
	EventIdPBU_EVT_BOOT_FALLBACK           EventId = 1213
	EventIdPBU_EVT_PARAMETER_REJECTED      EventId = 1214
)

const EventIdCount = 181

// ParameterId is TethysFlightDictionary::ParameterRow::parameterId.
type ParameterId int

const (
	ParameterIdCDH_WATCHDOG_PERIOD                       ParameterId = 1
	ParameterIdCDH_RECORDER_HIGH_WATER                   ParameterId = 2
	ParameterIdCDH_CLOCK_SLEW_LIMIT                      ParameterId = 3
	ParameterIdCDH_DOWNLINK_QUEUE_DEPTH                  ParameterId = 4
	ParameterIdGNC_SLEW_RATE_LIMIT                       ParameterId = 5
	ParameterIdGNC_POINTING_TOLERANCE                    ParameterId = 6
	ParameterIdGNC_WHEEL_SPEED_LIMIT                     ParameterId = 7
	ParameterIdGNC_DESAT_THRESHOLD                       ParameterId = 8
	ParameterIdSEP_CONTROL_THROTTLE_MINIMUM              ParameterId = 9
	ParameterIdSEP_CONTROL_RESTART_DELAY                 ParameterId = 10
	ParameterIdSEP_CONTROL_DISCHARGE_TRIP                ParameterId = 11
	ParameterIdSEP_CONTROL_TANK_HEATER_SETPOINT          ParameterId = 12
	ParameterIdPOWER_MANAGEMENT_END_OF_CHARGE_VOLTAGE    ParameterId = 13
	ParameterIdPOWER_MANAGEMENT_BUS_LOW_TRIP             ParameterId = 14
	ParameterIdPOWER_MANAGEMENT_BUS_HIGH_TRIP            ParameterId = 15
	ParameterIdPOWER_MANAGEMENT_LOAD_SHED_SOC            ParameterId = 16
	ParameterIdTHERMAL_CONTROL_DEADBAND                  ParameterId = 17
	ParameterIdTHERMAL_CONTROL_SURVIVAL_LOW              ParameterId = 18
	ParameterIdTHERMAL_CONTROL_SURVIVAL_HIGH             ParameterId = 19
	ParameterIdTHERMAL_CONTROL_HEATER_POWER_CAP          ParameterId = 20
	ParameterIdTELECOM_DEFAULT_DOWNLINK_RATE             ParameterId = 21
	ParameterIdTELECOM_DEFAULT_UPLINK_RATE               ParameterId = 22
	ParameterIdTELECOM_HGA_SLEW_LIMIT                    ParameterId = 23
	ParameterIdTELECOM_TRANSMIT_POWER                    ParameterId = 24
	ParameterIdINSPECTOR_HANDLING_RELEASE_SPEED          ParameterId = 25
	ParameterIdINSPECTOR_HANDLING_IMAGING_CADENCE        ParameterId = 26
	ParameterIdINSPECTOR_HANDLING_RELAY_RATE             ParameterId = 27
	ParameterIdINSPECTOR_HANDLING_CONTACT_TIMEOUT        ParameterId = 28
	ParameterIdCAPTURE_CONTROL_APPROACH_RATE_LIMIT       ParameterId = 29
	ParameterIdCAPTURE_CONTROL_CONTACT_FORCE_LIMIT       ParameterId = 30
	ParameterIdCAPTURE_CONTROL_CINCH_TENSION             ParameterId = 31
	ParameterIdCAPTURE_CONTROL_DESPIN_TORQUE_LIMIT       ParameterId = 32
	ParameterIdAUTONOMY_PLAN_HORIZON                     ParameterId = 33
	ParameterIdAUTONOMY_AUTONOMY_LEVEL                   ParameterId = 34
	ParameterIdAUTONOMY_WAYPOINT_HOLD_DEFAULT            ParameterId = 35
	ParameterIdAUTONOMY_RULE_COOLDOWN                    ParameterId = 36
	ParameterIdFDIR_COMMAND_LOSS_TIMEOUT                 ParameterId = 37
	ParameterIdFDIR_FLAMEOUT_RETRIES                     ParameterId = 38
	ParameterIdFDIR_BATTERY_LOW_FRACTION                 ParameterId = 39
	ParameterIdFDIR_IMPACT_PROBABILITY_LIMIT             ParameterId = 40
	ParameterIdMODE_MANAGEMENT_TRANSITION_TIMEOUT        ParameterId = 41
	ParameterIdMODE_MANAGEMENT_TWO_STEP_WINDOW           ParameterId = 42
	ParameterIdMODE_MANAGEMENT_MODE_TABLE_ID             ParameterId = 43
	ParameterIdMODE_MANAGEMENT_AUTO_TRANSITION_DEFAULT   ParameterId = 44
	ParameterIdPARAMETER_BOOT_UPDATE_STAGING_BUFFER_SIZE ParameterId = 45
	ParameterIdPARAMETER_BOOT_UPDATE_BOOT_RETRY_LIMIT    ParameterId = 46
	ParameterIdPARAMETER_BOOT_UPDATE_EEPROM_CYCLE_LIMIT  ParameterId = 47
	ParameterIdPARAMETER_BOOT_UPDATE_TABLE_COUNT         ParameterId = 48
)

const ParameterIdCount = 48

// ModeMaskOf is the mask of the named modes.
func ModeMaskOf(active []string) ModeMask {
	var m ModeMask
	for _, a := range active {
		for k, n := range TugModeNames {
			if n == a {
				m |= ModeBit(TugMode(k))
			}
		}
	}
	return m
}
