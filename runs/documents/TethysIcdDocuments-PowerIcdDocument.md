# ICD-011 Regulated power interface

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
| busVoltage | ISQElectromagnetism::ElectricPotentialValue | 28 \[V\] |
| voltageTolerance | ISQElectromagnetism::ElectricPotentialValue | 1 \[V\] |
| maximumLoadPower | ISQMechanics::PowerValue | 1200 \[W\] |
