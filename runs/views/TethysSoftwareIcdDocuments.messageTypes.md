<!-- TethysSoftwareIcdDocuments::messageTypes — table rendering (render Views::asElementTable) -->
| Element | Kind | Type | Declared in |
| --- | --- | --- | --- |
| TethysSoftwareIcds::TelemetryMessage | item def |  |  |
| TethysSoftwareIcds::CommandMessage | item def |  |  |
| TethysSoftwareIcds::AttitudeStateMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::AttitudeStateMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::AttitudeStateMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::AttitudeStateMessage |
| TethysSoftwareIcds::NavigationStateMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::NavigationStateMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::NavigationStateMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::NavigationStateMessage |
| TethysSoftwareIcds::ThrusterStatusMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::ThrusterStatusMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::ThrusterStatusMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::ThrusterStatusMessage |
| TethysSoftwareIcds::PowerStateMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::PowerStateMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::PowerStateMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::PowerStateMessage |
| TethysSoftwareIcds::ThermalStateMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::ThermalStateMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::ThermalStateMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::ThermalStateMessage |
| TethysSoftwareIcds::LinkStatusMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::LinkStatusMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::LinkStatusMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::LinkStatusMessage |
| TethysSoftwareIcds::CaptureStateMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::CaptureStateMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::CaptureStateMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::CaptureStateMessage |
| TethysSoftwareIcds::RelayStatusMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::RelayStatusMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::RelayStatusMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::RelayStatusMessage |
| TethysSoftwareIcds::FaultReportMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::FaultReportMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::FaultReportMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::FaultReportMessage |
| opcode | attribute | String | TethysSoftwareIcds::FaultReportMessage |
| TethysSoftwareIcds::ModeChangeMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::ModeChangeMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::ModeChangeMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::ModeChangeMessage |
| opcode | attribute | String | TethysSoftwareIcds::ModeChangeMessage |
| TethysSoftwareIcds::SequenceStepMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::SequenceStepMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::SequenceStepMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::SequenceStepMessage |
| opcode | attribute | String | TethysSoftwareIcds::SequenceStepMessage |
| TethysSoftwareIcds::TimeTickMessage | item def |  |  |
| apid | attribute | Natural | TethysSoftwareIcds::TimeTickMessage |
| length | attribute | StorageCapacityValue | TethysSoftwareIcds::TimeTickMessage |
| period | attribute | DurationValue | TethysSoftwareIcds::TimeTickMessage |
| TethysFlightSoftware::BusMessage | item def |  |  |
| period | attribute | DurationValue | TethysFlightSoftware::BusMessage |
| TethysIcds::CommandPacket | item def |  |  |
| opcode | attribute | String | TethysIcds::CommandPacket |
| TethysFlightSoftware::DataProduct | item def |  |  |
| size | attribute | StorageCapacityValue | TethysFlightSoftware::DataProduct |
| downlinkPriority | attribute | Natural | TethysFlightSoftware::DataProduct |
| retention | attribute | DurationValue | TethysFlightSoftware::DataProduct |
| TethysFlightSoftware::ImageSegment | item def |  |  |
| offset | attribute | StorageCapacityValue | TethysFlightSoftware::ImageSegment |
| length | attribute | StorageCapacityValue | TethysFlightSoftware::ImageSegment |
| TethysFlightSoftware::ParameterTable | item def |  |  |
| tableId | attribute | Natural | TethysFlightSoftware::ParameterTable |
| size | attribute | StorageCapacityValue | TethysFlightSoftware::ParameterTable |
| TethysFlightSoftware::SoftwareEvent | item def |  |  |
| level | attribute | FdirLevel | TethysFlightSoftware::SoftwareEvent |
| isFault | attribute | Boolean | TethysFlightSoftware::SoftwareEvent |
| TethysIcds::SpacePacket | item def |  |  |
| apid | attribute | Natural | TethysIcds::SpacePacket |
| sequenceCount | attribute | Natural | TethysIcds::SpacePacket |
| length | attribute | StorageCapacityValue | TethysIcds::SpacePacket |
| primaryHeaderLength | attribute | StorageCapacityValue | TethysIcds::SpacePacket |
| secondaryHeader | attribute | PacketSecondaryHeader | TethysIcds::SpacePacket |
| TethysIcds::TelemetryPacket | item def |  |  |
| TethysFlightSoftware::TimeTick | item def |  |  |
| missionElapsedTime | attribute | DurationValue | TethysFlightSoftware::TimeTick |
