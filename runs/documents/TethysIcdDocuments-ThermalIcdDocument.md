# ICD-014 Thermal interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| hot | TethysInterfaces::ThermalPort |
| cold | TethysInterfaces::ThermalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| conductance | ISQThermodynamics::ThermalConductanceValue | 2.5 \[W/K\] |
| maximumHeat | ISQMechanics::PowerValue | 150 \[W\] |
| interfaceTemperatureMinimum | ISQBase::ThermodynamicTemperatureValue | 253 \[K\] |
| interfaceTemperatureMaximum | ISQBase::ThermodynamicTemperatureValue | 313 \[K\] |
