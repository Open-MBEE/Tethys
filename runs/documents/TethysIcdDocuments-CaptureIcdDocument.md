# ICD-005 Capture interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::MechanicalPort |
| bodySide | TethysInterfaces::MechanicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| maximumContactForce | ISQMechanics::ForceValue | 2500 \[N\] |
| maximumContactSpeed | ISQSpaceTime::SpeedValue | 0.1 \['m/s'\] |
| maximumBodySpinRate | ISQSpaceTime::AngularVelocityValue | 0.0175 \['rad⋅s⁻¹'\] |
| despinTorque | ISQMechanics::TorqueValue | 120 \['N⋅m'\] |
| surfaceTemperatureMinimum | ISQBase::ThermodynamicTemperatureValue | 180 \[K\] |
| surfaceTemperatureMaximum | ISQBase::ThermodynamicTemperatureValue | 340 \[K\] |
