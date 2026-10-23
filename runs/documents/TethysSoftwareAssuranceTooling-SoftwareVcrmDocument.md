# Argent flight software and Meridian verification cross-reference matrix

Every software verification case with its level, test bed, as-run verdict and evidence, the system requirements it verifies and the software functions it exercises. Planned cases have not run.

*Verification cross-reference matrix*

| name | SoftwareVerification::level | SoftwareVerification::testBed | SoftwareVerification::verdict | SoftwareVerification::evidence | Verification::method | verifies | rows |
| --- | --- | --- | --- | --- | --- | --- | --- |
| relativeStateUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| relativeStateDynamics | integration | dynamicsSimulator | planned | not yet run | test |  | 0 |
| finalTargetingUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| finalTargetingFlightSoftwareInTheLoop | flightSoftwareInTheLoop | trajectoryTool | pass | software/conformance/evidence/finalTargetingFlightSoftwareInTheLoop.txt | test |  | 0 |
| finalTargetingModel | modelInTheLoop | executable model | pass | fdir-earth-impact-aborted, fdir-earth-impact-abort-hold pinned runs | analyze |  | 0 |
| captureAbortUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| captureAbortFlatsat | flatsat | flatsat | planned | not yet run | test |  | 0 |
| captureAbortModel | modelInTheLoop | executable model | pass | sw-autonomy-engine pinned run: storedSequences 1 to 6 | analyze |  | 0 |
| commandRoutingIntegration | integration | software integration bench | planned | not yet run | test |  | 0 |
| commandRoutingHardwareInTheLoop | hardwareInTheLoop | flatsat | planned | not yet run | test |  | 0 |
| commandRoutingModel | modelInTheLoop | executable model | pass | sw-failover pinned run, advanced 600 s | analyze |  | 0 |
| thrustArcUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| thrustArcFlightSoftwareInTheLoop | flightSoftwareInTheLoop | trajectoryTool | pass | software/conformance/evidence/thrustArcFlightSoftwareInTheLoop.txt | test |  | 0 |
| thrustArcModel | modelInTheLoop | executable model | pass | sw-sep-string-restarting, fdir-thruster-string-lost, wpd-flight-rules pinned runs | analyze |  | 0 |
| powerManagementUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| powerManagementFlatsat | flatsat | flatsat | planned | not yet run | test |  | 0 |
| thermalControlUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| thermalControlFlatsat | flatsat | flatsat | planned | not yet run | test |  | 0 |
| spaceLinkUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| spaceLinkHardwareInTheLoop | hardwareInTheLoop | flatsat | planned | not yet run | test |  | 0 |
| inspectorRelayUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| inspectorRelayIntegration | integration | software integration bench | planned | not yet run | test |  | 0 |
| captureSequenceUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| captureSequenceFlightSoftwareInTheLoop | flightSoftwareInTheLoop | captureRig | pass | software/conformance/evidence/captureSequenceFlightSoftwareInTheLoop.txt | test |  | 0 |
| captureSequenceHardwareInTheLoop | hardwareInTheLoop | captureRig | planned | not yet run | test |  | 0 |
| captureSequenceModel | modelInTheLoop | executable model | pass | fdir-inhibit-chain-check, fdir-inhibit-chain-held, sw-capture-controller-check, sw-capture-controller-check-inhibited pinned runs | analyze |  | 0 |
| faultDetectionUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| faultDetectionFlightSoftwareInTheLoop | flightSoftwareInTheLoop | trajectoryTool | pass | software/conformance/evidence/faultDetectionFlightSoftwareInTheLoop.txt | test |  | 0 |
| faultDetectionFlatsat | flatsat | flatsat | planned | not yet run | test |  | 0 |
| faultDetectionModel | modelInTheLoop | executable model | pass | fdir-command-loss-expired, fdir-command-loss-modes-safe, sw-fdir-command-loss-expired, sw-fdir-thruster-restarting pinned runs | analyze |  | 0 |
| modeManagementUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| modeManagementFlatsat | flatsat | flatsat | planned | not yet run | test |  | 0 |
| modeManagementModel | modelInTheLoop | executable model | pass | sw-mode-manager-safe, sw-mode-manager-recovered, sw-mode-manager-full-flight, modes-tug-full-flight pinned runs | analyze |  | 0 |
| bootAndParameterUnit | unit | developer workstation | planned | not yet run | test |  | 0 |
| bootAndParameterHardwareInTheLoop | hardwareInTheLoop | flatsat | planned | not yet run | test |  | 0 |
| bootAndParameterModel | modelInTheLoop | executable model | pass | sw-boot, sw-boot-sequence pinned runs | analyze |  | 0 |
| hazardousCommandInhibitModel | modelInTheLoop | executable model | pass | sw-assurance-coverage pinned run | analyze |  | 0 |
| hazardousCommandInhibitFlatsat | flatsat | flatsat | planned | not yet run | test |  | 0 |
| groundTwoStepModel | modelInTheLoop | executable model | pass | sw-ground-sequencer-check pinned run: verdict refused, reason FR-001 | analyze |  | 0 |
| groundTwoStepIntegration | flightSoftwareInTheLoop | trajectoryTool | pass | software/conformance/evidence/groundTwoStepIntegration.txt | test |  | 0 |
| passPlanningIntegration | integration | operations centre integration | planned | not yet run | test |  | 0 |

