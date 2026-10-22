# ICD-009 Propellant feed interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tankSide | TethysInterfaces::FluidPort |
| groundSide | TethysInterfaces::FluidPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| fillPressure | ISQMechanics::PressureValue |
| fillRate | ISQMechanics::MassFlowRateValue |
| loadedMass | ISQBase::MassValue |
