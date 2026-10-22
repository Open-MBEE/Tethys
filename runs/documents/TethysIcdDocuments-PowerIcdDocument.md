# ICD-011 Regulated power interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| source | TethysInterfaces::PowerOutlet |
| load | TethysInterfaces::PowerOutlet |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| busVoltage | ISQElectromagnetism::ElectricPotentialValue |
| voltageTolerance | ISQElectromagnetism::ElectricPotentialValue |
| maximumLoadPower | ISQMechanics::PowerValue |
