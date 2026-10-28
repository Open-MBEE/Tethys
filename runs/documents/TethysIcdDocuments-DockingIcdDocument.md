# ICD-006 Docking interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::DockingPort |
| visitorSide | TethysInterfaces::DockingPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| ringDiameter | ISQBase::LengthValue | 0.8 \[m\] |
| captureSpeedMaximum | ISQSpaceTime::SpeedValue | 0.05 \['m/s'\] |
| transferVoltage | ISQElectromagnetism::ElectricPotentialValue | 120 \[V\] |
| transferPower | ISQMechanics::PowerValue | 2 \[kW\] |
| dataRate | ISQInformation::BinaryDigitRateValue | 10000000 \[bit/s\] |
