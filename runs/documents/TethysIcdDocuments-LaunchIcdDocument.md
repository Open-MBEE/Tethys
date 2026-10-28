# ICD-002 Spacecraft–launcher interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| spacecraftSide | TethysInterfaces::MechanicalPort |
| launcherSide | TethysInterfaces::MechanicalPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| adapterDiameter | ISQBase::LengthValue | 1.666 \[m\] |
| fairingEnvelopeDiameter | ISQBase::LengthValue | 4.5 \[m\] |
| fairingEnvelopeHeight | ISQBase::LengthValue | 11 \[m\] |
| axialQuasiStatic | ISQSpaceTime::AccelerationValue | 58.8 \['m/s²'\] |
| lateralQuasiStatic | ISQSpaceTime::AccelerationValue | 19.6 \['m/s²'\] |
| sineVibration | ISQSpaceTime::AccelerationValue | 9.8 \['m/s²'\] |
| shockResponse | ISQSpaceTime::AccelerationValue | 19600 \['m/s²'\] |
| acousticLevelDb | ScalarValues::Real | 139.5 |
| maximumStackMass | ISQBase::MassValue | 12800 \[kg\] |
| maximumCentreOfMassHeight | ISQBase::LengthValue | 2.6 \[m\] |
| separationSpeed | ISQSpaceTime::SpeedValue | 0.5 \['m/s'\] |
| tipOffRate | ISQSpaceTime::AngularVelocityValue | 0.0175 \['rad⋅s⁻¹'\] |
| injectionC3ToleranceKm2PerS2 | ScalarValues::Real | 0.1 |
| umbilicalVoltage | ISQElectromagnetism::ElectricPotentialValue | 28 \[V\] |
