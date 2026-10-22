# ICD-001 Tug–inspector umbilical interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::UmbilicalPort |
| inspectorSide | TethysInterfaces::UmbilicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| keepAliveVoltage | ISQElectromagnetism::ElectricPotentialValue |
| keepAlivePower | ISQMechanics::PowerValue |
| checkoutDataRate | ISQInformation::BinaryDigitRateValue |
