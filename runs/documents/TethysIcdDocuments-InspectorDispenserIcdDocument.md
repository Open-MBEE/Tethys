# ICD-007 Inspector dispenser interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::MechanicalPort |
| inspectorSide | TethysInterfaces::MechanicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| railPreload | ISQMechanics::ForceValue | 400 \[N\] |
| ejectionSpeed | ISQSpaceTime::SpeedValue | 0.3 \['m/s'\] |
| inspectorMassMaximum | ISQBase::MassValue | 26 \[kg\] |
