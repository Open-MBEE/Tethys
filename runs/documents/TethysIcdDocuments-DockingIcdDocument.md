# ICD-006 Docking interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::DockingPort |
| visitorSide | TethysInterfaces::DockingPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| ringDiameter | ISQBase::LengthValue |
| captureSpeedMaximum | ISQSpaceTime::SpeedValue |
| transferVoltage | ISQElectromagnetism::ElectricPotentialValue |
| transferPower | ISQMechanics::PowerValue |
| dataRate | ISQInformation::BinaryDigitRateValue |