*Software functions and their cases*

| name | verifiedBy | cases | hostedOn |
| --- | --- | --- | --- |
| estimateRelativeState | verifiedFunctions, verifiedFunctions | 2 | gnc, gnc, gncPartition, prime, redundant |
| planFinalTargeting | verifiedFunctions, verifiedFunctions, verifiedFunctions | 3 | gnc, gnc, gncPartition, prime, redundant |
| abortCapture | verifiedFunctions, verifiedFunctions | 2 | cdh, autonomy, autonomyPartition, prime, redundant |
| routeCommandsAndTelemetry | verifiedFunctions, verifiedFunctions, verifiedFunctions, verifiedFunctions, verifiedFunctions | 5 | cdh, cdh, platformPartition, prime, redundant |
| controlThrustArc | verifiedFunctions, verifiedFunctions, verifiedFunctions | 3 | sep, sepControl, subsystemPartition, prime, redundant |
| manageBatteryAndLoads | verifiedFunctions, verifiedFunctions | 2 | eps, powerManagement, subsystemPartition, prime, redundant |
| regulateHeaterZones | verifiedFunctions, verifiedFunctions | 2 | thermal, thermalControl, subsystemPartition, prime, redundant |
| manageSpaceLink | verifiedFunctions, verifiedFunctions | 2 | telecom, telecom, subsystemPartition, prime, redundant |
| relayInspector | verifiedFunctions, verifiedFunctions | 2 | cdh, inspectorHandling, payloadPartition, prime, redundant |
| controlCaptureSequence | verifiedFunctions, verifiedFunctions, verifiedFunctions, verifiedFunctions | 4 | captureSystem, captureControl, autonomyPartition, prime, redundant |
| executeOnBoardSequences | verifiedFunctions | 1 | cdh, autonomy, autonomyPartition, prime, redundant |
| detectAndRecoverFaults | verifiedFunctions, verifiedFunctions, verifiedFunctions, verifiedFunctions | 4 | cdh, fdir, platformPartition, prime, redundant |
| manageModes | verifiedFunctions, verifiedFunctions, verifiedFunctions | 3 | cdh, modeManagement, platformPartition, prime, redundant |
| manageParametersAndImages | verifiedFunctions, verifiedFunctions, verifiedFunctions | 3 | cdh, parameterBootUpdate, platformPartition, prime, redundant |

*Software functions without a case (expected empty)*

| name |
| --- |

*Cases passed at this baseline*

| name | SoftwareVerification::level | SoftwareVerification::evidence |
| --- | --- | --- |
| finalTargetingFlightSoftwareInTheLoop | flightSoftwareInTheLoop | software/conformance/evidence/finalTargetingFlightSoftwareInTheLoop.txt |
| finalTargetingModel | modelInTheLoop | fdir-earth-impact-aborted, fdir-earth-impact-abort-hold pinned runs |
| captureAbortModel | modelInTheLoop | sw-autonomy-engine pinned run: storedSequences 1 to 6 |
| commandRoutingModel | modelInTheLoop | sw-failover pinned run, advanced 600 s |
| thrustArcFlightSoftwareInTheLoop | flightSoftwareInTheLoop | software/conformance/evidence/thrustArcFlightSoftwareInTheLoop.txt |
| thrustArcModel | modelInTheLoop | sw-sep-string-restarting, fdir-thruster-string-lost, wpd-flight-rules pinned runs |
| captureSequenceFlightSoftwareInTheLoop | flightSoftwareInTheLoop | software/conformance/evidence/captureSequenceFlightSoftwareInTheLoop.txt |
| captureSequenceModel | modelInTheLoop | fdir-inhibit-chain-check, fdir-inhibit-chain-held, sw-capture-controller-check, sw-capture-controller-check-inhibited pinned runs |
| faultDetectionFlightSoftwareInTheLoop | flightSoftwareInTheLoop | software/conformance/evidence/faultDetectionFlightSoftwareInTheLoop.txt |
| faultDetectionModel | modelInTheLoop | fdir-command-loss-expired, fdir-command-loss-modes-safe, sw-fdir-command-loss-expired, sw-fdir-thruster-restarting pinned runs |
| modeManagementModel | modelInTheLoop | sw-mode-manager-safe, sw-mode-manager-recovered, sw-mode-manager-full-flight, modes-tug-full-flight pinned runs |
| bootAndParameterModel | modelInTheLoop | sw-boot, sw-boot-sequence pinned runs |
| hazardousCommandInhibitModel | modelInTheLoop | sw-assurance-coverage pinned run |
| groundTwoStepModel | modelInTheLoop | sw-ground-sequencer-check pinned run: verdict refused, reason FR-001 |
| groundTwoStepIntegration | flightSoftwareInTheLoop | software/conformance/evidence/groundTwoStepIntegration.txt |
