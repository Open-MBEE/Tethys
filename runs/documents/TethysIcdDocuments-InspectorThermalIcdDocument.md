# ICD-008 Inspector thermal interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::ThermalPort |
| inspectorSide | TethysInterfaces::ThermalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| survivalTemperature | ISQBase::ThermodynamicTemperatureValue | 263 \[K\] |
| heaterPower | ISQMechanics::PowerValue | 4 \[W\] |
