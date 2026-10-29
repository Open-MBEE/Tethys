<!-- TethysAllocations::softwareDeploymentMatrix — matrix rendering (view def GridView) -->
| Source / Target | TethysFlightSoftware::ArgentFlightSoftware::gnc | TethysFlightSoftware::ArgentFlightSoftware::autonomy | TethysFlightSoftware::ArgentFlightSoftware::cdh | TethysFlightSoftware::ArgentFlightSoftware::sepControl | TethysFlightSoftware::ArgentFlightSoftware::powerManagement | TethysFlightSoftware::ArgentFlightSoftware::thermalControl | TethysFlightSoftware::ArgentFlightSoftware::telecom | TethysFlightSoftware::ArgentFlightSoftware::inspectorHandling | TethysFlightSoftware::ArgentFlightSoftware::captureControl | TethysFlightSoftware::ArgentFlightSoftware::fdir | TethysFlightSoftware::ArgentFlightSoftware::modeManagement | TethysFlightSoftware::ArgentFlightSoftware::parameterBootUpdate | TethysFlightSoftware::ArgentFlightSoftware::executive::platformPartition | TethysFlightSoftware::ArgentFlightSoftware::executive::gncPartition | TethysFlightSoftware::ArgentFlightSoftware::executive::subsystemPartition | TethysFlightSoftware::ArgentFlightSoftware::executive::autonomyPartition | TethysFlightSoftware::ArgentFlightSoftware::executive::payloadPartition | TethysFlightSoftware::CdhWithSoftware::prime | TethysFlightSoftware::CdhWithSoftware::redundant |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TethysAllocations::missionFunctions::estimateRelativeState | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::planFinalTargeting | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::abortCapture |  | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::routeCommandsAndTelemetry |  |  | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::controlThrustArc |  |  |  | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::manageBatteryAndLoads |  |  |  |  | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::regulateHeaterZones |  |  |  |  |  | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::manageSpaceLink |  |  |  |  |  |  | allocate |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::relayInspector |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::controlCaptureSequence |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::executeOnBoardSequences |  | allocate |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::detectAndRecoverFaults |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::manageModes |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |  |  |
| TethysAllocations::missionFunctions::manageParametersAndImages |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::cdh |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::fdir |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::modeManagement |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::parameterBootUpdate |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::gnc |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::sepControl |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::powerManagement |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::thermalControl |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::telecom |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::autonomy |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::captureControl |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::inspectorHandling |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate |  |  |
| TethysFlightSoftware::ArgentFlightSoftware::executive::platformPartition |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate | allocate |
| TethysFlightSoftware::ArgentFlightSoftware::executive::gncPartition |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate | allocate |
| TethysFlightSoftware::ArgentFlightSoftware::executive::subsystemPartition |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate | allocate |
| TethysFlightSoftware::ArgentFlightSoftware::executive::autonomyPartition |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate | allocate |
| TethysFlightSoftware::ArgentFlightSoftware::executive::payloadPartition |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | allocate | allocate |
