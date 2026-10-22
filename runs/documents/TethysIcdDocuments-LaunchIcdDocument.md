# ICD-002 Spacecraft–launcher interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| spacecraftSide | TethysInterfaces::MechanicalPort |
| launcherSide | TethysInterfaces::MechanicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| adapterDiameter | ISQBase::LengthValue |
| fairingEnvelopeDiameter | ISQBase::LengthValue |
| fairingEnvelopeHeight | ISQBase::LengthValue |
| axialQuasiStatic | ISQSpaceTime::AccelerationValue |
| lateralQuasiStatic | ISQSpaceTime::AccelerationValue |
| sineVibration | ISQSpaceTime::AccelerationValue |
| shockResponse | ISQSpaceTime::AccelerationValue |
| acousticLevelDb | ScalarValues::Real |
| maximumStackMass | ISQBase::MassValue |
| maximumCentreOfMassHeight | ISQBase::LengthValue |
| separationSpeed | ISQSpaceTime::SpeedValue |
| tipOffRate | ISQSpaceTime::AngularVelocityValue |
| injectionC3ToleranceKm2PerS2 | ScalarValues::Real |
| umbilicalVoltage | ISQElectromagnetism::ElectricPotentialValue |
