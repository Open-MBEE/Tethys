# ICD-009 Propellant feed interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tankSide | TethysInterfaces::FluidPort |
| groundSide | TethysInterfaces::FluidPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| fillPressure | ISQMechanics::PressureValue | 15000000 \[Pa\] |
| fillRate | ISQMechanics::MassFlowRateValue | 0.02 \['kg⋅s⁻¹'\] |
| loadedMass | ISQBase::MassValue |  |
