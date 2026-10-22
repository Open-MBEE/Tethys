# ICD-008 Inspector thermal interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::ThermalPort |
| inspectorSide | TethysInterfaces::ThermalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| survivalTemperature | ISQBase::ThermodynamicTemperatureValue |
| heaterPower | ISQMechanics::PowerValue |
