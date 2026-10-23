# ICD-007 Inspector dispenser interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::MechanicalPort |
| inspectorSide | TethysInterfaces::MechanicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| railPreload | ISQMechanics::ForceValue |
| ejectionSpeed | ISQSpaceTime::SpeedValue |
| inspectorMassMaximum | ISQBase::MassValue |
