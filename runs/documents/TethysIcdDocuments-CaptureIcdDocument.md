# ICD-005 Capture interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| tugSide | TethysInterfaces::MechanicalPort |
| bodySide | TethysInterfaces::MechanicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| maximumContactForce | ISQMechanics::ForceValue |
| maximumContactSpeed | ISQSpaceTime::SpeedValue |
| maximumBodySpinRate | ISQSpaceTime::AngularVelocityValue |
| despinTorque | ISQMechanics::TorqueValue |
| surfaceTemperatureMinimum | ISQBase::ThermodynamicTemperatureValue |
| surfaceTemperatureMaximum | ISQBase::ThermodynamicTemperatureValue |
