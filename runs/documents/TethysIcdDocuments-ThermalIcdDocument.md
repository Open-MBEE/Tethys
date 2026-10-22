# ICD-014 Thermal interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| hot | TethysInterfaces::ThermalPort |
| cold | TethysInterfaces::ThermalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| conductance | ISQThermodynamics::ThermalConductanceValue |
| maximumHeat | ISQMechanics::PowerValue |
| interfaceTemperatureMinimum | ISQBase::ThermodynamicTemperatureValue |
| interfaceTemperatureMaximum | ISQBase::ThermodynamicTemperatureValue |
