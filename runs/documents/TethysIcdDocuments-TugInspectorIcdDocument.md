# ICD-001 Tug–inspector umbilical interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::UmbilicalPort |
| inspectorSide | TethysInterfaces::UmbilicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| keepAliveVoltage | ISQElectromagnetism::ElectricPotentialValue | 28 \[V\] |
| keepAlivePower | ISQMechanics::PowerValue | 15 \[W\] |
| checkoutDataRate | ISQInformation::BinaryDigitRateValue | 9600 \[bit/s\] |
