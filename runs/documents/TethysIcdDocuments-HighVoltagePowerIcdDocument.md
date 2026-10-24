# ICD-012 High-voltage power interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| source | TethysInterfaces::PowerOutlet |
| load | TethysInterfaces::PowerOutlet |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| busVoltage | ISQElectromagnetism::ElectricPotentialValue | 300 \[V\] |
| maximumLoadPower | ISQMechanics::PowerValue | 40 \[kW\] |
