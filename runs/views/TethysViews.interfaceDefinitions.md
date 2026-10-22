<!-- TethysViews::interfaceDefinitions — table rendering (render asElementTable) -->
| Element | Kind | Type | Declared in |
| --- | --- | --- | --- |
| TethysInterfaces::ElectricalPower | item def |  |  |
| voltage | attribute | ElectricPotentialValue | TethysInterfaces::ElectricalPower |
| power | attribute | PowerValue | TethysInterfaces::ElectricalPower |
| TethysInterfaces::Telemetry | item def |  |  |
| dataRate | attribute | Real | TethysInterfaces::Telemetry |
| volume | attribute | Real | TethysInterfaces::Telemetry |
| TethysInterfaces::Telecommand | item def |  |  |
| TethysInterfaces::RfCarrier | item def |  |  |
| frequency | attribute | FrequencyValue | TethysInterfaces::RfCarrier |
| eirp | attribute | PowerValue | TethysInterfaces::RfCarrier |
| TethysInterfaces::Heat | item def |  |  |
| power | attribute | PowerValue | TethysInterfaces::Heat |
| TethysInterfaces::MechanicalLoad | item def |  |  |
| quasiStaticAcceleration | attribute | AccelerationValue | TethysInterfaces::MechanicalLoad |
| force | attribute | ForceValue | TethysInterfaces::MechanicalLoad |
| TethysInterfaces::Propellant | item def |  |  |
| mass | attribute | MassValue | TethysInterfaces::Propellant |
| TethysInterfaces::PowerOutlet | port def |  |  |
| supply | item | ElectricalPower | TethysInterfaces::PowerOutlet |
| TethysInterfaces::DataBusPort | port def |  |  |
| telemetry | item | Telemetry | TethysInterfaces::DataBusPort |
| telecommand | item | Telecommand | TethysInterfaces::DataBusPort |
| TethysInterfaces::RfPort | port def |  |  |
| carrier | item | RfCarrier | TethysInterfaces::RfPort |
| TethysInterfaces::ThermalPort | port def |  |  |
| heat | item | Heat | TethysInterfaces::ThermalPort |
| TethysInterfaces::MechanicalPort | port def |  |  |
| load | item | MechanicalLoad | TethysInterfaces::MechanicalPort |
| separable | attribute | Boolean | TethysInterfaces::MechanicalPort |
| TethysInterfaces::UmbilicalPort | port def |  |  |
| keepAlive | item | ElectricalPower | TethysInterfaces::UmbilicalPort |
| checkout | item | Telemetry | TethysInterfaces::UmbilicalPort |
| separationSignal | attribute | Boolean | TethysInterfaces::UmbilicalPort |
| TethysInterfaces::FluidPort | port def |  |  |
| propellantFlow | item | Propellant | TethysInterfaces::FluidPort |
| TethysInterfaces::DockingPort | port def |  |  |
| load | item | MechanicalLoad | TethysInterfaces::DockingPort |
| transfer | item | ElectricalPower | TethysInterfaces::DockingPort |
| data | item | Telemetry | TethysInterfaces::DockingPort |
| TethysInterfaces::TugInspectorInterface | interface def |  |  |
| tugSide | port | UmbilicalPort | TethysInterfaces::TugInspectorInterface |
| inspectorSide | port | ~UmbilicalPort | TethysInterfaces::TugInspectorInterface |
| TethysInterfaces::SpacecraftLauncherInterface | interface def |  |  |
| spacecraftSide | port | MechanicalPort | TethysInterfaces::SpacecraftLauncherInterface |
| launcherSide | port | ~MechanicalPort | TethysInterfaces::SpacecraftLauncherInterface |
| TethysInterfaces::SpaceGroundLink | interface def |  |  |
| spacecraftSide | port | RfPort | TethysInterfaces::SpaceGroundLink |
| groundSide | port | ~RfPort | TethysInterfaces::SpaceGroundLink |
| TethysInterfaces::InspectorRelayLink | interface def |  |  |
| inspectorSide | port | RfPort | TethysInterfaces::InspectorRelayLink |
| tugSide | port | ~RfPort | TethysInterfaces::InspectorRelayLink |
| TethysInterfaces::CaptureInterface | interface def |  |  |
| tugSide | port | MechanicalPort | TethysInterfaces::CaptureInterface |
| bodySide | port | ~MechanicalPort | TethysInterfaces::CaptureInterface |
| TethysInterfaces::DockingInterface | interface def |  |  |
| tugSide | port | DockingPort | TethysInterfaces::DockingInterface |
| visitorSide | port | ~DockingPort | TethysInterfaces::DockingInterface |
| TethysInterfaces::PowerInterface | interface def |  |  |
| source | port | PowerOutlet | TethysInterfaces::PowerInterface |
| load | port | ~PowerOutlet | TethysInterfaces::PowerInterface |
| TethysInterfaces::DataBusInterface | interface def |  |  |
| a | port | DataBusPort | TethysInterfaces::DataBusInterface |
| b | port | ~DataBusPort | TethysInterfaces::DataBusInterface |
| TethysInterfaces::ThermalInterface | interface def |  |  |
| hot | port | ThermalPort | TethysInterfaces::ThermalInterface |
| cold | port | ~ThermalPort | TethysInterfaces::ThermalInterface |
| SI::ampere | attribute | ElectricCurrentUnit |  |
| SI::'ampere per metre' | attribute | LinearElectricCurrentDensityUnit |  |
| SI::'ampere per square metre' | attribute | ElectricCurrentDensityUnit |  |
| ISQChemistryMolecular::AbsoluteActivityValue | attribute def |  |  |
| ISQAtomicNuclear::AbsorbedDoseRateUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AbsorbedDoseRateUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AbsorbedDoseRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::AbsorbedDoseRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::AbsorbedDoseRateValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::AbsorbedDoseRateValue |
| mRef | attribute | AbsorbedDoseRateUnit | ISQAtomicNuclear::AbsorbedDoseRateValue |
| ISQAtomicNuclear::AbsorbedDoseUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AbsorbedDoseUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AbsorbedDoseUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::AbsorbedDoseUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::AbsorbedDoseValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::AbsorbedDoseValue |
| mRef | attribute | AbsorbedDoseUnit | ISQAtomicNuclear::AbsorbedDoseValue |
| ISQLight::AbsorptanceValue | attribute def |  |  |
| ISQCharacteristicNumbers::AbsorptionNumberValue | attribute def |  |  |
| ISQSpaceTime::AccelerationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::AccelerationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::AccelerationUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::AccelerationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::AccelerationValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AccelerationValue |
| mRef | attribute | AccelerationUnit | ISQSpaceTime::AccelerationValue |
| ISQCondensedMatter::AcceptorDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::AcceptorDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::AcceptorDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::AcceptorDensityValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::AcceptorDensityValue |
| mRef | attribute | AcceptorDensityUnit | ISQCondensedMatter::AcceptorDensityValue |
| ISQAcoustics::AcousticImpedanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAcoustics::AcousticImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAcoustics::AcousticImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAcoustics::AcousticImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAcoustics::AcousticImpedanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAcoustics::AcousticImpedanceValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::AcousticImpedanceValue |
| mRef | attribute | AcousticImpedanceUnit | ISQAcoustics::AcousticImpedanceValue |
| ISQMechanics::ActionQuantityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::ActionQuantityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::ActionQuantityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::ActionQuantityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::ActionQuantityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::ActionQuantityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::ActionQuantityValue |
| mRef | attribute | ActionQuantityUnit | ISQMechanics::ActionQuantityValue |
| ISQChemistryMolecular::ActivityCoefficientValue | attribute def |  |  |
| ISQAtomicNuclear::ActivityConcentrationUnit | alias |  |  |
| ISQAtomicNuclear::ActivityConcentrationValue | alias |  |  |
| ISQAtomicNuclear::ActivityDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ActivityDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ActivityDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ActivityDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ActivityDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ActivityDensityValue |
| mRef | attribute | ActivityDensityUnit | ISQAtomicNuclear::ActivityDensityValue |
| ISQChemistryMolecular::ActivityFactorValue | attribute def |  |  |
| ISQChemistryMolecular::ActivityOfSoluteValue | attribute def |  |  |
| ISQChemistryMolecular::ActivityOfSolventValue | attribute def |  |  |
| ISQElectromagnetism::AdmittanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::AdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::AdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::AdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::AdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::AdmittanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::AdmittanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::AdmittanceValue |
| mRef | attribute | AdmittanceUnit | ISQElectromagnetism::AdmittanceValue |
| ISQChemistryMolecular::AffinityOfAChemicalReactionUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::AffinityOfAChemicalReactionUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::AffinityOfAChemicalReactionUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::AffinityOfAChemicalReactionUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::AffinityOfAChemicalReactionUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::AffinityOfAChemicalReactionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::AffinityOfAChemicalReactionValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::AffinityOfAChemicalReactionValue |
| mRef | attribute | AffinityOfAChemicalReactionUnit | ISQChemistryMolecular::AffinityOfAChemicalReactionValue |
| ISQCharacteristicNumbers::'AlfvénNumberValue' | attribute def |  |  |
| ISQChemistryMolecular::AmountOfSubstanceConcentrationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::AmountOfSubstanceConcentrationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::AmountOfSubstanceConcentrationUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::AmountOfSubstanceConcentrationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::AmountOfSubstanceConcentrationValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::AmountOfSubstanceConcentrationValue |
| mRef | attribute | AmountOfSubstanceConcentrationUnit | ISQChemistryMolecular::AmountOfSubstanceConcentrationValue |
| ISQChemistryMolecular::AmountOfSubstanceFractionMoleFractionValue | attribute def |  |  |
| ISQBase::AmountOfSubstanceUnit | attribute def |  |  |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQBase::AmountOfSubstanceUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQBase::AmountOfSubstanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQBase::AmountOfSubstanceValue | attribute def |  |  |
| num | attribute | Real | ISQBase::AmountOfSubstanceValue |
| mRef | attribute | AmountOfSubstanceUnit | ISQBase::AmountOfSubstanceValue |
| ISQCharacteristicNumbers::'AmpèreNumberValue' | attribute def |  |  |
| ISQSpaceTime::AngularAccelerationUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::AngularAccelerationUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::AngularAccelerationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::AngularAccelerationValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AngularAccelerationValue |
| mRef | attribute | AngularAccelerationUnit | ISQSpaceTime::AngularAccelerationValue |
| ISQSpaceTime::AngularFrequencyUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::AngularFrequencyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::AngularFrequencyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::AngularFrequencyValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AngularFrequencyValue |
| mRef | attribute | AngularFrequencyUnit | ISQSpaceTime::AngularFrequencyValue |
| ISQMechanics::AngularImpulseUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::AngularImpulseUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::AngularImpulseUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::AngularImpulseUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::AngularImpulseUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::AngularImpulseValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::AngularImpulseValue |
| mRef | attribute | AngularImpulseUnit | ISQMechanics::AngularImpulseValue |
| ISQSpaceTime::AngularMeasureUnit | attribute def |  |  |
| ISQSpaceTime::AngularMeasureValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AngularMeasureValue |
| mRef | attribute | AngularMeasureUnit | ISQSpaceTime::AngularMeasureValue |
| ISQMechanics::AngularMomentumUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::AngularMomentumUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::AngularMomentumUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::AngularMomentumUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::AngularMomentumUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::AngularMomentumValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::AngularMomentumValue |
| mRef | attribute | AngularMomentumUnit | ISQMechanics::AngularMomentumValue |
| ISQCondensedMatter::AngularReciprocalLatticeVectorMagnitudeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::AngularReciprocalLatticeVectorMagnitudeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::AngularReciprocalLatticeVectorMagnitudeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::AngularReciprocalLatticeVectorMagnitudeValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::AngularReciprocalLatticeVectorMagnitudeValue |
| mRef | attribute | AngularReciprocalLatticeVectorMagnitudeUnit | ISQCondensedMatter::AngularReciprocalLatticeVectorMagnitudeValue |
| ISQSpaceTime::AngularRepetencyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::AngularRepetencyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::AngularRepetencyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::AngularRepetencyValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AngularRepetencyValue |
| mRef | attribute | AngularRepetencyUnit | ISQSpaceTime::AngularRepetencyValue |
| ISQSpaceTime::AngularVelocityUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::AngularVelocityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::AngularVelocityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::AngularVelocityValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AngularVelocityValue |
| mRef | attribute | AngularVelocityUnit | ISQSpaceTime::AngularVelocityValue |
| ISQSpaceTime::AngularWavenumberUnit | alias |  |  |
| ISQSpaceTime::AngularWavenumberValue | alias |  |  |
| ISQCharacteristicNumbers::ArchimedesNumberValue | attribute def |  |  |
| ISQSpaceTime::AreaUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::AreaUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::AreaUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::AreaValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AreaValue |
| mRef | attribute | AreaUnit | ISQSpaceTime::AreaValue |
| ISQElectromagnetism::AreicElectricChargeUnit | alias |  |  |
| ISQElectromagnetism::AreicElectricChargeValue | alias |  |  |
| ISQCharacteristicNumbers::ArrheniusNumberValue | attribute def |  |  |
| ISQAtomicNuclear::AtomicAttenuationCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AtomicAttenuationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::AtomicAttenuationCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::AtomicAttenuationCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::AtomicAttenuationCoefficientValue |
| mRef | attribute | AtomicAttenuationCoefficientUnit | ISQAtomicNuclear::AtomicAttenuationCoefficientValue |
| ISQCondensedMatter::AtomicScatteringFactorValue | attribute def |  |  |
| ISQSpaceTime::AttenuationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::AttenuationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::AttenuationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::AttenuationValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::AttenuationValue |
| mRef | attribute | AttenuationUnit | ISQSpaceTime::AttenuationValue |
| ISQCharacteristicNumbers::AtwoodNumberValue | attribute def |  |  |
| ISQInformation::AverageConditionalInformationContentUnit | alias |  |  |
| ISQInformation::AverageConditionalInformationContentValue | alias |  |  |
| ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedValue |
| mRef | attribute | AverageEnergyLossPerElementaryChargeProducedUnit | ISQAtomicNuclear::AverageEnergyLossPerElementaryChargeProducedValue |
| ISQInformation::AverageInformationRateUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::AverageInformationRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::AverageInformationRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::AverageInformationRateValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::AverageInformationRateValue |
| mRef | attribute | AverageInformationRateUnit | ISQInformation::AverageInformationRateValue |
| ISQAtomicNuclear::AverageLogarithmicEnergyDecrementValue | attribute def |  |  |
| ISQInformation::AverageTransinformationRateUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::AverageTransinformationRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::AverageTransinformationRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::AverageTransinformationRateValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::AverageTransinformationRateValue |
| mRef | attribute | AverageTransinformationRateUnit | ISQInformation::AverageTransinformationRateValue |
| SI::'ampere metre squared' | attribute | MagneticMomentUnit |  |
| SI::'ampere metre squared joule to the power minus 1 second to the power minus 1' | attribute | GyromagneticRatioUnit |  |
| SI::'ampere metre to the power minus 2 kelvin to the power minus 2' | attribute | RichardsonConstantUnit |  |
| SI::'ampere second per kilogram' | attribute | GyromagneticRatioUnit |  |
| SI::byte | attribute | StorageCapacityUnit |  |
| SI::'byte per second' | attribute | TransferRateUnit |  |
| ISQCharacteristicNumbers::BagnoldNumberForSolidParticlesValue | attribute def |  |  |
| ISQCharacteristicNumbers::BagnoldNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::BatchelorNumberValue | attribute def |  |  |
| SI::baud | attribute | ModulationRateUnit |  |
| ISQCharacteristicNumbers::BejanNumberForEntropyValue | attribute def |  |  |
| ISQCharacteristicNumbers::BejanNumberForHeatTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::BejanNumberForMassTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::BejanNumberValue | attribute def |  |  |
| ISQInformation::BinaryDigitRateUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::BinaryDigitRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::BinaryDigitRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::BinaryDigitRateValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::BinaryDigitRateValue |
| mRef | attribute | BinaryDigitRateUnit | ISQInformation::BinaryDigitRateValue |
| ISQAtomicNuclear::BindingFractionValue | attribute def |  |  |
| ISQCharacteristicNumbers::BinghamNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::BiotNumberForMassTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::BiotNumberValue | attribute def |  |  |
| ISQInformation::BitRateUnit | alias |  |  |
| ISQInformation::BitRateValue | alias |  |  |
| ISQCharacteristicNumbers::BlakeNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::BodensteinNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::BoltzmannNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::BondNumberValue | attribute def |  |  |
| ScalarValues::Boolean | datatype |  |  |
| SI::becquerel | attribute | NuclearActivityUnit |  |
| SI::'becquerel per kilogram' | attribute | SpecificActivityUnit |  |
| SI::'becquerel per square metre' | attribute | SurfaceActivityDensityUnit |  |
| SI::'becquerel per cubic metre' | attribute | ActivityDensityUnit |  |
| ISQCharacteristicNumbers::BrinkmanNumberValue | attribute def |  |  |
| ISQMechanics::BulkModulusUnit | alias |  |  |
| ISQMechanics::BulkModulusValue | alias |  |  |
| SI::coulomb | attribute | ElectricChargeUnit |  |
| SI::'coulomb per kilogram second' | attribute | ExposureRateUnit |  |
| SI::'coulomb per kilogram' | attribute | ExposureUnit |  |
| SI::'coulomb per metre' | attribute | LinearDensityOfElectricChargeUnit |  |
| SI::'coulomb per square metre' | attribute | SurfaceDensityOfElectricChargeUnit |  |
| SI::'coulomb per cubic metre' | attribute | ElectricChargeDensityUnit |  |
| ISQInformation::CallIntensityUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::CallIntensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::CallIntensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::CallIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::CallIntensityValue |
| mRef | attribute | CallIntensityUnit | ISQInformation::CallIntensityValue |
| ISQInformation::CallingRateUnit | alias |  |  |
| ISQInformation::CallingRateValue | alias |  |  |
| ISQChemistryMolecular::CanonicalPartitionFunctionValue | attribute def |  |  |
| ISQElectromagnetism::CapacitanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::CapacitanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::CapacitanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::CapacitanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::CapacitanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::CapacitanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::CapacitanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::CapacitanceValue |
| mRef | attribute | CapacitanceUnit | ISQElectromagnetism::CapacitanceValue |
| ISQCharacteristicNumbers::CapillaryNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::CarnotNumberValue | attribute def |  |  |
| ISQMechanics::Cartesian3dMomentOfInertiaMeasurementReference | attribute def |  |  |
| dimensions | attribute | Positive | ISQMechanics::Cartesian3dMomentOfInertiaMeasurementReference |
| isBound | attribute | Boolean | ISQMechanics::Cartesian3dMomentOfInertiaMeasurementReference |
| mRefs | attribute | MomentOfInertiaUnit | ISQMechanics::Cartesian3dMomentOfInertiaMeasurementReference |
| ISQMechanics::Cartesian3dMomentOfInertiaTensor | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::Cartesian3dMomentOfInertiaTensor |
| num | attribute | Real | ISQMechanics::Cartesian3dMomentOfInertiaTensor |
| mRef | attribute | Cartesian3dMomentOfInertiaMeasurementReference | ISQMechanics::Cartesian3dMomentOfInertiaTensor |
| ISQMechanics::Cartesian3dStrainMeasurementReference | attribute def |  |  |
| dimensions | attribute | Positive | ISQMechanics::Cartesian3dStrainMeasurementReference |
| isBound | attribute | Boolean | ISQMechanics::Cartesian3dStrainMeasurementReference |
| mRefs | attribute | StrainUnit | ISQMechanics::Cartesian3dStrainMeasurementReference |
| ISQMechanics::Cartesian3dStrainTensor | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::Cartesian3dStrainTensor |
| num | attribute | Real | ISQMechanics::Cartesian3dStrainTensor |
| mRef | attribute | Cartesian3dStrainMeasurementReference | ISQMechanics::Cartesian3dStrainTensor |
| ISQMechanics::Cartesian3dStressMeasurementReference | attribute def |  |  |
| dimensions | attribute | Positive | ISQMechanics::Cartesian3dStressMeasurementReference |
| isBound | attribute | Boolean | ISQMechanics::Cartesian3dStressMeasurementReference |
| mRefs | attribute | StressUnit | ISQMechanics::Cartesian3dStressMeasurementReference |
| ISQMechanics::Cartesian3dStressTensor | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::Cartesian3dStressTensor |
| num | attribute | Real | ISQMechanics::Cartesian3dStressTensor |
| mRef | attribute | Cartesian3dStressMeasurementReference | ISQMechanics::Cartesian3dStressTensor |
| ISQSpaceTime::CartesianAcceleration3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianAcceleration3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::CartesianAcceleration3dCoordinateFrame |
| mRefs | attribute | AccelerationUnit | ISQSpaceTime::CartesianAcceleration3dCoordinateFrame |
| ISQSpaceTime::CartesianAcceleration3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianAcceleration3dVector |
| mRef | attribute | CartesianAcceleration3dCoordinateFrame | ISQSpaceTime::CartesianAcceleration3dVector |
| ISQSpaceTime::CartesianAngularAcceleration3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianAngularAcceleration3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::CartesianAngularAcceleration3dCoordinateFrame |
| mRefs | attribute | AngularAccelerationUnit | ISQSpaceTime::CartesianAngularAcceleration3dCoordinateFrame |
| ISQSpaceTime::CartesianAngularAcceleration3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianAngularAcceleration3dVector |
| mRef | attribute | CartesianAngularAcceleration3dCoordinateFrame | ISQSpaceTime::CartesianAngularAcceleration3dVector |
| ISQMechanics::CartesianAngularImpulse3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianAngularImpulse3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQMechanics::CartesianAngularImpulse3dCoordinateFrame |
| mRefs | attribute | AngularImpulseUnit | ISQMechanics::CartesianAngularImpulse3dCoordinateFrame |
| ISQMechanics::CartesianAngularImpulse3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianAngularImpulse3dVector |
| mRef | attribute | CartesianAngularImpulse3dCoordinateFrame | ISQMechanics::CartesianAngularImpulse3dVector |
| ISQMechanics::CartesianAngularMomentum3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianAngularMomentum3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQMechanics::CartesianAngularMomentum3dCoordinateFrame |
| mRefs | attribute | AngularMomentumUnit | ISQMechanics::CartesianAngularMomentum3dCoordinateFrame |
| ISQMechanics::CartesianAngularMomentum3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianAngularMomentum3dVector |
| mRef | attribute | CartesianAngularMomentum3dCoordinateFrame | ISQMechanics::CartesianAngularMomentum3dVector |
| ISQCondensedMatter::CartesianAngularReciprocalLattice3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianAngularReciprocalLattice3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQCondensedMatter::CartesianAngularReciprocalLattice3dCoordinateFrame |
| mRefs | attribute | AngularReciprocalLatticeVectorMagnitudeUnit | ISQCondensedMatter::CartesianAngularReciprocalLattice3dCoordinateFrame |
| ISQCondensedMatter::CartesianAngularReciprocalLattice3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianAngularReciprocalLattice3dVector |
| mRef | attribute | CartesianAngularReciprocalLattice3dCoordinateFrame | ISQCondensedMatter::CartesianAngularReciprocalLattice3dVector |
| ISQSpaceTime::CartesianAngularVelocity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianAngularVelocity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::CartesianAngularVelocity3dCoordinateFrame |
| mRefs | attribute | AngularVelocityUnit | ISQSpaceTime::CartesianAngularVelocity3dCoordinateFrame |
| ISQSpaceTime::CartesianAngularVelocity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianAngularVelocity3dVector |
| mRef | attribute | CartesianAngularVelocity3dCoordinateFrame | ISQSpaceTime::CartesianAngularVelocity3dVector |
| ISQElectromagnetism::CartesianAreicElectricCurrent3dCoordinateFrame | alias |  |  |
| ISQCondensedMatter::CartesianBurgers3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianBurgers3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQCondensedMatter::CartesianBurgers3dVector |
| ISQCondensedMatter::CartesianDisplacement3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianDisplacement3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQCondensedMatter::CartesianDisplacement3dVector |
| ISQSpaceTime::CartesianDisplacement3dVector | attribute def |  |  |
| x | attribute | LengthValue | ISQSpaceTime::CartesianDisplacement3dVector |
| y | attribute | LengthValue | ISQSpaceTime::CartesianDisplacement3dVector |
| z | attribute | LengthValue | ISQSpaceTime::CartesianDisplacement3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQSpaceTime::CartesianDisplacement3dVector |
| ISQElectromagnetism::CartesianDisplacementCurrentDensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianDisplacementCurrentDensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianDisplacementCurrentDensity3dCoordinateFrame |
| mRefs | attribute | DisplacementCurrentDensityUnit | ISQElectromagnetism::CartesianDisplacementCurrentDensity3dCoordinateFrame |
| ISQElectromagnetism::CartesianDisplacementCurrentDensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianDisplacementCurrentDensity3dVector |
| mRef | attribute | CartesianDisplacementCurrentDensity3dCoordinateFrame | ISQElectromagnetism::CartesianDisplacementCurrentDensity3dVector |
| ISQMechanics::CartesianDragForce3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianDragForce3dVector |
| mRef | attribute | CartesianForce3dCoordinateFrame | ISQMechanics::CartesianDragForce3dVector |
| ISQElectromagnetism::CartesianElectricCurrentDensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricCurrentDensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianElectricCurrentDensity3dCoordinateFrame |
| mRefs | attribute | ElectricCurrentDensityUnit | ISQElectromagnetism::CartesianElectricCurrentDensity3dCoordinateFrame |
| ISQElectromagnetism::CartesianElectricCurrentDensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricCurrentDensity3dVector |
| mRef | attribute | CartesianElectricCurrentDensity3dCoordinateFrame | ISQElectromagnetism::CartesianElectricCurrentDensity3dVector |
| ISQElectromagnetism::CartesianElectricDipoleMoment3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricDipoleMoment3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianElectricDipoleMoment3dCoordinateFrame |
| mRefs | attribute | ElectricDipoleMomentUnit | ISQElectromagnetism::CartesianElectricDipoleMoment3dCoordinateFrame |
| ISQElectromagnetism::CartesianElectricDipoleMoment3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricDipoleMoment3dVector |
| mRef | attribute | CartesianElectricDipoleMoment3dCoordinateFrame | ISQElectromagnetism::CartesianElectricDipoleMoment3dVector |
| ISQElectromagnetism::CartesianElectricDisplacement3dCoordinateFrame | alias |  |  |
| ISQElectromagnetism::CartesianElectricFieldStrength3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricFieldStrength3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianElectricFieldStrength3dCoordinateFrame |
| mRefs | attribute | ElectricFieldStrengthUnit | ISQElectromagnetism::CartesianElectricFieldStrength3dCoordinateFrame |
| ISQElectromagnetism::CartesianElectricFieldStrength3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricFieldStrength3dVector |
| mRef | attribute | CartesianElectricFieldStrength3dCoordinateFrame | ISQElectromagnetism::CartesianElectricFieldStrength3dVector |
| ISQElectromagnetism::CartesianElectricFluxDensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricFluxDensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianElectricFluxDensity3dCoordinateFrame |
| mRefs | attribute | ElectricFluxDensityUnit | ISQElectromagnetism::CartesianElectricFluxDensity3dCoordinateFrame |
| ISQElectromagnetism::CartesianElectricFluxDensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricFluxDensity3dVector |
| mRef | attribute | CartesianElectricFluxDensity3dCoordinateFrame | ISQElectromagnetism::CartesianElectricFluxDensity3dVector |
| ISQElectromagnetism::CartesianElectricPolarization3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricPolarization3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianElectricPolarization3dCoordinateFrame |
| mRefs | attribute | ElectricPolarizationUnit | ISQElectromagnetism::CartesianElectricPolarization3dCoordinateFrame |
| ISQElectromagnetism::CartesianElectricPolarization3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianElectricPolarization3dVector |
| mRef | attribute | CartesianElectricPolarization3dCoordinateFrame | ISQElectromagnetism::CartesianElectricPolarization3dVector |
| ISQCondensedMatter::CartesianEquilibriumPosition3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianEquilibriumPosition3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQCondensedMatter::CartesianEquilibriumPosition3dVector |
| ISQMechanics::CartesianForce3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianForce3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQMechanics::CartesianForce3dCoordinateFrame |
| mRefs | attribute | ForceUnit | ISQMechanics::CartesianForce3dCoordinateFrame |
| ISQMechanics::CartesianForce3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianForce3dVector |
| mRef | attribute | CartesianForce3dCoordinateFrame | ISQMechanics::CartesianForce3dVector |
| ISQCondensedMatter::CartesianFundamentalLattice3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianFundamentalLattice3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQCondensedMatter::CartesianFundamentalLattice3dVector |
| ISQCondensedMatter::CartesianFundamentalReciprocalLattice3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianFundamentalReciprocalLattice3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQCondensedMatter::CartesianFundamentalReciprocalLattice3dCoordinateFrame |
| mRefs | attribute | FundamentalReciprocalLatticeVectorMagnitudeUnit | ISQCondensedMatter::CartesianFundamentalReciprocalLattice3dCoordinateFrame |
| ISQCondensedMatter::CartesianFundamentalReciprocalLattice3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianFundamentalReciprocalLattice3dVector |
| mRef | attribute | CartesianFundamentalReciprocalLattice3dCoordinateFrame | ISQCondensedMatter::CartesianFundamentalReciprocalLattice3dVector |
| ISQMechanics::CartesianImpulse3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianImpulse3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQMechanics::CartesianImpulse3dCoordinateFrame |
| mRefs | attribute | ImpulseUnit | ISQMechanics::CartesianImpulse3dCoordinateFrame |
| ISQMechanics::CartesianImpulse3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianImpulse3dVector |
| mRef | attribute | CartesianImpulse3dCoordinateFrame | ISQMechanics::CartesianImpulse3dVector |
| ISQMechanics::CartesianKineticFrictionForce3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianKineticFrictionForce3dVector |
| mRef | attribute | CartesianForce3dCoordinateFrame | ISQMechanics::CartesianKineticFrictionForce3dVector |
| ISQCondensedMatter::CartesianLattice3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianLattice3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQCondensedMatter::CartesianLattice3dVector |
| ISQElectromagnetism::CartesianLinearElectricCurrentDensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianLinearElectricCurrentDensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianLinearElectricCurrentDensity3dCoordinateFrame |
| mRefs | attribute | LinearElectricCurrentDensityUnit | ISQElectromagnetism::CartesianLinearElectricCurrentDensity3dCoordinateFrame |
| ISQElectromagnetism::CartesianLinearElectricCurrentDensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianLinearElectricCurrentDensity3dVector |
| mRef | attribute | CartesianLinearElectricCurrentDensity3dCoordinateFrame | ISQElectromagnetism::CartesianLinearElectricCurrentDensity3dVector |
| ISQElectromagnetism::CartesianLineicElectricCurrent3dCoordinateFrame | alias |  |  |
| ISQElectromagnetism::CartesianMagneticAreaMoment3dCoordinateFrame | alias |  |  |
| ISQAtomicNuclear::CartesianMagneticDipoleMoment3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianMagneticDipoleMoment3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQAtomicNuclear::CartesianMagneticDipoleMoment3dCoordinateFrame |
| mRefs | attribute | MagneticDipoleMomentUnit | ISQAtomicNuclear::CartesianMagneticDipoleMoment3dCoordinateFrame |
| ISQElectromagnetism::CartesianMagneticDipoleMoment3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticDipoleMoment3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianMagneticDipoleMoment3dCoordinateFrame |
| mRefs | attribute | MagneticDipoleMomentUnit | ISQElectromagnetism::CartesianMagneticDipoleMoment3dCoordinateFrame |
| ISQAtomicNuclear::CartesianMagneticDipoleMoment3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianMagneticDipoleMoment3dVector |
| mRef | attribute | CartesianMagneticDipoleMoment3dCoordinateFrame | ISQAtomicNuclear::CartesianMagneticDipoleMoment3dVector |
| ISQElectromagnetism::CartesianMagneticDipoleMoment3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticDipoleMoment3dVector |
| mRef | attribute | CartesianMagneticDipoleMoment3dCoordinateFrame | ISQElectromagnetism::CartesianMagneticDipoleMoment3dVector |
| ISQElectromagnetism::CartesianMagneticFieldStrength3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticFieldStrength3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianMagneticFieldStrength3dCoordinateFrame |
| mRefs | attribute | MagneticFieldStrengthUnit | ISQElectromagnetism::CartesianMagneticFieldStrength3dCoordinateFrame |
| ISQElectromagnetism::CartesianMagneticFieldStrength3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticFieldStrength3dVector |
| mRef | attribute | CartesianMagneticFieldStrength3dCoordinateFrame | ISQElectromagnetism::CartesianMagneticFieldStrength3dVector |
| ISQElectromagnetism::CartesianMagneticFluxDensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticFluxDensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianMagneticFluxDensity3dCoordinateFrame |
| mRefs | attribute | MagneticFluxDensityUnit | ISQElectromagnetism::CartesianMagneticFluxDensity3dCoordinateFrame |
| ISQElectromagnetism::CartesianMagneticFluxDensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticFluxDensity3dVector |
| mRef | attribute | CartesianMagneticFluxDensity3dCoordinateFrame | ISQElectromagnetism::CartesianMagneticFluxDensity3dVector |
| ISQElectromagnetism::CartesianMagneticMoment3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticMoment3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianMagneticMoment3dCoordinateFrame |
| mRefs | attribute | MagneticMomentUnit | ISQElectromagnetism::CartesianMagneticMoment3dCoordinateFrame |
| ISQElectromagnetism::CartesianMagneticMoment3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticMoment3dVector |
| mRef | attribute | CartesianMagneticMoment3dCoordinateFrame | ISQElectromagnetism::CartesianMagneticMoment3dVector |
| ISQElectromagnetism::CartesianMagneticPolarization3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticPolarization3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianMagneticPolarization3dCoordinateFrame |
| mRefs | attribute | MagneticPolarizationUnit | ISQElectromagnetism::CartesianMagneticPolarization3dCoordinateFrame |
| ISQElectromagnetism::CartesianMagneticPolarization3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticPolarization3dVector |
| mRef | attribute | CartesianMagneticPolarization3dCoordinateFrame | ISQElectromagnetism::CartesianMagneticPolarization3dVector |
| ISQElectromagnetism::CartesianMagneticVectorPotential3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticVectorPotential3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianMagneticVectorPotential3dCoordinateFrame |
| mRefs | attribute | MagneticVectorPotentialUnit | ISQElectromagnetism::CartesianMagneticVectorPotential3dCoordinateFrame |
| ISQElectromagnetism::CartesianMagneticVectorPotential3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagneticVectorPotential3dVector |
| mRef | attribute | CartesianMagneticVectorPotential3dCoordinateFrame | ISQElectromagnetism::CartesianMagneticVectorPotential3dVector |
| ISQElectromagnetism::CartesianMagnetization3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagnetization3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianMagnetization3dCoordinateFrame |
| mRefs | attribute | MagnetizationUnit | ISQElectromagnetism::CartesianMagnetization3dCoordinateFrame |
| ISQElectromagnetism::CartesianMagnetization3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianMagnetization3dVector |
| mRef | attribute | CartesianMagnetization3dCoordinateFrame | ISQElectromagnetism::CartesianMagnetization3dVector |
| ISQElectromagnetism::CartesianMagnetizingField3dCoordinateFrame | alias |  |  |
| ISQMechanics::CartesianMassFlow3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianMassFlow3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQMechanics::CartesianMassFlow3dCoordinateFrame |
| mRefs | attribute | MassFlowUnit | ISQMechanics::CartesianMassFlow3dCoordinateFrame |
| ISQMechanics::CartesianMassFlow3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianMassFlow3dVector |
| mRef | attribute | CartesianMassFlow3dCoordinateFrame | ISQMechanics::CartesianMassFlow3dVector |
| ISQMechanics::CartesianMomentOfForce3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianMomentOfForce3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQMechanics::CartesianMomentOfForce3dCoordinateFrame |
| mRefs | attribute | MomentOfForceUnit | ISQMechanics::CartesianMomentOfForce3dCoordinateFrame |
| ISQMechanics::CartesianMomentOfForce3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianMomentOfForce3dVector |
| mRef | attribute | CartesianMomentOfForce3dCoordinateFrame | ISQMechanics::CartesianMomentOfForce3dVector |
| ISQMechanics::CartesianMomentum3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianMomentum3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQMechanics::CartesianMomentum3dCoordinateFrame |
| mRefs | attribute | MomentumUnit | ISQMechanics::CartesianMomentum3dCoordinateFrame |
| ISQMechanics::CartesianMomentum3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianMomentum3dVector |
| mRef | attribute | CartesianMomentum3dCoordinateFrame | ISQMechanics::CartesianMomentum3dVector |
| ISQAtomicNuclear::CartesianParticleCurrentDensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianParticleCurrentDensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQAtomicNuclear::CartesianParticleCurrentDensity3dCoordinateFrame |
| mRefs | attribute | ParticleCurrentDensityUnit | ISQAtomicNuclear::CartesianParticleCurrentDensity3dCoordinateFrame |
| ISQAtomicNuclear::CartesianParticleCurrentDensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianParticleCurrentDensity3dVector |
| mRef | attribute | CartesianParticleCurrentDensity3dCoordinateFrame | ISQAtomicNuclear::CartesianParticleCurrentDensity3dVector |
| ISQCondensedMatter::CartesianParticlePosition3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQCondensedMatter::CartesianParticlePosition3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQCondensedMatter::CartesianParticlePosition3dVector |
| ISQSpaceTime::CartesianPosition3dVector | attribute def |  |  |
| x | attribute | LengthValue | ISQSpaceTime::CartesianPosition3dVector |
| y | attribute | LengthValue | ISQSpaceTime::CartesianPosition3dVector |
| z | attribute | LengthValue | ISQSpaceTime::CartesianPosition3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQSpaceTime::CartesianPosition3dVector |
| ISQElectromagnetism::CartesianPoynting3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianPoynting3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianPoynting3dCoordinateFrame |
| mRefs | attribute | PoyntingVectorMagnitudeUnit | ISQElectromagnetism::CartesianPoynting3dCoordinateFrame |
| ISQElectromagnetism::CartesianPoynting3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianPoynting3dVector |
| mRef | attribute | CartesianPoynting3dCoordinateFrame | ISQElectromagnetism::CartesianPoynting3dVector |
| ISQMechanics::CartesianRollingResistance3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianRollingResistance3dVector |
| mRef | attribute | CartesianForce3dCoordinateFrame | ISQMechanics::CartesianRollingResistance3dVector |
| ISQAcoustics::CartesianSoundIntensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQAcoustics::CartesianSoundIntensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQAcoustics::CartesianSoundIntensity3dCoordinateFrame |
| mRefs | attribute | SoundIntensityUnit | ISQAcoustics::CartesianSoundIntensity3dCoordinateFrame |
| ISQAcoustics::CartesianSoundIntensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAcoustics::CartesianSoundIntensity3dVector |
| mRef | attribute | CartesianSoundIntensity3dCoordinateFrame | ISQAcoustics::CartesianSoundIntensity3dVector |
| ISQAcoustics::CartesianSoundParticleAcceleration3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAcoustics::CartesianSoundParticleAcceleration3dVector |
| mRef | attribute | CartesianAcceleration3dCoordinateFrame | ISQAcoustics::CartesianSoundParticleAcceleration3dVector |
| ISQAcoustics::CartesianSoundParticleDisplacement3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAcoustics::CartesianSoundParticleDisplacement3dVector |
| mRef | attribute | CartesianSpatial3dCoordinateFrame | ISQAcoustics::CartesianSoundParticleDisplacement3dVector |
| ISQAcoustics::CartesianSoundParticleVelocity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAcoustics::CartesianSoundParticleVelocity3dVector |
| mRef | attribute | CartesianVelocity3dCoordinateFrame | ISQAcoustics::CartesianSoundParticleVelocity3dVector |
| ISQSpaceTime::CartesianSpatial3dCoordinateFrame | attribute def |  |  |
| xUnit | attribute | LengthUnit | ISQSpaceTime::CartesianSpatial3dCoordinateFrame |
| yUnit | attribute | LengthUnit | ISQSpaceTime::CartesianSpatial3dCoordinateFrame |
| zUnit | attribute | LengthUnit | ISQSpaceTime::CartesianSpatial3dCoordinateFrame |
| mRefs | attribute | LengthUnit | ISQSpaceTime::CartesianSpatial3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::CartesianSpatial3dCoordinateFrame |
| ISQAtomicNuclear::CartesianSpin3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianSpin3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQAtomicNuclear::CartesianSpin3dCoordinateFrame |
| mRefs | attribute | SpinUnit | ISQAtomicNuclear::CartesianSpin3dCoordinateFrame |
| ISQAtomicNuclear::CartesianSpin3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianSpin3dVector |
| mRef | attribute | CartesianSpin3dCoordinateFrame | ISQAtomicNuclear::CartesianSpin3dVector |
| ISQMechanics::CartesianStaticFrictionForce3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianStaticFrictionForce3dVector |
| mRef | attribute | CartesianForce3dCoordinateFrame | ISQMechanics::CartesianStaticFrictionForce3dVector |
| ISQAtomicNuclear::CartesianTotalAngularMomentum3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianTotalAngularMomentum3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQAtomicNuclear::CartesianTotalAngularMomentum3dCoordinateFrame |
| mRefs | attribute | TotalAngularMomentumUnit | ISQAtomicNuclear::CartesianTotalAngularMomentum3dCoordinateFrame |
| ISQAtomicNuclear::CartesianTotalAngularMomentum3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQAtomicNuclear::CartesianTotalAngularMomentum3dVector |
| mRef | attribute | CartesianTotalAngularMomentum3dCoordinateFrame | ISQAtomicNuclear::CartesianTotalAngularMomentum3dVector |
| ISQElectromagnetism::CartesianTotalCurrentDensity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianTotalCurrentDensity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQElectromagnetism::CartesianTotalCurrentDensity3dCoordinateFrame |
| mRefs | attribute | TotalCurrentDensityUnit | ISQElectromagnetism::CartesianTotalCurrentDensity3dCoordinateFrame |
| ISQElectromagnetism::CartesianTotalCurrentDensity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQElectromagnetism::CartesianTotalCurrentDensity3dVector |
| mRef | attribute | CartesianTotalCurrentDensity3dCoordinateFrame | ISQElectromagnetism::CartesianTotalCurrentDensity3dVector |
| ISQSpaceTime::CartesianVelocity3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianVelocity3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::CartesianVelocity3dCoordinateFrame |
| mRefs | attribute | SpeedUnit | ISQSpaceTime::CartesianVelocity3dCoordinateFrame |
| ISQSpaceTime::CartesianVelocity3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianVelocity3dVector |
| mRef | attribute | CartesianVelocity3dCoordinateFrame | ISQSpaceTime::CartesianVelocity3dVector |
| ISQSpaceTime::CartesianWave3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianWave3dVector |
| mRef | attribute | CartesianWaveVector3dCoordinateFrame | ISQSpaceTime::CartesianWave3dVector |
| ISQSpaceTime::CartesianWaveVector3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::CartesianWaveVector3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::CartesianWaveVector3dCoordinateFrame |
| mRefs | attribute | RepetencyUnit | ISQSpaceTime::CartesianWaveVector3dCoordinateFrame |
| ISQMechanics::CartesianWeight3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQMechanics::CartesianWeight3dVector |
| mRef | attribute | CartesianForce3dCoordinateFrame | ISQMechanics::CartesianWeight3dVector |
| ISQCharacteristicNumbers::CauchyNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::CavitationNumberValue | attribute def |  |  |
| ISQThermodynamics::CelsiusTemperatureUnit | attribute def |  |  |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::CelsiusTemperatureUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::CelsiusTemperatureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::CelsiusTemperatureValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::CelsiusTemperatureValue |
| mRef | attribute | CelsiusTemperatureUnit | ISQThermodynamics::CelsiusTemperatureValue |
| ISQCharacteristicNumbers::ChandrasekharNumberValue | attribute def |  |  |
| ISQInformation::ChannelCapacityPerCharacterUnit | attribute def |  |  |
| ISQInformation::ChannelCapacityPerCharacterValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::ChannelCapacityPerCharacterValue |
| mRef | attribute | ChannelCapacityPerCharacterUnit | ISQInformation::ChannelCapacityPerCharacterValue |
| ISQInformation::ChannelCapacityUnit | alias |  |  |
| ISQInformation::ChannelCapacityValue | alias |  |  |
| ISQInformation::ChannelTimeCapacityUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::ChannelTimeCapacityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::ChannelTimeCapacityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::ChannelTimeCapacityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::ChannelTimeCapacityValue |
| mRef | attribute | ChannelTimeCapacityUnit | ISQInformation::ChannelTimeCapacityValue |
| ISQInformation::CharacterMeanEntropyUnit | attribute def |  |  |
| ISQInformation::CharacterMeanEntropyValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::CharacterMeanEntropyValue |
| mRef | attribute | CharacterMeanEntropyUnit | ISQInformation::CharacterMeanEntropyValue |
| ISQInformation::CharacterMeanTransinformationContentUnit | attribute def |  |  |
| ISQInformation::CharacterMeanTransinformationContentValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::CharacterMeanTransinformationContentValue |
| mRef | attribute | CharacterMeanTransinformationContentUnit | ISQInformation::CharacterMeanTransinformationContentValue |
| ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesValue |
| mRef | attribute | CharacteristicImpedanceOfAMediumForLongitudinalWavesUnit | ISQAcoustics::CharacteristicImpedanceOfAMediumForLongitudinalWavesValue |
| ISQAtomicNuclear::ChargeNumberValue | attribute def |  |  |
| ISQChemistryMolecular::ChemicalPotentialUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::ChemicalPotentialUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::ChemicalPotentialValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::ChemicalPotentialValue |
| mRef | attribute | ChemicalPotentialUnit | ISQChemistryMolecular::ChemicalPotentialValue |
| ISQLight::ChromaticityCoordinatesInTheCie1931StandardColorimetricSystemValue | attribute def |  |  |
| ISQLight::ChromaticityCoordinatesInTheCie1964StandardColorimetricSystemValue | attribute def |  |  |
| ISQLight::CieColourMatchingFunctionsForTheCie1931StandardColorimetricObserverValue | attribute def |  |  |
| ISQLight::CieColourMatchingFunctionsForTheCie1964StandardColorimetricObserverValue | attribute def |  |  |
| ISQCharacteristicNumbers::ClausiusNumberValue | attribute def |  |  |
| ISQThermodynamics::CoefficientOfHeatTransferUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::CoefficientOfHeatTransferUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::CoefficientOfHeatTransferUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::CoefficientOfHeatTransferUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::CoefficientOfHeatTransferUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::CoefficientOfHeatTransferValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::CoefficientOfHeatTransferValue |
| mRef | attribute | CoefficientOfHeatTransferUnit | ISQThermodynamics::CoefficientOfHeatTransferValue |
| ISQThermodynamics::CoefficientOfThermalInsulanceUnit | alias |  |  |
| ISQThermodynamics::CoefficientOfThermalInsulanceValue | alias |  |  |
| ISQElectromagnetism::CoercivityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::CoercivityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::CoercivityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::CoercivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::CoercivityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::CoercivityValue |
| mRef | attribute | CoercivityUnit | ISQElectromagnetism::CoercivityValue |
| ISQInformation::CompletedCallIntensityUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::CompletedCallIntensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::CompletedCallIntensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::CompletedCallIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::CompletedCallIntensityValue |
| mRef | attribute | CompletedCallIntensityUnit | ISQInformation::CompletedCallIntensityValue |
| ScalarValues::Complex | datatype |  |  |
| ISQElectromagnetism::ComplexAdmittanceUnit | alias |  |  |
| ISQElectromagnetism::ComplexAdmittanceValue | alias |  |  |
| ISQElectromagnetism::ComplexImpedanceUnit | alias |  |  |
| ISQElectromagnetism::ComplexImpedanceValue | alias |  |  |
| ISQCharacteristicNumbers::CompressibilityNumberValue | attribute def |  |  |
| ISQMechanics::CompressibilityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::CompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::CompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::CompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::CompressibilityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::CompressibilityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::CompressibilityValue |
| mRef | attribute | CompressibilityUnit | ISQMechanics::CompressibilityValue |
| ISQInformation::ConditionalEntropyUnit | attribute def |  |  |
| ISQInformation::ConditionalEntropyValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::ConditionalEntropyValue |
| mRef | attribute | ConditionalEntropyUnit | ISQInformation::ConditionalEntropyValue |
| ISQInformation::ConditionalInformationContentUnit | attribute def |  |  |
| ISQInformation::ConditionalInformationContentValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::ConditionalInformationContentValue |
| mRef | attribute | ConditionalInformationContentUnit | ISQInformation::ConditionalInformationContentValue |
| ISQElectromagnetism::ConductanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ConductanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ConductanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ConductanceValue |
| mRef | attribute | ConductanceUnit | ISQElectromagnetism::ConductanceValue |
| ISQElectromagnetism::ConductivityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductivityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductivityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ConductivityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ConductivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ConductivityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ConductivityValue |
| mRef | attribute | ConductivityUnit | ISQElectromagnetism::ConductivityValue |
| ISQElectromagnetism::CouplingFactorValue | attribute def |  |  |
| ISQCharacteristicNumbers::CowlingNumberValue | attribute def |  |  |
| ISQThermodynamics::CubicExpansionCoefficientUnit | attribute def |  |  |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::CubicExpansionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::CubicExpansionCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::CubicExpansionCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::CubicExpansionCoefficientValue |
| mRef | attribute | CubicExpansionCoefficientUnit | ISQThermodynamics::CubicExpansionCoefficientValue |
| ISQSpaceTime::CurvatureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::CurvatureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::CurvatureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::CurvatureValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::CurvatureValue |
| mRef | attribute | CurvatureUnit | ISQSpaceTime::CurvatureValue |
| ISQSpaceTime::CylindricalDisplacement3dVector | attribute def |  |  |
| radialDistance | attribute | LengthValue | ISQSpaceTime::CylindricalDisplacement3dVector |
| azimuth | attribute | AngularMeasureUnit | ISQSpaceTime::CylindricalDisplacement3dVector |
| height | attribute | LengthValue | ISQSpaceTime::CylindricalDisplacement3dVector |
| mRef | attribute | CylindricalSpatial3dCoordinateFrame | ISQSpaceTime::CylindricalDisplacement3dVector |
| ISQSpaceTime::CylindricalPosition3dVector | attribute def |  |  |
| radialDistance | attribute | LengthValue | ISQSpaceTime::CylindricalPosition3dVector |
| azimuth | attribute | AngularMeasureUnit | ISQSpaceTime::CylindricalPosition3dVector |
| height | attribute | LengthValue | ISQSpaceTime::CylindricalPosition3dVector |
| mRef | attribute | CylindricalSpatial3dCoordinateFrame | ISQSpaceTime::CylindricalPosition3dVector |
| ISQSpaceTime::CylindricalSpatial3dCoordinateFrame | attribute def |  |  |
| radialDistanceUnit | attribute | LengthUnit | ISQSpaceTime::CylindricalSpatial3dCoordinateFrame |
| azimuthUnit | attribute | AngularMeasureUnit | ISQSpaceTime::CylindricalSpatial3dCoordinateFrame |
| zUnit | attribute | LengthUnit | ISQSpaceTime::CylindricalSpatial3dCoordinateFrame |
| mRefs | attribute | ScalarMeasurementReference | ISQSpaceTime::CylindricalSpatial3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::CylindricalSpatial3dCoordinateFrame |
| SI::'coulomb metre' | attribute | ElectricDipoleMomentUnit |  |
| SI::dalton | attribute | MassUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::dalton |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| isExact | attribute | Boolean | unitConversion |
| ISQSpaceTime::DampingCoefficientUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::DampingCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::DampingCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::DampingCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::DampingCoefficientValue |
| mRef | attribute | DampingCoefficientUnit | ISQSpaceTime::DampingCoefficientValue |
| ISQCharacteristicNumbers::DarcyFrictionFactorValue | attribute def |  |  |
| ISQCharacteristicNumbers::DeanNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::DeborahNumberValue | attribute def |  |  |
| ISQCondensedMatter::DebyeWallerFactorValue | attribute def |  |  |
| ISQAtomicNuclear::DecayConstantUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::DecayConstantUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::DecayConstantUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::DecayConstantValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::DecayConstantValue |
| mRef | attribute | DecayConstantUnit | ISQAtomicNuclear::DecayConstantValue |
| ISQInformation::DecisionContentValue | attribute def |  |  |
| ISQChemistryMolecular::DegeneracyValue | attribute def |  |  |
| ISQChemistryMolecular::DegreeOfDissociationValue | attribute def |  |  |
| ISQThermodynamics::DensityOfHeatFlowRateUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::DensityOfHeatFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::DensityOfHeatFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::DensityOfHeatFlowRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::DensityOfHeatFlowRateValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::DensityOfHeatFlowRateValue |
| mRef | attribute | DensityOfHeatFlowRateUnit | ISQThermodynamics::DensityOfHeatFlowRateValue |
| ISQCondensedMatter::DensityOfVibrationalStatesUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::DensityOfVibrationalStatesUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQCondensedMatter::DensityOfVibrationalStatesUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::DensityOfVibrationalStatesUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::DensityOfVibrationalStatesValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::DensityOfVibrationalStatesValue |
| mRef | attribute | DensityOfVibrationalStatesUnit | ISQCondensedMatter::DensityOfVibrationalStatesValue |
| ISQMechanics::DensityUnit | alias |  |  |
| ISQMechanics::DensityValue | alias |  |  |
| ISQAtomicNuclear::DiffusionCoefficientForParticleNumberDensityUnit | alias |  |  |
| ISQAtomicNuclear::DiffusionCoefficientForParticleNumberDensityValue | alias |  |  |
| ISQChemistryMolecular::DiffusionCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::DiffusionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::DiffusionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::DiffusionCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::DiffusionCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::DiffusionCoefficientValue |
| mRef | attribute | DiffusionCoefficientUnit | ISQChemistryMolecular::DiffusionCoefficientValue |
| ISQAtomicNuclear::DirectionAndEnergyDistributionOfCrossSectionUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::DirectionAndEnergyDistributionOfCrossSectionUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::DirectionAndEnergyDistributionOfCrossSectionUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::DirectionAndEnergyDistributionOfCrossSectionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::DirectionAndEnergyDistributionOfCrossSectionValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::DirectionAndEnergyDistributionOfCrossSectionValue |
| mRef | attribute | DirectionAndEnergyDistributionOfCrossSectionUnit | ISQAtomicNuclear::DirectionAndEnergyDistributionOfCrossSectionValue |
| ISQAtomicNuclear::DirectionDistributionOfCrossSectionUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::DirectionDistributionOfCrossSectionUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::DirectionDistributionOfCrossSectionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::DirectionDistributionOfCrossSectionValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::DirectionDistributionOfCrossSectionValue |
| mRef | attribute | DirectionDistributionOfCrossSectionUnit | ISQAtomicNuclear::DirectionDistributionOfCrossSectionValue |
| ISQAtomicNuclear::DisintegrationConstantUnit | alias |  |  |
| ISQAtomicNuclear::DisintegrationConstantValue | alias |  |  |
| ISQSpaceTime::Displacement3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::Displacement3dVector |
| mRef | attribute | Spatial3dCoordinateFrame | ISQSpaceTime::Displacement3dVector |
| ISQElectromagnetism::DisplacementCurrentDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::DisplacementCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::DisplacementCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::DisplacementCurrentDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::DisplacementCurrentDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::DisplacementCurrentDensityValue |
| mRef | attribute | DisplacementCurrentDensityUnit | ISQElectromagnetism::DisplacementCurrentDensityValue |
| ISQCondensedMatter::DonorDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::DonorDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::DonorDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::DonorDensityValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::DonorDensityValue |
| mRef | attribute | DonorDensityUnit | ISQCondensedMatter::DonorDensityValue |
| ISQAtomicNuclear::DoseEquivalentUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::DoseEquivalentUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::DoseEquivalentUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::DoseEquivalentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::DoseEquivalentValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::DoseEquivalentValue |
| mRef | attribute | DoseEquivalentUnit | ISQAtomicNuclear::DoseEquivalentValue |
| ISQMechanics::DragCoefficientValue | attribute def |  |  |
| ISQBase::DurationUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQBase::DurationUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQBase::DurationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQBase::DurationValue | attribute def |  |  |
| num | attribute | Real | ISQBase::DurationValue |
| mRef | attribute | DurationUnit | ISQBase::DurationValue |
| ISQCharacteristicNumbers::DynamicCapillaryNumberValue | attribute def |  |  |
| ISQMechanics::DynamicViscosityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::DynamicViscosityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::DynamicViscosityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::DynamicViscosityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::DynamicViscosityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::DynamicViscosityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::DynamicViscosityValue |
| mRef | attribute | DynamicViscosityUnit | ISQMechanics::DynamicViscosityValue |
| SI::erlang | attribute | TrafficIntensityUnit |  |
| ISQCharacteristicNumbers::EckertNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::EkmanNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::ElasticityNumberValue | attribute def |  |  |
| ISQElectromagnetism::ElectricChargeDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricChargeDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricChargeDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricChargeDensityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricChargeDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricChargeDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricChargeDensityValue |
| mRef | attribute | ElectricChargeDensityUnit | ISQElectromagnetism::ElectricChargeDensityValue |
| ISQElectromagnetism::ElectricChargeUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricChargeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricChargeValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricChargeValue |
| mRef | attribute | ElectricChargeUnit | ISQElectromagnetism::ElectricChargeValue |
| ISQElectromagnetism::ElectricConstantUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricConstantUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricConstantUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricConstantUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricConstantUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricConstantUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricConstantValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricConstantValue |
| mRef | attribute | ElectricConstantUnit | ISQElectromagnetism::ElectricConstantValue |
| ISQElectromagnetism::ElectricCurrentDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricCurrentDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricCurrentDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricCurrentDensityValue |
| mRef | attribute | ElectricCurrentDensityUnit | ISQElectromagnetism::ElectricCurrentDensityValue |
| ISQBase::ElectricCurrentUnit | attribute def |  |  |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQBase::ElectricCurrentUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQBase::ElectricCurrentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQBase::ElectricCurrentValue | attribute def |  |  |
| num | attribute | Real | ISQBase::ElectricCurrentValue |
| mRef | attribute | ElectricCurrentUnit | ISQBase::ElectricCurrentValue |
| ISQElectromagnetism::ElectricDipoleMomentUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricDipoleMomentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricDipoleMomentValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricDipoleMomentValue |
| mRef | attribute | ElectricDipoleMomentUnit | ISQElectromagnetism::ElectricDipoleMomentValue |
| ISQCharacteristicNumbers::ElectricFieldParameterValue | attribute def |  |  |
| ISQElectromagnetism::ElectricFieldStrengthUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFieldStrengthUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFieldStrengthUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFieldStrengthUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFieldStrengthUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricFieldStrengthUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricFieldStrengthValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricFieldStrengthValue |
| mRef | attribute | ElectricFieldStrengthUnit | ISQElectromagnetism::ElectricFieldStrengthValue |
| ISQElectromagnetism::ElectricFluxDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFluxDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFluxDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFluxDensityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricFluxDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricFluxDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricFluxDensityValue |
| mRef | attribute | ElectricFluxDensityUnit | ISQElectromagnetism::ElectricFluxDensityValue |
| ISQElectromagnetism::ElectricFluxUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFluxUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricFluxUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricFluxUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricFluxValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricFluxValue |
| mRef | attribute | ElectricFluxUnit | ISQElectromagnetism::ElectricFluxValue |
| ISQElectromagnetism::ElectricPolarizationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPolarizationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPolarizationUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPolarizationUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricPolarizationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricPolarizationValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricPolarizationValue |
| mRef | attribute | ElectricPolarizationUnit | ISQElectromagnetism::ElectricPolarizationValue |
| ISQElectromagnetism::ElectricPotentialDifferenceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialDifferenceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialDifferenceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialDifferenceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialDifferenceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricPotentialDifferenceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricPotentialDifferenceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricPotentialDifferenceValue |
| mRef | attribute | ElectricPotentialDifferenceUnit | ISQElectromagnetism::ElectricPotentialDifferenceValue |
| ISQElectromagnetism::ElectricPotentialUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectricPotentialUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectricPotentialUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectricPotentialValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectricPotentialValue |
| mRef | attribute | ElectricPotentialUnit | ISQElectromagnetism::ElectricPotentialValue |
| ISQElectromagnetism::ElectricSusceptibilityValue | attribute def |  |  |
| ISQChemistryMolecular::ElectrolyticConductivityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ElectrolyticConductivityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ElectrolyticConductivityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ElectrolyticConductivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ElectrolyticConductivityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::ElectrolyticConductivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::ElectrolyticConductivityValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::ElectrolyticConductivityValue |
| mRef | attribute | ElectrolyticConductivityUnit | ISQChemistryMolecular::ElectrolyticConductivityValue |
| ISQElectromagnetism::ElectromagneticEnergyDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectromagneticEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectromagneticEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ElectromagneticEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ElectromagneticEnergyDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ElectromagneticEnergyDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ElectromagneticEnergyDensityValue |
| mRef | attribute | ElectromagneticEnergyDensityUnit | ISQElectromagnetism::ElectromagneticEnergyDensityValue |
| ISQCondensedMatter::ElectronDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::ElectronDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::ElectronDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::ElectronDensityValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::ElectronDensityValue |
| mRef | attribute | ElectronDensityUnit | ISQCondensedMatter::ElectronDensityValue |
| ISQLight::EmissivityAtASpecifiedWavelengthValue | attribute def |  |  |
| ISQLight::EmissivityValue | attribute def |  |  |
| ISQCondensedMatter::EnergyDensityOfStatesUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::EnergyDensityOfStatesUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQCondensedMatter::EnergyDensityOfStatesUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQCondensedMatter::EnergyDensityOfStatesUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::EnergyDensityOfStatesUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::EnergyDensityOfStatesValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::EnergyDensityOfStatesValue |
| mRef | attribute | EnergyDensityOfStatesUnit | ISQCondensedMatter::EnergyDensityOfStatesValue |
| ISQAtomicNuclear::EnergyDistributionOfCrossSectionUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::EnergyDistributionOfCrossSectionUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::EnergyDistributionOfCrossSectionUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::EnergyDistributionOfCrossSectionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::EnergyDistributionOfCrossSectionValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::EnergyDistributionOfCrossSectionValue |
| mRef | attribute | EnergyDistributionOfCrossSectionUnit | ISQAtomicNuclear::EnergyDistributionOfCrossSectionValue |
| ISQAtomicNuclear::EnergyFluenceRateUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::EnergyFluenceRateUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::EnergyFluenceRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::EnergyFluenceRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::EnergyFluenceRateValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::EnergyFluenceRateValue |
| mRef | attribute | EnergyFluenceRateUnit | ISQAtomicNuclear::EnergyFluenceRateValue |
| ISQAtomicNuclear::EnergyFluenceUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::EnergyFluenceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::EnergyFluenceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::EnergyFluenceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::EnergyFluenceValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::EnergyFluenceValue |
| mRef | attribute | EnergyFluenceUnit | ISQAtomicNuclear::EnergyFluenceValue |
| ISQThermodynamics::EnergyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::EnergyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::EnergyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::EnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::EnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::EnergyValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::EnergyValue |
| mRef | attribute | EnergyUnit | ISQThermodynamics::EnergyValue |
| ISQInformation::EntropyForInformationScienceUnit | attribute def |  |  |
| ISQInformation::EntropyForInformationScienceValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::EntropyForInformationScienceValue |
| mRef | attribute | EntropyForInformationScienceUnit | ISQInformation::EntropyForInformationScienceValue |
| ISQThermodynamics::EntropyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::EntropyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::EntropyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::EntropyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::EntropyUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::EntropyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::EntropyValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::EntropyValue |
| mRef | attribute | EntropyUnit | ISQThermodynamics::EntropyValue |
| ISQChemistryMolecular::EquilibriumConstantOnConcentrationBasisUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::EquilibriumConstantOnConcentrationBasisUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::EquilibriumConstantOnConcentrationBasisUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::EquilibriumConstantOnConcentrationBasisUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::EquilibriumConstantOnConcentrationBasisValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::EquilibriumConstantOnConcentrationBasisValue |
| mRef | attribute | EquilibriumConstantOnConcentrationBasisUnit | ISQChemistryMolecular::EquilibriumConstantOnConcentrationBasisValue |
| ISQChemistryMolecular::EquilibriumConstantOnPressureBasisUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::EquilibriumConstantOnPressureBasisUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::EquilibriumConstantOnPressureBasisUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::EquilibriumConstantOnPressureBasisUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::EquilibriumConstantOnPressureBasisUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::EquilibriumConstantOnPressureBasisValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::EquilibriumConstantOnPressureBasisValue |
| mRef | attribute | EquilibriumConstantOnPressureBasisUnit | ISQChemistryMolecular::EquilibriumConstantOnPressureBasisValue |
| ISQInformation::EquivalentBinaryDigitRateUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::EquivalentBinaryDigitRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::EquivalentBinaryDigitRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::EquivalentBinaryDigitRateValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::EquivalentBinaryDigitRateValue |
| mRef | attribute | EquivalentBinaryDigitRateUnit | ISQInformation::EquivalentBinaryDigitRateValue |
| ISQInformation::EquivalentBinaryStorageCapacityUnit | attribute def |  |  |
| ISQInformation::EquivalentBinaryStorageCapacityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::EquivalentBinaryStorageCapacityValue |
| mRef | attribute | EquivalentBinaryStorageCapacityUnit | ISQInformation::EquivalentBinaryStorageCapacityValue |
| ISQInformation::EquivalentBitRateUnit | alias |  |  |
| ISQInformation::EquivalentBitRateValue | alias |  |  |
| ISQInformation::EquivocationUnit | attribute def |  |  |
| ISQInformation::EquivocationValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::EquivocationValue |
| mRef | attribute | EquivocationUnit | ISQInformation::EquivocationValue |
| ISQInformation::ErrorProbabilityValue | attribute def |  |  |
| ISQCharacteristicNumbers::EulerNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::ExpansionNumberValue | attribute def |  |  |
| ISQAtomicNuclear::ExposureRateUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ExposureRateUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ExposureRateUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ExposureRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ExposureRateValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ExposureRateValue |
| mRef | attribute | ExposureRateUnit | ISQAtomicNuclear::ExposureRateValue |
| ISQAtomicNuclear::ExposureUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ExposureUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ExposureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ExposureUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ExposureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ExposureValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ExposureValue |
| mRef | attribute | ExposureUnit | ISQAtomicNuclear::ExposureValue |
| ISQSpaceTime::ExtinctionUnit | alias |  |  |
| ISQSpaceTime::ExtinctionValue | alias |  |  |
| SI::farad | attribute | CapacitanceUnit |  |
| SI::'farad per metre' | attribute | ElectricConstantUnit |  |
| ISQCharacteristicNumbers::FanningNumberValue | attribute def |  |  |
| ISQAtomicNuclear::FastFissionFactorUnit | attribute def |  |  |
| ISQAtomicNuclear::FastFissionFactorValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::FastFissionFactorValue |
| mRef | attribute | FastFissionFactorUnit | ISQAtomicNuclear::FastFissionFactorValue |
| ISQMechanics::ForceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::ForceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::ForceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::ForceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::ForceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::ForceValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::ForceValue |
| mRef | attribute | ForceUnit | ISQMechanics::ForceValue |
| ISQCharacteristicNumbers::FourierNumberForMassTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::FourierNumberValue | attribute def |  |  |
| ISQSpaceTime::FrequencyUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::FrequencyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::FrequencyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::FrequencyValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::FrequencyValue |
| mRef | attribute | FrequencyUnit | ISQSpaceTime::FrequencyValue |
| ISQCharacteristicNumbers::FroudeNumberForHeatTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::FroudeNumberValue | attribute def |  |  |
| ISQChemistryMolecular::FugacityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::FugacityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::FugacityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::FugacityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::FugacityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::FugacityValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::FugacityValue |
| mRef | attribute | FugacityUnit | ISQChemistryMolecular::FugacityValue |
| ISQCondensedMatter::FundamentalReciprocalLatticeVectorMagnitudeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::FundamentalReciprocalLatticeVectorMagnitudeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::FundamentalReciprocalLatticeVectorMagnitudeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::FundamentalReciprocalLatticeVectorMagnitudeValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::FundamentalReciprocalLatticeVectorMagnitudeValue |
| mRef | attribute | FundamentalReciprocalLatticeVectorMagnitudeUnit | ISQCondensedMatter::FundamentalReciprocalLatticeVectorMagnitudeValue |
| ISQAtomicNuclear::GFactorOfNucleusOrNuclearParticleValue | attribute def |  |  |
| SI::gigajoule | attribute | EnergyUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::gigajoule |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| ISQCharacteristicNumbers::GalileiNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::GoertlerNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::GraetzNumberForMassTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::GraetzNumberValue | attribute def |  |  |
| ISQChemistryMolecular::GrandCanonicalPartitionFunctionValue | attribute def |  |  |
| ISQCharacteristicNumbers::GrashofMagneticNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::GrashofNumberForMassTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::GrashofNumberValue | attribute def |  |  |
| ISQCondensedMatter::'GrüneisenParameterValue' | attribute def |  |  |
| SI::gray | attribute | AbsorbedDoseUnit |  |
| SI::'gray per second' | attribute | AbsorbedDoseRateUnit |  |
| ISQAtomicNuclear::GyromagneticCoefficientOfTheElectronUnit | alias |  |  |
| ISQAtomicNuclear::GyromagneticCoefficientOfTheElectronValue | alias |  |  |
| ISQAtomicNuclear::GyromagneticCoefficientUnit | alias |  |  |
| ISQAtomicNuclear::GyromagneticCoefficientValue | alias |  |  |
| ISQAtomicNuclear::GyromagneticRatioOfTheElectronUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::GyromagneticRatioOfTheElectronUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::GyromagneticRatioOfTheElectronUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::GyromagneticRatioOfTheElectronUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::GyromagneticRatioOfTheElectronUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::GyromagneticRatioOfTheElectronValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::GyromagneticRatioOfTheElectronValue |
| mRef | attribute | GyromagneticRatioOfTheElectronUnit | ISQAtomicNuclear::GyromagneticRatioOfTheElectronValue |
| ISQAtomicNuclear::GyromagneticRatioUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::GyromagneticRatioUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::GyromagneticRatioUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::GyromagneticRatioUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::GyromagneticRatioUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::GyromagneticRatioValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::GyromagneticRatioValue |
| mRef | attribute | GyromagneticRatioUnit | ISQAtomicNuclear::GyromagneticRatioValue |
| SI::henry | attribute | PermeanceUnit, InductanceUnit |  |
| quantityDimension | attribute | QuantityDimension | SI::henry |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| SI::'henry per metre' | attribute | MagneticConstantUnit |  |
| ISQCharacteristicNumbers::HagenNumberValue | attribute def |  |  |
| ISQCondensedMatter::HallCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::HallCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQCondensedMatter::HallCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQCondensedMatter::HallCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::HallCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::HallCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::HallCoefficientValue |
| mRef | attribute | HallCoefficientUnit | ISQCondensedMatter::HallCoefficientValue |
| ISQCharacteristicNumbers::HallNumberValue | attribute def |  |  |
| SI::hartley | attribute | InformationContentUnit |  |
| SI::'hartley per second' | attribute | AverageInformationRateUnit |  |
| ISQCharacteristicNumbers::HartmannNumberValue | attribute def |  |  |
| ISQAtomicNuclear::HartreeEnergyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::HartreeEnergyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::HartreeEnergyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::HartreeEnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::HartreeEnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::HartreeEnergyValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::HartreeEnergyValue |
| mRef | attribute | HartreeEnergyUnit | ISQAtomicNuclear::HartreeEnergyValue |
| ISQThermodynamics::HeatCapacityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::HeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::HeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::HeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::HeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::HeatCapacityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::HeatCapacityValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::HeatCapacityValue |
| mRef | attribute | HeatCapacityUnit | ISQThermodynamics::HeatCapacityValue |
| ISQThermodynamics::HeatFlowRateUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::HeatFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::HeatFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::HeatFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::HeatFlowRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::HeatFlowRateValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::HeatFlowRateValue |
| mRef | attribute | HeatFlowRateUnit | ISQThermodynamics::HeatFlowRateValue |
| ISQCharacteristicNumbers::HeatTransferNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::'HedströmNumberValue' | attribute def |  |  |
| ISQCondensedMatter::HoleDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::HoleDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::HoleDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::HoleDensityValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::HoleDensityValue |
| mRef | attribute | HoleDensityUnit | ISQCondensedMatter::HoleDensityValue |
| ISQCharacteristicNumbers::HookeNumberValue | attribute def |  |  |
| SI::hertz | attribute | FrequencyUnit |  |
| SI::'henry to the power minus 1' | attribute | ReluctanceUnit |  |
| SI::'ISO/IEC 80000 International System of Units' | attribute | SystemOfUnits |  |
| systemOfQuantities | attribute | SystemOfQuantities | SI::'ISO/IEC 80000 International System of Units' |
| baseUnits | attribute | SimpleUnit | SI::'ISO/IEC 80000 International System of Units' |
| ISQLight::IlluminanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::IlluminanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::IlluminanceUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::IlluminanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::IlluminanceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::IlluminanceValue |
| mRef | attribute | IlluminanceUnit | ISQLight::IlluminanceValue |
| ISQElectromagnetism::ImpedanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ImpedanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ImpedanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ImpedanceValue |
| mRef | attribute | ImpedanceUnit | ISQElectromagnetism::ImpedanceValue |
| ISQMechanics::ImpulseUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::ImpulseUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::ImpulseUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::ImpulseUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::ImpulseUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::ImpulseValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::ImpulseValue |
| mRef | attribute | ImpulseUnit | ISQMechanics::ImpulseValue |
| ISQElectromagnetism::InductanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::InductanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::InductanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::InductanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::InductanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::InductanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::InductanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::InductanceValue |
| mRef | attribute | InductanceUnit | ISQElectromagnetism::InductanceValue |
| ISQAtomicNuclear::InfiniteMultiplicationFactorUnit | attribute def |  |  |
| ISQAtomicNuclear::InfiniteMultiplicationFactorValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::InfiniteMultiplicationFactorValue |
| mRef | attribute | InfiniteMultiplicationFactorUnit | ISQAtomicNuclear::InfiniteMultiplicationFactorValue |
| ISQInformation::InformationContentUnit | attribute def |  |  |
| ISQInformation::InformationContentValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::InformationContentValue |
| mRef | attribute | InformationContentUnit | ISQInformation::InformationContentValue |
| ScalarValues::Integer | datatype |  |  |
| ISQAtomicNuclear::InternalConversionFactorValue | attribute def |  |  |
| ISQBase::'International System of Quantities' | attribute | SystemOfQuantities |  |
| baseQuantities | attribute | ScalarQuantityValue | ISQBase::'International System of Quantities' |
| L | attribute | LengthValue | ISQBase::'International System of Quantities' |
| M | attribute | MassValue | ISQBase::'International System of Quantities' |
| T | attribute | DurationValue | ISQBase::'International System of Quantities' |
| I | attribute | ElectricCurrentValue | ISQBase::'International System of Quantities' |
| 'Θ' | attribute | ThermodynamicTemperatureValue | ISQBase::'International System of Quantities' |
| N | attribute | AmountOfSubstanceValue | ISQBase::'International System of Quantities' |
| J | attribute | LuminousIntensityValue | ISQBase::'International System of Quantities' |
| ISQCondensedMatter::IntrinsicCarrierDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::IntrinsicCarrierDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::IntrinsicCarrierDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::IntrinsicCarrierDensityValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::IntrinsicCarrierDensityValue |
| mRef | attribute | IntrinsicCarrierDensityUnit | ISQCondensedMatter::IntrinsicCarrierDensityValue |
| ISQAtomicNuclear::IonDensityUnit | alias |  |  |
| ISQAtomicNuclear::IonDensityValue | alias |  |  |
| ISQAtomicNuclear::IonNumberDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::IonNumberDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::IonNumberDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::IonNumberDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::IonNumberDensityValue |
| mRef | attribute | IonNumberDensityUnit | ISQAtomicNuclear::IonNumberDensityValue |
| ISQChemistryMolecular::IonicStrengthUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::IonicStrengthUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::IonicStrengthUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::IonicStrengthUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::IonicStrengthValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::IonicStrengthValue |
| mRef | attribute | IonicStrengthUnit | ISQChemistryMolecular::IonicStrengthValue |
| ISQLight::IrradianceUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQLight::IrradianceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::IrradianceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::IrradianceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::IrradianceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::IrradianceValue |
| mRef | attribute | IrradianceUnit | ISQLight::IrradianceValue |
| ISQInformation::IrrelevanceUnit | attribute def |  |  |
| ISQInformation::IrrelevanceValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::IrrelevanceValue |
| mRef | attribute | IrrelevanceUnit | ISQInformation::IrrelevanceValue |
| ISQThermodynamics::IsentropicCompressibilityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::IsentropicCompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::IsentropicCompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::IsentropicCompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::IsentropicCompressibilityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::IsentropicCompressibilityValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::IsentropicCompressibilityValue |
| mRef | attribute | IsentropicCompressibilityUnit | ISQThermodynamics::IsentropicCompressibilityValue |
| ISQThermodynamics::IsentropicExponentValue | attribute def |  |  |
| ISQThermodynamics::IsothermalCompressibilityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::IsothermalCompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::IsothermalCompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::IsothermalCompressibilityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::IsothermalCompressibilityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::IsothermalCompressibilityValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::IsothermalCompressibilityValue |
| mRef | attribute | IsothermalCompressibilityUnit | ISQThermodynamics::IsothermalCompressibilityValue |
| SI::joule | attribute | EnergyUnit |  |
| SI::'joule per kilogram kelvin' | attribute | SpecificHeatCapacityUnit |  |
| SI::'joule per mole kelvin' | attribute | MolarHeatCapacityUnit |  |
| SI::'joule per square metre nm' | attribute | SpectralRadiantExposureUnit |  |
| SI::'joule per cubic metre nm' | attribute | SpectralRadiantEnergyDensityInTermsOfWavelengthUnit |  |
| SI::'joule per kelvin' | attribute | HeatCapacityUnit |  |
| SI::'joule per kilogram' | attribute | SpecificEnergyUnit |  |
| SI::'joule per metre' | attribute | TotalLinearStoppingPowerUnit |  |
| SI::'joule per mole' | attribute | MolarInternalEnergyUnit |  |
| SI::'joule per square metre' | attribute | SpectralRadiantEnergyDensityInTermsOfWavenumberUnit |  |
| SI::'joule per cubic metre' | attribute | ElectromagneticEnergyDensityUnit |  |
| SI::'joule per nm' | attribute | SpectralRadiantEnergyUnit |  |
| SI::'joule per second' | attribute | HeatFlowRateUnit |  |
| ISQCharacteristicNumbers::JFactorValue | attribute def |  |  |
| ISQInformation::JointInformationContentUnit | attribute def |  |  |
| ISQInformation::JointInformationContentValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::JointInformationContentValue |
| mRef | attribute | JointInformationContentUnit | ISQInformation::JointInformationContentValue |
| ISQCharacteristicNumbers::JouleMagneticNumberValue | attribute def |  |  |
| ISQThermodynamics::JouleThomsonCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::JouleThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::JouleThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::JouleThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::JouleThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::JouleThomsonCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::JouleThomsonCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::JouleThomsonCoefficientValue |
| mRef | attribute | JouleThomsonCoefficientUnit | ISQThermodynamics::JouleThomsonCoefficientValue |
| SI::'joule to the power minus 1 metre to the power minus 3 electronvolt to the power minus 1 metre to the power minus 3' | attribute | EnergyDensityOfStatesUnit |  |
| SI::'joule metre squared per kilogram' | attribute | TotalMassStoppingPowerUnit |  |
| SI::'joule second' | attribute | ActionQuantityUnit |  |
| SI::'joule second to the power minus 1' | attribute | PowerUnit |  |
| SI::'joule second electronvolt second' | attribute | TotalAngularMomentumUnit |  |
| SI::kelvin | attribute | ThermodynamicTemperatureUnit, TemperatureDifferenceUnit |  |
| temperatureOfWaterAtTriplePointInK | attribute | DefinitionalQuantityValue | SI::kelvin |
| num | attribute | Number | temperatureOfWaterAtTriplePointInK |
| definition | attribute | String | temperatureOfWaterAtTriplePointInK |
| definitionalQuantityValues | attribute | DefinitionalQuantityValue | SI::kelvin |
| quantityDimension | attribute | QuantityDimension | SI::kelvin |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| SI::'kelvin per pascal' | attribute | JouleThomsonCoefficientUnit |  |
| SI::'kelvin per watt' | attribute | ThermalResistanceUnit |  |
| ISQAtomicNuclear::KermaRateUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::KermaRateUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::KermaRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::KermaRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::KermaRateValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::KermaRateValue |
| mRef | attribute | KermaRateUnit | ISQAtomicNuclear::KermaRateValue |
| ISQAtomicNuclear::KermaUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::KermaUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::KermaUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::KermaUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::KermaValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::KermaValue |
| mRef | attribute | KermaUnit | ISQAtomicNuclear::KermaValue |
| ISQMechanics::KinematicViscosityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::KinematicViscosityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::KinematicViscosityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::KinematicViscosityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::KinematicViscosityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::KinematicViscosityValue |
| mRef | attribute | KinematicViscosityUnit | ISQMechanics::KinematicViscosityValue |
| ISQMechanics::KineticFrictionFactorValue | attribute def |  |  |
| ISQCharacteristicNumbers::KnudsenNumberValue | attribute def |  |  |
| SI::'kelvin to the power minus 1' | attribute | LinearExpansionCoefficientUnit |  |
| SI::litre | attribute | VolumeUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::litre |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| ISQCharacteristicNumbers::LagrangeNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::LandauGinzburgNumberValue | attribute def |  |  |
| ISQAtomicNuclear::LandeFactorValue | attribute def |  |  |
| ISQCharacteristicNumbers::LaplaceNumberValue | attribute def |  |  |
| ISQAtomicNuclear::LarmorFrequencyUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::LarmorFrequencyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::LarmorFrequencyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::LarmorFrequencyValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::LarmorFrequencyValue |
| mRef | attribute | LarmorFrequencyUnit | ISQAtomicNuclear::LarmorFrequencyValue |
| ISQCharacteristicNumbers::LavalNumberValue | attribute def |  |  |
| ISQElectromagnetism::LeakageFactorValue | attribute def |  |  |
| ISQBase::LengthUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQBase::LengthUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQBase::LengthUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQBase::LengthValue | attribute def |  |  |
| num | attribute | Real | ISQBase::LengthValue |
| mRef | attribute | LengthUnit | ISQBase::LengthValue |
| ISQAtomicNuclear::LethargyValue | attribute def |  |  |
| ISQCharacteristicNumbers::LewisNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::LiftCoefficientValue | attribute def |  |  |
| ISQLight::LightExposureUnit | alias |  |  |
| ISQLight::LightExposureValue | alias |  |  |
| ISQElectromagnetism::LightSpeedUnit | alias |  |  |
| ISQElectromagnetism::LightSpeedValue | alias |  |  |
| ISQInformation::LineDigitRateUnit | alias |  |  |
| ISQInformation::LineDigitRateValue | alias |  |  |
| ISQLight::LinearAbsorptionCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::LinearAbsorptionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LinearAbsorptionCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LinearAbsorptionCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LinearAbsorptionCoefficientValue |
| mRef | attribute | LinearAbsorptionCoefficientUnit | ISQLight::LinearAbsorptionCoefficientValue |
| ISQAtomicNuclear::LinearAttenuationCoefficientForIonizingRadiationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::LinearAttenuationCoefficientForIonizingRadiationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::LinearAttenuationCoefficientForIonizingRadiationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::LinearAttenuationCoefficientForIonizingRadiationValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::LinearAttenuationCoefficientForIonizingRadiationValue |
| mRef | attribute | LinearAttenuationCoefficientForIonizingRadiationUnit | ISQAtomicNuclear::LinearAttenuationCoefficientForIonizingRadiationValue |
| ISQLight::LinearAttenuationCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::LinearAttenuationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LinearAttenuationCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LinearAttenuationCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LinearAttenuationCoefficientValue |
| mRef | attribute | LinearAttenuationCoefficientUnit | ISQLight::LinearAttenuationCoefficientValue |
| ISQElectromagnetism::LinearDensityOfElectricChargeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinearDensityOfElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinearDensityOfElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinearDensityOfElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::LinearDensityOfElectricChargeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::LinearDensityOfElectricChargeValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::LinearDensityOfElectricChargeValue |
| mRef | attribute | LinearDensityOfElectricChargeUnit | ISQElectromagnetism::LinearDensityOfElectricChargeValue |
| ISQMechanics::LinearDensityUnit | alias |  |  |
| ISQMechanics::LinearDensityValue | alias |  |  |
| ISQElectromagnetism::LinearElectricCurrentDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinearElectricCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinearElectricCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::LinearElectricCurrentDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::LinearElectricCurrentDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::LinearElectricCurrentDensityValue |
| mRef | attribute | LinearElectricCurrentDensityUnit | ISQElectromagnetism::LinearElectricCurrentDensityValue |
| ISQAtomicNuclear::LinearEnergyTransferUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::LinearEnergyTransferUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::LinearEnergyTransferUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::LinearEnergyTransferUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::LinearEnergyTransferUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::LinearEnergyTransferValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::LinearEnergyTransferValue |
| mRef | attribute | LinearEnergyTransferUnit | ISQAtomicNuclear::LinearEnergyTransferValue |
| ISQThermodynamics::LinearExpansionCoefficientUnit | attribute def |  |  |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::LinearExpansionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::LinearExpansionCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::LinearExpansionCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::LinearExpansionCoefficientValue |
| mRef | attribute | LinearExpansionCoefficientUnit | ISQThermodynamics::LinearExpansionCoefficientValue |
| ISQLight::LinearExtinctionCoefficientUnit | alias |  |  |
| ISQLight::LinearExtinctionCoefficientValue | alias |  |  |
| ISQAtomicNuclear::LinearIonizationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::LinearIonizationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::LinearIonizationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::LinearIonizationValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::LinearIonizationValue |
| mRef | attribute | LinearIonizationUnit | ISQAtomicNuclear::LinearIonizationValue |
| ISQMechanics::LinearMassDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::LinearMassDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::LinearMassDensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::LinearMassDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::LinearMassDensityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::LinearMassDensityValue |
| mRef | attribute | LinearMassDensityUnit | ISQMechanics::LinearMassDensityValue |
| ISQAtomicNuclear::LinearStoppingPowerUnit | alias |  |  |
| ISQAtomicNuclear::LinearStoppingPowerValue | alias |  |  |
| ISQElectromagnetism::LineicElectricChargeUnit | alias |  |  |
| ISQElectromagnetism::LineicElectricChargeValue | alias |  |  |
| ISQElectromagnetism::LinkedFluxUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinkedFluxUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinkedFluxUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinkedFluxUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::LinkedFluxUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::LinkedFluxUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::LinkedFluxValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::LinkedFluxValue |
| mRef | attribute | LinkedFluxUnit | ISQElectromagnetism::LinkedFluxValue |
| ISQCharacteristicNumbers::LockhartMartinelliParameterValue | attribute def |  |  |
| ISQSpaceTime::LogarithmicDecrementValue | attribute def |  |  |
| ISQAcoustics::LogarithmicFrequencyRangeUnit | attribute def |  |  |
| ISQAcoustics::LogarithmicFrequencyRangeValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::LogarithmicFrequencyRangeValue |
| mRef | attribute | LogarithmicFrequencyRangeUnit | ISQAcoustics::LogarithmicFrequencyRangeValue |
| ISQCondensedMatter::LongRangeOrderParameterValue | attribute def |  |  |
| ISQCharacteristicNumbers::LorentzNumberValue | attribute def |  |  |
| ISQCondensedMatter::LorenzCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::LorenzCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQCondensedMatter::LorenzCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQCondensedMatter::LorenzCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQCondensedMatter::LorenzCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQCondensedMatter::LorenzCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::LorenzCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::LorenzCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::LorenzCoefficientValue |
| mRef | attribute | LorenzCoefficientUnit | ISQCondensedMatter::LorenzCoefficientValue |
| ISQElectromagnetism::LossFactorValue | attribute def |  |  |
| ISQInformation::LossProbabilityValue | attribute def |  |  |
| ISQLight::LuminanceFactorValue | attribute def |  |  |
| ISQLight::LuminanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::LuminanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::LuminanceUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LuminanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LuminanceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LuminanceValue |
| mRef | attribute | LuminanceUnit | ISQLight::LuminanceValue |
| ISQLight::LuminousAbsorptanceValue | attribute def |  |  |
| ISQLight::LuminousEfficacyOfASourceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfASourceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfASourceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfASourceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfASourceUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LuminousEfficacyOfASourceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LuminousEfficacyOfASourceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LuminousEfficacyOfASourceValue |
| mRef | attribute | LuminousEfficacyOfASourceUnit | ISQLight::LuminousEfficacyOfASourceValue |
| ISQLight::LuminousEfficacyOfRadiationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfRadiationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfRadiationUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfRadiationUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::LuminousEfficacyOfRadiationUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LuminousEfficacyOfRadiationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LuminousEfficacyOfRadiationValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LuminousEfficacyOfRadiationValue |
| mRef | attribute | LuminousEfficacyOfRadiationUnit | ISQLight::LuminousEfficacyOfRadiationValue |
| ISQLight::LuminousEfficiencyValue | attribute def |  |  |
| ISQLight::LuminousEnergyUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQLight::LuminousEnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::LuminousEnergyUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LuminousEnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LuminousEnergyValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LuminousEnergyValue |
| mRef | attribute | LuminousEnergyUnit | ISQLight::LuminousEnergyValue |
| ISQLight::LuminousExitanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::LuminousExitanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::LuminousExitanceUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LuminousExitanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LuminousExitanceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LuminousExitanceValue |
| mRef | attribute | LuminousExitanceUnit | ISQLight::LuminousExitanceValue |
| ISQLight::LuminousExposureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::LuminousExposureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::LuminousExposureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::LuminousExposureUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LuminousExposureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LuminousExposureValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LuminousExposureValue |
| mRef | attribute | LuminousExposureUnit | ISQLight::LuminousExposureValue |
| ISQLight::LuminousFluxUnit | attribute def |  |  |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::LuminousFluxUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::LuminousFluxUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::LuminousFluxValue | attribute def |  |  |
| num | attribute | Real | ISQLight::LuminousFluxValue |
| mRef | attribute | LuminousFluxUnit | ISQLight::LuminousFluxValue |
| ISQBase::LuminousIntensityUnit | attribute def |  |  |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQBase::LuminousIntensityUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQBase::LuminousIntensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQBase::LuminousIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQBase::LuminousIntensityValue |
| mRef | attribute | LuminousIntensityUnit | ISQBase::LuminousIntensityValue |
| ISQLight::LuminousReflectanceValue | attribute def |  |  |
| ISQLight::LuminousTransmittanceValue | attribute def |  |  |
| ISQCharacteristicNumbers::LundquistNumberValue | attribute def |  |  |
| SI::megajoule | attribute | EnergyUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::megajoule |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| ISQCharacteristicNumbers::MachNumberValue | attribute def |  |  |
| ISQAtomicNuclear::MacroscopicCrossSectionUnit | alias |  |  |
| ISQAtomicNuclear::MacroscopicCrossSectionValue | alias |  |  |
| ISQAtomicNuclear::MacroscopicTotalCrossSectionUnit | alias |  |  |
| ISQAtomicNuclear::MacroscopicTotalCrossSectionValue | alias |  |  |
| ISQElectromagnetism::MagneticConstantUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticConstantUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticConstantUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticConstantUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticConstantUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticConstantUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticConstantValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticConstantValue |
| mRef | attribute | MagneticConstantUnit | ISQElectromagnetism::MagneticConstantValue |
| ISQAtomicNuclear::MagneticDipoleMomentUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MagneticDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MagneticDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::MagneticDipoleMomentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticDipoleMomentUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticDipoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticDipoleMomentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::MagneticDipoleMomentValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::MagneticDipoleMomentValue |
| mRef | attribute | MagneticDipoleMomentUnit | ISQAtomicNuclear::MagneticDipoleMomentValue |
| ISQElectromagnetism::MagneticDipoleMomentValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticDipoleMomentValue |
| mRef | attribute | MagneticDipoleMomentUnit | ISQElectromagnetism::MagneticDipoleMomentValue |
| ISQElectromagnetism::MagneticFieldStrengthUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFieldStrengthUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFieldStrengthUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticFieldStrengthUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticFieldStrengthValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticFieldStrengthValue |
| mRef | attribute | MagneticFieldStrengthUnit | ISQElectromagnetism::MagneticFieldStrengthValue |
| ISQElectromagnetism::MagneticFluxDensityUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFluxDensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFluxDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFluxDensityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticFluxDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticFluxDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticFluxDensityValue |
| mRef | attribute | MagneticFluxDensityUnit | ISQElectromagnetism::MagneticFluxDensityValue |
| ISQElectromagnetism::MagneticFluxUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFluxUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFluxUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFluxUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticFluxUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticFluxUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticFluxValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticFluxValue |
| mRef | attribute | MagneticFluxUnit | ISQElectromagnetism::MagneticFluxValue |
| ISQElectromagnetism::MagneticMomentUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticMomentUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticMomentUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticMomentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticMomentValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticMomentValue |
| mRef | attribute | MagneticMomentUnit | ISQElectromagnetism::MagneticMomentValue |
| ISQCharacteristicNumbers::MagneticNumberValue | attribute def |  |  |
| ISQElectromagnetism::MagneticPolarizationUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticPolarizationUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticPolarizationUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticPolarizationUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticPolarizationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticPolarizationValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticPolarizationValue |
| mRef | attribute | MagneticPolarizationUnit | ISQElectromagnetism::MagneticPolarizationValue |
| ISQCharacteristicNumbers::MagneticPressureNumberValue | attribute def |  |  |
| ISQElectromagnetism::MagneticSusceptibilityValue | attribute def |  |  |
| ISQElectromagnetism::MagneticVectorPotentialUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticVectorPotentialUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticVectorPotentialUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticVectorPotentialUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagneticVectorPotentialUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagneticVectorPotentialUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagneticVectorPotentialValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagneticVectorPotentialValue |
| mRef | attribute | MagneticVectorPotentialUnit | ISQElectromagnetism::MagneticVectorPotentialValue |
| ISQElectromagnetism::MagnetizationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagnetizationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagnetizationUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagnetizationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagnetizationValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagnetizationValue |
| mRef | attribute | MagnetizationUnit | ISQElectromagnetism::MagnetizationValue |
| ISQAtomicNuclear::MagnetogyricRatioOfTheElectronUnit | alias |  |  |
| ISQAtomicNuclear::MagnetogyricRatioOfTheElectronValue | alias |  |  |
| ISQAtomicNuclear::MagnetogyricRatioUnit | alias |  |  |
| ISQAtomicNuclear::MagnetogyricRatioValue | alias |  |  |
| ISQElectromagnetism::MagnetomotiveForceUnit | attribute def |  |  |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::MagnetomotiveForceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::MagnetomotiveForceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::MagnetomotiveForceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::MagnetomotiveForceValue |
| mRef | attribute | MagnetomotiveForceUnit | ISQElectromagnetism::MagnetomotiveForceValue |
| ISQCharacteristicNumbers::MarangoniNumberValue | attribute def |  |  |
| ISQLight::MassAbsorptionCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::MassAbsorptionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::MassAbsorptionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::MassAbsorptionCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::MassAbsorptionCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQLight::MassAbsorptionCoefficientValue |
| mRef | attribute | MassAbsorptionCoefficientUnit | ISQLight::MassAbsorptionCoefficientValue |
| ISQAtomicNuclear::MassAttenuationCoefficientForIonizingRadiationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MassAttenuationCoefficientForIonizingRadiationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MassAttenuationCoefficientForIonizingRadiationUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::MassAttenuationCoefficientForIonizingRadiationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::MassAttenuationCoefficientForIonizingRadiationValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::MassAttenuationCoefficientForIonizingRadiationValue |
| mRef | attribute | MassAttenuationCoefficientForIonizingRadiationUnit | ISQAtomicNuclear::MassAttenuationCoefficientForIonizingRadiationValue |
| ISQLight::MassAttenuationCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::MassAttenuationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::MassAttenuationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::MassAttenuationCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::MassAttenuationCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQLight::MassAttenuationCoefficientValue |
| mRef | attribute | MassAttenuationCoefficientUnit | ISQLight::MassAttenuationCoefficientValue |
| ISQMechanics::MassChangeRateUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::MassChangeRateUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::MassChangeRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::MassChangeRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::MassChangeRateValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::MassChangeRateValue |
| mRef | attribute | MassChangeRateUnit | ISQMechanics::MassChangeRateValue |
| ISQThermodynamics::MassConcentrationOfWaterUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::MassConcentrationOfWaterUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::MassConcentrationOfWaterUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::MassConcentrationOfWaterUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::MassConcentrationOfWaterValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::MassConcentrationOfWaterValue |
| mRef | attribute | MassConcentrationOfWaterUnit | ISQThermodynamics::MassConcentrationOfWaterValue |
| ISQThermodynamics::MassConcentrationOfWaterVapourAbsoluteHumidityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::MassConcentrationOfWaterVapourAbsoluteHumidityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::MassConcentrationOfWaterVapourAbsoluteHumidityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::MassConcentrationOfWaterVapourAbsoluteHumidityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::MassConcentrationOfWaterVapourAbsoluteHumidityValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::MassConcentrationOfWaterVapourAbsoluteHumidityValue |
| mRef | attribute | MassConcentrationOfWaterVapourAbsoluteHumidityUnit | ISQThermodynamics::MassConcentrationOfWaterVapourAbsoluteHumidityValue |
| ISQChemistryMolecular::MassConcentrationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MassConcentrationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MassConcentrationUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MassConcentrationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MassConcentrationValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MassConcentrationValue |
| mRef | attribute | MassConcentrationUnit | ISQChemistryMolecular::MassConcentrationValue |
| ISQMechanics::MassDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::MassDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::MassDensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::MassDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::MassDensityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::MassDensityValue |
| mRef | attribute | MassDensityUnit | ISQMechanics::MassDensityValue |
| ISQAtomicNuclear::MassEnergyTransferCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MassEnergyTransferCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MassEnergyTransferCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::MassEnergyTransferCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::MassEnergyTransferCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::MassEnergyTransferCoefficientValue |
| mRef | attribute | MassEnergyTransferCoefficientUnit | ISQAtomicNuclear::MassEnergyTransferCoefficientValue |
| ISQMechanics::MassFlowRateUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::MassFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::MassFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::MassFlowRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::MassFlowRateValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::MassFlowRateValue |
| mRef | attribute | MassFlowRateUnit | ISQMechanics::MassFlowRateValue |
| ISQMechanics::MassFlowUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::MassFlowUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::MassFlowUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::MassFlowUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::MassFlowUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::MassFlowValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::MassFlowValue |
| mRef | attribute | MassFlowUnit | ISQMechanics::MassFlowValue |
| ISQThermodynamics::MassFractionOfDryMatterValue | attribute def |  |  |
| ISQThermodynamics::MassFractionOfWaterValue | attribute def |  |  |
| ISQChemistryMolecular::MassFractionValue | attribute def |  |  |
| ISQThermodynamics::MassRatioOfWaterToDryMatterValue | attribute def |  |  |
| ISQThermodynamics::MassRatioOfWaterVapourToDryGasValue | attribute def |  |  |
| ISQAtomicNuclear::MassStoppingPowerUnit | alias |  |  |
| ISQAtomicNuclear::MassStoppingPowerValue | alias |  |  |
| ISQCharacteristicNumbers::MassTransferFactorValue | attribute def |  |  |
| ISQBase::MassUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQBase::MassUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQBase::MassUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQBase::MassValue | attribute def |  |  |
| num | attribute | Real | ISQBase::MassValue |
| mRef | attribute | MassUnit | ISQBase::MassValue |
| ISQAtomicNuclear::MassicActivityUnit | alias |  |  |
| ISQAtomicNuclear::MassicActivityValue | alias |  |  |
| ISQThermodynamics::MassieuFunctionUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::MassieuFunctionUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::MassieuFunctionUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::MassieuFunctionUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::MassieuFunctionUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::MassieuFunctionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::MassieuFunctionValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::MassieuFunctionValue |
| mRef | attribute | MassieuFunctionUnit | ISQThermodynamics::MassieuFunctionValue |
| ISQInformation::MaximumEntropyUnit | attribute def |  |  |
| ISQInformation::MaximumEntropyValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::MaximumEntropyValue |
| mRef | attribute | MaximumEntropyUnit | ISQInformation::MaximumEntropyValue |
| ISQLight::MaximumLuminousEfficacyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::MaximumLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::MaximumLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::MaximumLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::MaximumLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::MaximumLuminousEfficacyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::MaximumLuminousEfficacyValue | attribute def |  |  |
| num | attribute | Real | ISQLight::MaximumLuminousEfficacyValue |
| mRef | attribute | MaximumLuminousEfficacyUnit | ISQLight::MaximumLuminousEfficacyValue |
| ISQThermodynamics::MaximumThermalEfficiencyValue | attribute def |  |  |
| ISQInformation::MeanConditionalInformationContentUnit | alias |  |  |
| ISQInformation::MeanConditionalInformationContentValue | alias |  |  |
| ISQAtomicNuclear::MeanMassRangeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MeanMassRangeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MeanMassRangeUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::MeanMassRangeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::MeanMassRangeValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::MeanMassRangeValue |
| mRef | attribute | MeanMassRangeUnit | ISQAtomicNuclear::MeanMassRangeValue |
| ISQInformation::MeanQueueLengthValue | attribute def |  |  |
| ISQInformation::MeanTransinformationContentUnit | attribute def |  |  |
| ISQInformation::MeanTransinformationContentValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::MeanTransinformationContentValue |
| mRef | attribute | MeanTransinformationContentUnit | ISQInformation::MeanTransinformationContentValue |
| ISQMechanics::MechanicalEfficiencyValue | attribute def |  |  |
| ISQCondensedMatter::MobilityRatioValue | attribute def |  |  |
| ISQAtomicNuclear::MobilityUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MobilityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MobilityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MobilityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::MobilityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::MobilityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::MobilityValue |
| mRef | attribute | MobilityUnit | ISQAtomicNuclear::MobilityValue |
| ISQInformation::ModulationRateUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::ModulationRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::ModulationRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::ModulationRateValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::ModulationRateValue |
| mRef | attribute | ModulationRateUnit | ISQInformation::ModulationRateValue |
| ISQElectromagnetism::ModulusOfAdmittanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfAdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfAdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfAdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfAdmittanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ModulusOfAdmittanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ModulusOfAdmittanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ModulusOfAdmittanceValue |
| mRef | attribute | ModulusOfAdmittanceUnit | ISQElectromagnetism::ModulusOfAdmittanceValue |
| ISQMechanics::ModulusOfCompressionUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfCompressionUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfCompressionUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfCompressionUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::ModulusOfCompressionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::ModulusOfCompressionValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::ModulusOfCompressionValue |
| mRef | attribute | ModulusOfCompressionUnit | ISQMechanics::ModulusOfCompressionValue |
| ISQMechanics::ModulusOfElasticityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfElasticityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfElasticityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfElasticityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::ModulusOfElasticityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::ModulusOfElasticityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::ModulusOfElasticityValue |
| mRef | attribute | ModulusOfElasticityUnit | ISQMechanics::ModulusOfElasticityValue |
| ISQElectromagnetism::ModulusOfImpedanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ModulusOfImpedanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ModulusOfImpedanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ModulusOfImpedanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ModulusOfImpedanceValue |
| mRef | attribute | ModulusOfImpedanceUnit | ISQElectromagnetism::ModulusOfImpedanceValue |
| ISQMechanics::ModulusOfRigidityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfRigidityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfRigidityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::ModulusOfRigidityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::ModulusOfRigidityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::ModulusOfRigidityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::ModulusOfRigidityValue |
| mRef | attribute | ModulusOfRigidityUnit | ISQMechanics::ModulusOfRigidityValue |
| ISQChemistryMolecular::MolalityUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolalityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolalityUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolalityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolalityValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolalityValue |
| mRef | attribute | MolalityUnit | ISQChemistryMolecular::MolalityValue |
| ISQLight::MolarAbsorptionCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::MolarAbsorptionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQLight::MolarAbsorptionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQLight::MolarAbsorptionCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::MolarAbsorptionCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQLight::MolarAbsorptionCoefficientValue |
| mRef | attribute | MolarAbsorptionCoefficientUnit | ISQLight::MolarAbsorptionCoefficientValue |
| ISQAtomicNuclear::MolarAttenuationCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MolarAttenuationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQAtomicNuclear::MolarAttenuationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::MolarAttenuationCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::MolarAttenuationCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::MolarAttenuationCoefficientValue |
| mRef | attribute | MolarAttenuationCoefficientUnit | ISQAtomicNuclear::MolarAttenuationCoefficientValue |
| ISQChemistryMolecular::MolarConductivityUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarConductivityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarConductivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarConductivityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarConductivityUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarConductivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarConductivityValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarConductivityValue |
| mRef | attribute | MolarConductivityUnit | ISQChemistryMolecular::MolarConductivityValue |
| ISQChemistryMolecular::MolarEnthalpyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEnthalpyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEnthalpyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEnthalpyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEnthalpyUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarEnthalpyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarEnthalpyValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarEnthalpyValue |
| mRef | attribute | MolarEnthalpyUnit | ISQChemistryMolecular::MolarEnthalpyValue |
| ISQChemistryMolecular::MolarEntropyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEntropyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEntropyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEntropyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEntropyUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarEntropyUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarEntropyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarEntropyValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarEntropyValue |
| mRef | attribute | MolarEntropyUnit | ISQChemistryMolecular::MolarEntropyValue |
| ISQChemistryMolecular::MolarGasConstantUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarGasConstantUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarGasConstantValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarGasConstantValue |
| mRef | attribute | MolarGasConstantUnit | ISQChemistryMolecular::MolarGasConstantValue |
| ISQChemistryMolecular::MolarGibbsEnergyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGibbsEnergyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGibbsEnergyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGibbsEnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarGibbsEnergyUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarGibbsEnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarGibbsEnergyValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarGibbsEnergyValue |
| mRef | attribute | MolarGibbsEnergyUnit | ISQChemistryMolecular::MolarGibbsEnergyValue |
| ISQChemistryMolecular::MolarHeatCapacityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarHeatCapacityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarHeatCapacityValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarHeatCapacityValue |
| mRef | attribute | MolarHeatCapacityUnit | ISQChemistryMolecular::MolarHeatCapacityValue |
| ISQChemistryMolecular::MolarHelmholtzEnergyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHelmholtzEnergyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHelmholtzEnergyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHelmholtzEnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarHelmholtzEnergyUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarHelmholtzEnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarHelmholtzEnergyValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarHelmholtzEnergyValue |
| mRef | attribute | MolarHelmholtzEnergyUnit | ISQChemistryMolecular::MolarHelmholtzEnergyValue |
| ISQChemistryMolecular::MolarInternalEnergyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarInternalEnergyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarInternalEnergyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarInternalEnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarInternalEnergyUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarInternalEnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarInternalEnergyValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarInternalEnergyValue |
| mRef | attribute | MolarInternalEnergyUnit | ISQChemistryMolecular::MolarInternalEnergyValue |
| ISQChemistryMolecular::MolarMassUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarMassUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarMassUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarMassUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarMassValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarMassValue |
| mRef | attribute | MolarMassUnit | ISQChemistryMolecular::MolarMassValue |
| ISQChemistryMolecular::MolarOpticalRotatoryPowerUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarOpticalRotatoryPowerUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarOpticalRotatoryPowerUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarOpticalRotatoryPowerUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarOpticalRotatoryPowerValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarOpticalRotatoryPowerValue |
| mRef | attribute | MolarOpticalRotatoryPowerUnit | ISQChemistryMolecular::MolarOpticalRotatoryPowerValue |
| ISQChemistryMolecular::MolarVolumeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarVolumeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::MolarVolumeUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::MolarVolumeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::MolarVolumeValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::MolarVolumeValue |
| mRef | attribute | MolarVolumeUnit | ISQChemistryMolecular::MolarVolumeValue |
| ISQChemistryMolecular::MolecularPartitionFunctionValue | attribute def |  |  |
| ISQMechanics::MomentOfForceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::MomentOfForceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::MomentOfForceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::MomentOfForceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::MomentOfForceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::MomentOfForceValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::MomentOfForceValue |
| mRef | attribute | MomentOfForceUnit | ISQMechanics::MomentOfForceValue |
| ISQMechanics::MomentOfInertiaUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::MomentOfInertiaUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::MomentOfInertiaUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::MomentOfInertiaUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::MomentOfInertiaValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::MomentOfInertiaValue |
| mRef | attribute | MomentOfInertiaUnit | ISQMechanics::MomentOfInertiaValue |
| ISQMechanics::MomentumUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::MomentumUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::MomentumUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::MomentumUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::MomentumUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::MomentumValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::MomentumValue |
| mRef | attribute | MomentumUnit | ISQMechanics::MomentumValue |
| ISQCharacteristicNumbers::MortonNumberValue | attribute def |  |  |
| ISQAtomicNuclear::MultiplicationFactorUnit | attribute def |  |  |
| ISQAtomicNuclear::MultiplicationFactorValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::MultiplicationFactorValue |
| mRef | attribute | MultiplicationFactorUnit | ISQAtomicNuclear::MultiplicationFactorValue |
| SI::newton | attribute | ForceUnit |  |
| ISQLight::NapierianAbsorbanceValue | attribute def |  |  |
| ScalarValues::Natural | datatype |  |  |
| ISQCharacteristicNumbers::NazeNumberValue | attribute def |  |  |
| ISQAtomicNuclear::NonLeakageProbabilityUnit | attribute def |  |  |
| ISQAtomicNuclear::NonLeakageProbabilityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::NonLeakageProbabilityValue |
| mRef | attribute | NonLeakageProbabilityUnit | ISQAtomicNuclear::NonLeakageProbabilityValue |
| ISQMechanics::NormalStressUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::NormalStressUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::NormalStressUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::NormalStressUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::NormalStressUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::NormalStressValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::NormalStressValue |
| mRef | attribute | NormalStressUnit | ISQMechanics::NormalStressValue |
| ISQAtomicNuclear::NuclearActivityUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::NuclearActivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::NuclearActivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::NuclearActivityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::NuclearActivityValue |
| mRef | attribute | NuclearActivityUnit | ISQAtomicNuclear::NuclearActivityValue |
| ISQAtomicNuclear::NuclearQuadrupoleMomentUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::NuclearQuadrupoleMomentUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::NuclearQuadrupoleMomentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::NuclearQuadrupoleMomentValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::NuclearQuadrupoleMomentValue |
| mRef | attribute | NuclearQuadrupoleMomentUnit | ISQAtomicNuclear::NuclearQuadrupoleMomentValue |
| ScalarValues::Number | datatype |  |  |
| ISQChemistryMolecular::NumberOfMolesUnit | alias |  |  |
| ISQChemistryMolecular::NumberOfMolesValue | alias |  |  |
| ScalarValues::NumericalValue | datatype |  |  |
| ISQCharacteristicNumbers::NusseltElectricNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::NusseltNumberForMassTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::NusseltNumberValue | attribute def |  |  |
| SI::'newton metre' | attribute | MomentOfForceUnit, TorqueUnit |  |
| quantityDimension | attribute | QuantityDimension | SI::'newton metre' |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| SI::'newton metre to the power minus 2' | attribute | PressureUnit |  |
| SI::'newton metre to the power minus 1' | attribute | SurfaceTensionUnit |  |
| SI::'newton metre second' | attribute | AngularImpulseUnit |  |
| SI::'newton metre second to the power minus 1' | attribute | PowerUnit |  |
| SI::'newton second' | attribute | ImpulseUnit |  |
| ISQCharacteristicNumbers::OhnesorgeNumberValue | attribute def |  |  |
| ISQChemistryMolecular::OsmoticFactorOfSolventValue | attribute def |  |  |
| ISQChemistryMolecular::OsmoticPressureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::OsmoticPressureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::OsmoticPressureUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::OsmoticPressureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::OsmoticPressureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::OsmoticPressureValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::OsmoticPressureValue |
| mRef | attribute | OsmoticPressureUnit | ISQChemistryMolecular::OsmoticPressureValue |
| SI::pascal | attribute | PressureUnit |  |
| SI::'pascal per kelvin' | attribute | PressureCoefficientUnit |  |
| ISQAtomicNuclear::PackingFractionValue | attribute def |  |  |
| ISQChemistryMolecular::PartialPressureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::PartialPressureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::PartialPressureUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::PartialPressureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::PartialPressureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::PartialPressureValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::PartialPressureValue |
| mRef | attribute | PartialPressureUnit | ISQChemistryMolecular::PartialPressureValue |
| ISQChemistryMolecular::ParticleConcentrationUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ParticleConcentrationUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::ParticleConcentrationUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::ParticleConcentrationValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::ParticleConcentrationValue |
| mRef | attribute | ParticleConcentrationUnit | ISQChemistryMolecular::ParticleConcentrationValue |
| ISQAtomicNuclear::ParticleCurrentDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ParticleCurrentDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ParticleCurrentDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ParticleCurrentDensityValue |
| mRef | attribute | ParticleCurrentDensityUnit | ISQAtomicNuclear::ParticleCurrentDensityValue |
| ISQAtomicNuclear::ParticleEmissionRateUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleEmissionRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ParticleEmissionRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ParticleEmissionRateValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ParticleEmissionRateValue |
| mRef | attribute | ParticleEmissionRateUnit | ISQAtomicNuclear::ParticleEmissionRateValue |
| ISQAtomicNuclear::ParticleFluenceRateUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleFluenceRateUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleFluenceRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ParticleFluenceRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ParticleFluenceRateValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ParticleFluenceRateValue |
| mRef | attribute | ParticleFluenceRateUnit | ISQAtomicNuclear::ParticleFluenceRateValue |
| ISQAtomicNuclear::ParticleFluenceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleFluenceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ParticleFluenceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ParticleFluenceValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ParticleFluenceValue |
| mRef | attribute | ParticleFluenceUnit | ISQAtomicNuclear::ParticleFluenceValue |
| ISQAtomicNuclear::ParticleNumberDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleNumberDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ParticleNumberDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ParticleNumberDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ParticleNumberDensityValue |
| mRef | attribute | ParticleNumberDensityUnit | ISQAtomicNuclear::ParticleNumberDensityValue |
| ISQAtomicNuclear::ParticleSourceDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleSourceDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::ParticleSourceDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::ParticleSourceDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::ParticleSourceDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ParticleSourceDensityValue |
| mRef | attribute | ParticleSourceDensityUnit | ISQAtomicNuclear::ParticleSourceDensityValue |
| SI::'pascal to the power 2 second' | attribute | SoundExposureUnit |  |
| SI::'pascal to the power minus 1' | attribute | CompressibilityUnit |  |
| SI::'pascal second' | attribute | DynamicViscosityUnit |  |
| SI::'pascal second per metre' | attribute | CharacteristicImpedanceOfAMediumForLongitudinalWavesUnit |  |
| SI::'pascal second per cubic metre' | attribute | AcousticImpedanceUnit |  |
| ISQElectromagnetism::PermeabilityOfVacuumUnit | alias |  |  |
| ISQElectromagnetism::PermeabilityOfVacuumValue | alias |  |  |
| ISQElectromagnetism::PermeabilityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeabilityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeabilityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeabilityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeabilityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::PermeabilityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::PermeabilityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::PermeabilityValue |
| mRef | attribute | PermeabilityUnit | ISQElectromagnetism::PermeabilityValue |
| ISQElectromagnetism::PermeanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermeanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::PermeanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::PermeanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::PermeanceValue |
| mRef | attribute | PermeanceUnit | ISQElectromagnetism::PermeanceValue |
| ISQElectromagnetism::PermittivityOfVacuumUnit | alias |  |  |
| ISQElectromagnetism::PermittivityOfVacuumValue | alias |  |  |
| ISQElectromagnetism::PermittivityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermittivityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermittivityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermittivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PermittivityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::PermittivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::PermittivityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::PermittivityValue |
| mRef | attribute | PermittivityUnit | ISQElectromagnetism::PermittivityValue |
| ISQSpaceTime::PhaseCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::PhaseCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::PhaseCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::PhaseCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::PhaseCoefficientValue |
| mRef | attribute | PhaseCoefficientUnit | ISQSpaceTime::PhaseCoefficientValue |
| ISQElectromagnetism::PhaseDifferenceUnit | attribute def |  |  |
| ISQElectromagnetism::PhaseDifferenceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::PhaseDifferenceValue |
| mRef | attribute | PhaseDifferenceUnit | ISQElectromagnetism::PhaseDifferenceValue |
| ISQElectromagnetism::PhaseSpeedOfElectromagneticWavesUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PhaseSpeedOfElectromagneticWavesUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PhaseSpeedOfElectromagneticWavesUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::PhaseSpeedOfElectromagneticWavesUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::PhaseSpeedOfElectromagneticWavesValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::PhaseSpeedOfElectromagneticWavesValue |
| mRef | attribute | PhaseSpeedOfElectromagneticWavesUnit | ISQElectromagnetism::PhaseSpeedOfElectromagneticWavesValue |
| ISQSpaceTime::PhaseSpeedUnit | alias |  |  |
| ISQSpaceTime::PhaseSpeedValue | alias |  |  |
| ISQSpaceTime::PhaseVelocityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::PhaseVelocityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::PhaseVelocityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::PhaseVelocityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::PhaseVelocityValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::PhaseVelocityValue |
| mRef | attribute | PhaseVelocityUnit | ISQSpaceTime::PhaseVelocityValue |
| ISQLight::PhotonExitanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::PhotonExitanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::PhotonExitanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::PhotonExitanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::PhotonExitanceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::PhotonExitanceValue |
| mRef | attribute | PhotonExitanceUnit | ISQLight::PhotonExitanceValue |
| ISQLight::PhotonExposureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::PhotonExposureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::PhotonExposureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::PhotonExposureValue | attribute def |  |  |
| num | attribute | Real | ISQLight::PhotonExposureValue |
| mRef | attribute | PhotonExposureUnit | ISQLight::PhotonExposureValue |
| ISQLight::PhotonFluxUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQLight::PhotonFluxUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::PhotonFluxUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::PhotonFluxValue | attribute def |  |  |
| num | attribute | Real | ISQLight::PhotonFluxValue |
| mRef | attribute | PhotonFluxUnit | ISQLight::PhotonFluxValue |
| ISQLight::PhotonIntensityUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQLight::PhotonIntensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::PhotonIntensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::PhotonIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQLight::PhotonIntensityValue |
| mRef | attribute | PhotonIntensityUnit | ISQLight::PhotonIntensityValue |
| ISQLight::PhotonIrradianceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::PhotonIrradianceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::PhotonIrradianceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::PhotonIrradianceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::PhotonIrradianceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::PhotonIrradianceValue |
| mRef | attribute | PhotonIrradianceUnit | ISQLight::PhotonIrradianceValue |
| ISQLight::PhotonNumberValue | attribute def |  |  |
| ISQLight::PhotonRadianceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::PhotonRadianceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::PhotonRadianceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::PhotonRadianceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::PhotonRadianceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::PhotonRadianceValue |
| mRef | attribute | PhotonRadianceUnit | ISQLight::PhotonRadianceValue |
| ISQThermodynamics::PlanckFunctionUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::PlanckFunctionUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::PlanckFunctionUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::PlanckFunctionUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::PlanckFunctionUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::PlanckFunctionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::PlanckFunctionValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::PlanckFunctionValue |
| mRef | attribute | PlanckFunctionUnit | ISQThermodynamics::PlanckFunctionValue |
| ISQSpaceTime::PlaneAngleUnit | alias |  |  |
| ISQSpaceTime::PlaneAngleValue | alias |  |  |
| ISQSpaceTime::PlanetaryPosition3dVector | attribute def |  |  |
| latitude | attribute | AngularMeasureUnit | ISQSpaceTime::PlanetaryPosition3dVector |
| longitude | attribute | AngularMeasureUnit | ISQSpaceTime::PlanetaryPosition3dVector |
| altitude | attribute | LengthValue | ISQSpaceTime::PlanetaryPosition3dVector |
| mRef | attribute | PlanetarySpatial3dCoordinateFrame | ISQSpaceTime::PlanetaryPosition3dVector |
| ISQSpaceTime::PlanetarySpatial3dCoordinateFrame | attribute def |  |  |
| latitudeUnit | attribute | AngularMeasureUnit | ISQSpaceTime::PlanetarySpatial3dCoordinateFrame |
| longitudeUnit | attribute | AngularMeasureUnit | ISQSpaceTime::PlanetarySpatial3dCoordinateFrame |
| altitudeUnit | attribute | LengthUnit | ISQSpaceTime::PlanetarySpatial3dCoordinateFrame |
| mRefs | attribute | ScalarMeasurementReference | ISQSpaceTime::PlanetarySpatial3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::PlanetarySpatial3dCoordinateFrame |
| ISQCharacteristicNumbers::PoiseuilleNumberValue | attribute def |  |  |
| ISQMechanics::PoissonNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::PomerantsevNumberValue | attribute def |  |  |
| ISQSpaceTime::Position3dVector | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::Position3dVector |
| mRef | attribute | Spatial3dCoordinateFrame | ISQSpaceTime::Position3dVector |
| ScalarValues::Positive | datatype |  |  |
| ISQElectromagnetism::PowerFactorValue | attribute def |  |  |
| ISQCharacteristicNumbers::PowerNumberValue | attribute def |  |  |
| ISQMechanics::PowerUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::PowerUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::PowerUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::PowerUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::PowerUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::PowerValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::PowerValue |
| mRef | attribute | PowerUnit | ISQMechanics::PowerValue |
| ISQElectromagnetism::PoyntingVectorMagnitudeUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PoyntingVectorMagnitudeUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::PoyntingVectorMagnitudeUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::PoyntingVectorMagnitudeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::PoyntingVectorMagnitudeValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::PoyntingVectorMagnitudeValue |
| mRef | attribute | PoyntingVectorMagnitudeUnit | ISQElectromagnetism::PoyntingVectorMagnitudeValue |
| ISQCharacteristicNumbers::PrandtlMagneticNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::PrandtlNumberValue | attribute def |  |  |
| ISQThermodynamics::PressureCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::PressureCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::PressureCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::PressureCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::PressureCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::PressureCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::PressureCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::PressureCoefficientValue |
| mRef | attribute | PressureCoefficientUnit | ISQThermodynamics::PressureCoefficientValue |
| ISQMechanics::PressureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::PressureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::PressureUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::PressureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::PressureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::PressureValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::PressureValue |
| mRef | attribute | PressureUnit | ISQMechanics::PressureValue |
| ISQSpaceTime::PropagationCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::PropagationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::PropagationCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::PropagationCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::PropagationCoefficientValue |
| mRef | attribute | PropagationCoefficientUnit | ISQSpaceTime::PropagationCoefficientValue |
| ISQCharacteristicNumbers::'PécletNumberForMassTransferValue' | attribute def |  |  |
| ISQCharacteristicNumbers::'PécletNumberValue' | attribute def |  |  |
| ISQAtomicNuclear::QualityFactorForIonizingRadiationUnit | attribute def |  |  |
| ISQAtomicNuclear::QualityFactorForIonizingRadiationValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::QualityFactorForIonizingRadiationValue |
| mRef | attribute | QualityFactorForIonizingRadiationUnit | ISQAtomicNuclear::QualityFactorForIonizingRadiationValue |
| ISQElectromagnetism::QualityFactorValue | attribute def |  |  |
| ISQLight::QuantityOfIlluminationUnit | alias |  |  |
| ISQLight::QuantityOfIlluminationValue | alias |  |  |
| ISQLight::QuantityOfLightUnit | alias |  |  |
| ISQLight::QuantityOfLightValue | alias |  |  |
| ISQAtomicNuclear::QuantumNumberValue | attribute def |  |  |
| ISQLight::RadianceFactorValue | attribute def |  |  |
| ISQLight::RadianceUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQLight::RadianceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::RadianceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::RadianceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::RadianceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::RadianceValue |
| mRef | attribute | RadianceUnit | ISQLight::RadianceValue |
| ISQLight::RadiantEmittanceUnit | alias |  |  |
| ISQLight::RadiantEmittanceValue | alias |  |  |
| ISQLight::RadiantEnergyDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::RadiantEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::RadiantEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::RadiantEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::RadiantEnergyDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::RadiantEnergyDensityValue | attribute def |  |  |
| num | attribute | Real | ISQLight::RadiantEnergyDensityValue |
| mRef | attribute | RadiantEnergyDensityUnit | ISQLight::RadiantEnergyDensityValue |
| ISQLight::RadiantExitanceUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQLight::RadiantExitanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::RadiantExitanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::RadiantExitanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::RadiantExitanceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::RadiantExitanceValue |
| mRef | attribute | RadiantExitanceUnit | ISQLight::RadiantExitanceValue |
| ISQLight::RadiantExposureUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQLight::RadiantExposureUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::RadiantExposureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::RadiantExposureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::RadiantExposureValue | attribute def |  |  |
| num | attribute | Real | ISQLight::RadiantExposureValue |
| mRef | attribute | RadiantExposureUnit | ISQLight::RadiantExposureValue |
| ISQLight::RadiantFluxUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::RadiantFluxUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::RadiantFluxUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::RadiantFluxUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::RadiantFluxUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::RadiantFluxValue | attribute def |  |  |
| num | attribute | Real | ISQLight::RadiantFluxValue |
| mRef | attribute | RadiantFluxUnit | ISQLight::RadiantFluxValue |
| ISQLight::RadiantIntensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::RadiantIntensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::RadiantIntensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::RadiantIntensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::RadiantIntensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::RadiantIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQLight::RadiantIntensityValue |
| mRef | attribute | RadiantIntensityUnit | ISQLight::RadiantIntensityValue |
| ISQLight::RadiantPowerUnit | alias |  |  |
| ISQLight::RadiantPowerValue | alias |  |  |
| ISQThermodynamics::RatioOfSpecificHeatCapacitiesValue | attribute def |  |  |
| ScalarValues::Rational | datatype |  |  |
| ISQCharacteristicNumbers::RayleighNumberValue | attribute def |  |  |
| ISQElectromagnetism::ReactanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReactanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReactanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReactanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReactanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ReactanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ReactanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ReactanceValue |
| mRef | attribute | ReactanceUnit | ISQElectromagnetism::ReactanceValue |
| ScalarValues::Real | datatype |  |  |
| ISQAtomicNuclear::RecombinationCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::RecombinationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::RecombinationCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::RecombinationCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::RecombinationCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::RecombinationCoefficientValue |
| mRef | attribute | RecombinationCoefficientUnit | ISQAtomicNuclear::RecombinationCoefficientValue |
| ISQInformation::RedundancyUnit | attribute def |  |  |
| ISQInformation::RedundancyValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::RedundancyValue |
| mRef | attribute | RedundancyUnit | ISQInformation::RedundancyValue |
| ISQCharacteristicNumbers::ReechNumberValue | attribute def |  |  |
| ISQLight::ReflectanceFactorValue | attribute def |  |  |
| ISQLight::ReflectanceValue | attribute def |  |  |
| ISQLight::RefractiveIndexValue | attribute def |  |  |
| ISQChemistryMolecular::RelativeAtomicMassValue | attribute def |  |  |
| ISQInformation::RelativeEntropyValue | attribute def |  |  |
| ISQThermodynamics::RelativeHumidityValue | attribute def |  |  |
| ISQMechanics::RelativeLinearStrainValue | attribute def |  |  |
| ISQThermodynamics::RelativeMassConcentrationOfVapourValue | attribute def |  |  |
| ISQAtomicNuclear::RelativeMassDefectValue | attribute def |  |  |
| ISQMechanics::RelativeMassDensityValue | attribute def |  |  |
| ISQAtomicNuclear::RelativeMassExcessValue | attribute def |  |  |
| ISQThermodynamics::RelativeMassRatioOfVapourValue | attribute def |  |  |
| ISQElectromagnetism::RelativePermeabilityValue | attribute def |  |  |
| ISQElectromagnetism::RelativePermittivityValue | attribute def |  |  |
| ISQThermodynamics::RelativePressureCoefficientUnit | attribute def |  |  |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::RelativePressureCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::RelativePressureCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::RelativePressureCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::RelativePressureCoefficientValue |
| mRef | attribute | RelativePressureCoefficientUnit | ISQThermodynamics::RelativePressureCoefficientValue |
| ISQInformation::RelativeRedundancyValue | attribute def |  |  |
| ISQMechanics::RelativeVolumeStrainValue | attribute def |  |  |
| ISQElectromagnetism::ReluctanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReluctanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReluctanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReluctanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ReluctanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ReluctanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ReluctanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ReluctanceValue |
| mRef | attribute | ReluctanceUnit | ISQElectromagnetism::ReluctanceValue |
| ISQSpaceTime::RepetencyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::RepetencyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::RepetencyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::RepetencyValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::RepetencyValue |
| mRef | attribute | RepetencyUnit | ISQSpaceTime::RepetencyValue |
| ISQElectromagnetism::ResistanceToAlternatingCurrentUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceToAlternatingCurrentUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceToAlternatingCurrentUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceToAlternatingCurrentUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceToAlternatingCurrentUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ResistanceToAlternatingCurrentUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ResistanceToAlternatingCurrentValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ResistanceToAlternatingCurrentValue |
| mRef | attribute | ResistanceToAlternatingCurrentUnit | ISQElectromagnetism::ResistanceToAlternatingCurrentValue |
| ISQElectromagnetism::ResistanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ResistanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ResistanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ResistanceValue |
| mRef | attribute | ResistanceUnit | ISQElectromagnetism::ResistanceValue |
| ISQElectromagnetism::ResistivityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistivityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistivityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::ResistivityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::ResistivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::ResistivityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::ResistivityValue |
| mRef | attribute | ResistivityUnit | ISQElectromagnetism::ResistivityValue |
| ISQAtomicNuclear::ResonanceEscapeProbabilityValue | attribute def |  |  |
| ISQCharacteristicNumbers::ReynoldsElectricNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::ReynoldsMagneticNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::ReynoldsNumberValue | attribute def |  |  |
| ISQCondensedMatter::RichardsonConstantUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::RichardsonConstantUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQCondensedMatter::RichardsonConstantUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQCondensedMatter::RichardsonConstantUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::RichardsonConstantUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::RichardsonConstantValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::RichardsonConstantValue |
| mRef | attribute | RichardsonConstantUnit | ISQCondensedMatter::RichardsonConstantValue |
| ISQCharacteristicNumbers::RichardsonNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::RobertsNumberValue | attribute def |  |  |
| ISQMechanics::RollingResistanceFactorValue | attribute def |  |  |
| ISQCharacteristicNumbers::RossbyNumberValue | attribute def |  |  |
| ISQAtomicNuclear::RydbergConstantUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::RydbergConstantUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::RydbergConstantUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::RydbergConstantValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::RydbergConstantValue |
| mRef | attribute | RydbergConstantUnit | ISQAtomicNuclear::RydbergConstantValue |
| SI::siemens | attribute | ConductanceUnit |  |
| SI::'siemens per metre' | attribute | ConductivityUnit |  |
| ScalarValues::ScalarValue | datatype |  |  |
| ISQCharacteristicNumbers::SchmidtNumberValue | attribute def |  |  |
| ISQMechanics::SecondAxialMomentOfAreaUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::SecondAxialMomentOfAreaUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::SecondAxialMomentOfAreaUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::SecondAxialMomentOfAreaValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::SecondAxialMomentOfAreaValue |
| mRef | attribute | SecondAxialMomentOfAreaUnit | ISQMechanics::SecondAxialMomentOfAreaValue |
| ISQMechanics::SecondPolarMomentOfAreaUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::SecondPolarMomentOfAreaUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::SecondPolarMomentOfAreaUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::SecondPolarMomentOfAreaValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::SecondPolarMomentOfAreaValue |
| mRef | attribute | SecondPolarMomentOfAreaUnit | ISQMechanics::SecondPolarMomentOfAreaValue |
| ISQMechanics::SectionModulusUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::SectionModulusUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::SectionModulusUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::SectionModulusValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::SectionModulusValue |
| mRef | attribute | SectionModulusUnit | ISQMechanics::SectionModulusValue |
| ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBValue |
| mRef | attribute | SeebeckCoefficientForSubstancesAAndBUnit | ISQCondensedMatter::SeebeckCoefficientForSubstancesAAndBValue |
| ISQElectromagnetism::SelfInductanceUnit | alias |  |  |
| ISQElectromagnetism::SelfInductanceValue | alias |  |  |
| SI::shannon | attribute | InformationContentUnit |  |
| SI::'shannon per second' | attribute | AverageInformationRateUnit |  |
| ISQMechanics::ShearModulusUnit | alias |  |  |
| ISQMechanics::ShearModulusValue | alias |  |  |
| ISQMechanics::ShearStrainValue | attribute def |  |  |
| ISQMechanics::ShearStressUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::ShearStressUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::ShearStressUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::ShearStressUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::ShearStressUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::ShearStressValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::ShearStressValue |
| mRef | attribute | ShearStressUnit | ISQMechanics::ShearStressValue |
| ISQCondensedMatter::ShortRangeOrderParameterValue | attribute def |  |  |
| ISQAtomicNuclear::SlowingDownDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SlowingDownDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SlowingDownDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::SlowingDownDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::SlowingDownDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::SlowingDownDensityValue |
| mRef | attribute | SlowingDownDensityUnit | ISQAtomicNuclear::SlowingDownDensityValue |
| ISQSpaceTime::SolidAngularMeasureUnit | attribute def |  |  |
| ISQSpaceTime::SolidAngularMeasureValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::SolidAngularMeasureValue |
| mRef | attribute | SolidAngularMeasureUnit | ISQSpaceTime::SolidAngularMeasureValue |
| ISQCharacteristicNumbers::SommerfeldNumberValue | attribute def |  |  |
| ISQAcoustics::SoundEnergyDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundEnergyDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAcoustics::SoundEnergyDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAcoustics::SoundEnergyDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::SoundEnergyDensityValue |
| mRef | attribute | SoundEnergyDensityUnit | ISQAcoustics::SoundEnergyDensityValue |
| ISQAcoustics::SoundExposureLevelUnit | attribute def |  |  |
| ISQAcoustics::SoundExposureLevelValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::SoundExposureLevelValue |
| mRef | attribute | SoundExposureLevelUnit | ISQAcoustics::SoundExposureLevelValue |
| ISQAcoustics::SoundExposureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundExposureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundExposureUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundExposureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAcoustics::SoundExposureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAcoustics::SoundExposureValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::SoundExposureValue |
| mRef | attribute | SoundExposureUnit | ISQAcoustics::SoundExposureValue |
| ISQAcoustics::SoundIntensityUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundIntensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAcoustics::SoundIntensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAcoustics::SoundIntensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAcoustics::SoundIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::SoundIntensityValue |
| mRef | attribute | SoundIntensityUnit | ISQAcoustics::SoundIntensityValue |
| ISQAcoustics::SoundPowerLevelUnit | attribute def |  |  |
| ISQAcoustics::SoundPowerLevelValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::SoundPowerLevelValue |
| mRef | attribute | SoundPowerLevelUnit | ISQAcoustics::SoundPowerLevelValue |
| ISQAcoustics::SoundPressureLevelUnit | attribute def |  |  |
| ISQAcoustics::SoundPressureLevelValue | attribute def |  |  |
| num | attribute | Real | ISQAcoustics::SoundPressureLevelValue |
| mRef | attribute | SoundPressureLevelUnit | ISQAcoustics::SoundPressureLevelValue |
| ISQElectromagnetism::SourceTensionUnit | alias |  |  |
| ISQElectromagnetism::SourceTensionValue | alias |  |  |
| ISQElectromagnetism::SourceVoltageUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SourceVoltageUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SourceVoltageUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SourceVoltageUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SourceVoltageUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::SourceVoltageUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::SourceVoltageValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::SourceVoltageValue |
| mRef | attribute | SourceVoltageUnit | ISQElectromagnetism::SourceVoltageValue |
| ISQSpaceTime::Spatial3dCoordinateFrame | attribute def |  |  |
| isBound | attribute | Boolean | ISQSpaceTime::Spatial3dCoordinateFrame |
| ISQAtomicNuclear::SpecificActivityUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SpecificActivityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SpecificActivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::SpecificActivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::SpecificActivityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::SpecificActivityValue |
| mRef | attribute | SpecificActivityUnit | ISQAtomicNuclear::SpecificActivityValue |
| ISQThermodynamics::SpecificEnergyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificEnergyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificEnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificEnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificEnergyValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificEnergyValue |
| mRef | attribute | SpecificEnergyUnit | ISQThermodynamics::SpecificEnergyValue |
| ISQThermodynamics::SpecificEnthalpyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificEnthalpyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificEnthalpyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificEnthalpyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificEnthalpyValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificEnthalpyValue |
| mRef | attribute | SpecificEnthalpyUnit | ISQThermodynamics::SpecificEnthalpyValue |
| ISQThermodynamics::SpecificEntropyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificEntropyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificEntropyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificEntropyUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificEntropyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificEntropyValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificEntropyValue |
| mRef | attribute | SpecificEntropyUnit | ISQThermodynamics::SpecificEntropyValue |
| ISQThermodynamics::SpecificGasConstantUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificGasConstantUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificGasConstantUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificGasConstantValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificGasConstantValue |
| mRef | attribute | SpecificGasConstantUnit | ISQThermodynamics::SpecificGasConstantValue |
| ISQThermodynamics::SpecificHeatCapacityAtConstantPressureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtConstantPressureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtConstantPressureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtConstantPressureUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificHeatCapacityAtConstantPressureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificHeatCapacityAtConstantPressureValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificHeatCapacityAtConstantPressureValue |
| mRef | attribute | SpecificHeatCapacityAtConstantPressureUnit | ISQThermodynamics::SpecificHeatCapacityAtConstantPressureValue |
| ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeValue |
| mRef | attribute | SpecificHeatCapacityAtConstantVolumeUnit | ISQThermodynamics::SpecificHeatCapacityAtConstantVolumeValue |
| ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureValue |
| mRef | attribute | SpecificHeatCapacityAtSaturatedVapourPressureUnit | ISQThermodynamics::SpecificHeatCapacityAtSaturatedVapourPressureValue |
| ISQThermodynamics::SpecificHeatCapacityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::SpecificHeatCapacityUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SpecificHeatCapacityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SpecificHeatCapacityValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SpecificHeatCapacityValue |
| mRef | attribute | SpecificHeatCapacityUnit | ISQThermodynamics::SpecificHeatCapacityValue |
| ISQChemistryMolecular::SpecificOpticalRotatoryPowerUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::SpecificOpticalRotatoryPowerUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::SpecificOpticalRotatoryPowerUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::SpecificOpticalRotatoryPowerUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::SpecificOpticalRotatoryPowerValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::SpecificOpticalRotatoryPowerValue |
| mRef | attribute | SpecificOpticalRotatoryPowerUnit | ISQChemistryMolecular::SpecificOpticalRotatoryPowerValue |
| ISQMechanics::SpecificVolumeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::SpecificVolumeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::SpecificVolumeUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::SpecificVolumeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::SpecificVolumeValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::SpecificVolumeValue |
| mRef | attribute | SpecificVolumeUnit | ISQMechanics::SpecificVolumeValue |
| ISQLight::SpectralIrradianceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralIrradianceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralIrradianceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralIrradianceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralIrradianceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralIrradianceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralIrradianceValue |
| mRef | attribute | SpectralIrradianceUnit | ISQLight::SpectralIrradianceValue |
| ISQLight::SpectralLuminousEfficacyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::SpectralLuminousEfficacyUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralLuminousEfficacyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralLuminousEfficacyValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralLuminousEfficacyValue |
| mRef | attribute | SpectralLuminousEfficacyUnit | ISQLight::SpectralLuminousEfficacyValue |
| ISQLight::SpectralLuminousEfficiencyValue | attribute def |  |  |
| ISQLight::SpectralRadianceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadianceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadianceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadianceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadianceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadianceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadianceValue |
| mRef | attribute | SpectralRadianceUnit | ISQLight::SpectralRadianceValue |
| ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthValue |
| mRef | attribute | SpectralRadiantEnergyDensityInTermsOfWavelengthUnit | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavelengthValue |
| ISQLight::SpectralRadiantEnergyDensityInTermsOfWavenumberUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavenumberUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavenumberUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavenumberUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadiantEnergyDensityInTermsOfWavenumberValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavenumberValue |
| mRef | attribute | SpectralRadiantEnergyDensityInTermsOfWavenumberUnit | ISQLight::SpectralRadiantEnergyDensityInTermsOfWavenumberValue |
| ISQLight::SpectralRadiantEnergyUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantEnergyUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadiantEnergyUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadiantEnergyValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadiantEnergyValue |
| mRef | attribute | SpectralRadiantEnergyUnit | ISQLight::SpectralRadiantEnergyValue |
| ISQLight::SpectralRadiantExitanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantExitanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantExitanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantExitanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadiantExitanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadiantExitanceValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadiantExitanceValue |
| mRef | attribute | SpectralRadiantExitanceUnit | ISQLight::SpectralRadiantExitanceValue |
| ISQLight::SpectralRadiantExposureUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantExposureUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantExposureUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantExposureUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadiantExposureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadiantExposureValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadiantExposureValue |
| mRef | attribute | SpectralRadiantExposureUnit | ISQLight::SpectralRadiantExposureValue |
| ISQLight::SpectralRadiantFluxUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantFluxUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantFluxUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantFluxUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadiantFluxUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadiantFluxValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadiantFluxValue |
| mRef | attribute | SpectralRadiantFluxUnit | ISQLight::SpectralRadiantFluxValue |
| ISQLight::SpectralRadiantIntensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantIntensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantIntensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpectralRadiantIntensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpectralRadiantIntensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpectralRadiantIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpectralRadiantIntensityValue |
| mRef | attribute | SpectralRadiantIntensityUnit | ISQLight::SpectralRadiantIntensityValue |
| ISQLight::SpectralRadiantPowerUnit | alias |  |  |
| ISQLight::SpectralRadiantPowerValue | alias |  |  |
| ISQLight::SpeedOfLightInAMediumUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::SpeedOfLightInAMediumUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQLight::SpeedOfLightInAMediumUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::SpeedOfLightInAMediumUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::SpeedOfLightInAMediumValue | attribute def |  |  |
| num | attribute | Real | ISQLight::SpeedOfLightInAMediumValue |
| mRef | attribute | SpeedOfLightInAMediumUnit | ISQLight::SpeedOfLightInAMediumValue |
| ISQElectromagnetism::SpeedOfLightUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SpeedOfLightUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SpeedOfLightUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::SpeedOfLightUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::SpeedOfLightValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::SpeedOfLightValue |
| mRef | attribute | SpeedOfLightUnit | ISQElectromagnetism::SpeedOfLightValue |
| ISQSpaceTime::SpeedUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::SpeedUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQSpaceTime::SpeedUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::SpeedUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::SpeedValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::SpeedValue |
| mRef | attribute | SpeedUnit | ISQSpaceTime::SpeedValue |
| ISQSpaceTime::SphericalDisplacement3dVector | attribute def |  |  |
| radialDistance | attribute | LengthValue | ISQSpaceTime::SphericalDisplacement3dVector |
| inclination | attribute | AngularMeasureUnit | ISQSpaceTime::SphericalDisplacement3dVector |
| azimuth | attribute | AngularMeasureUnit | ISQSpaceTime::SphericalDisplacement3dVector |
| mRef | attribute | SphericalSpatial3dCoordinateFrame | ISQSpaceTime::SphericalDisplacement3dVector |
| ISQSpaceTime::SphericalPosition3dVector | attribute def |  |  |
| radialDistance | attribute | LengthValue | ISQSpaceTime::SphericalPosition3dVector |
| inclination | attribute | AngularMeasureUnit | ISQSpaceTime::SphericalPosition3dVector |
| azimuth | attribute | AngularMeasureUnit | ISQSpaceTime::SphericalPosition3dVector |
| mRef | attribute | SphericalSpatial3dCoordinateFrame | ISQSpaceTime::SphericalPosition3dVector |
| ISQSpaceTime::SphericalSpatial3dCoordinateFrame | attribute def |  |  |
| radialDistanceUnit | attribute | LengthUnit | ISQSpaceTime::SphericalSpatial3dCoordinateFrame |
| inclinationUnit | attribute | AngularMeasureUnit | ISQSpaceTime::SphericalSpatial3dCoordinateFrame |
| azimuthUnit | attribute | AngularMeasureUnit | ISQSpaceTime::SphericalSpatial3dCoordinateFrame |
| mRefs | attribute | ScalarMeasurementReference | ISQSpaceTime::SphericalSpatial3dCoordinateFrame |
| isOrthogonal | attribute | Boolean | ISQSpaceTime::SphericalSpatial3dCoordinateFrame |
| ISQAtomicNuclear::SpinUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SpinUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SpinUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SpinUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::SpinUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::SpinValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::SpinValue |
| mRef | attribute | SpinUnit | ISQAtomicNuclear::SpinValue |
| ISQChemistryMolecular::StandardAbsoluteActivityInMixtureValue | attribute def |  |  |
| ISQChemistryMolecular::StandardAbsoluteActivityInSolutionValue | attribute def |  |  |
| ISQChemistryMolecular::StandardAbsoluteActivityOfSolventValue | attribute def |  |  |
| ISQChemistryMolecular::StandardChemicalPotentialUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::StandardChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::StandardChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::StandardChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| amountOfSubstancePF | attribute | QuantityPowerFactor | ISQChemistryMolecular::StandardChemicalPotentialUnit |
| quantity | attribute | ScalarQuantityValue | amountOfSubstancePF |
| exponent | attribute | Real | amountOfSubstancePF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::StandardChemicalPotentialUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::StandardChemicalPotentialValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::StandardChemicalPotentialValue |
| mRef | attribute | StandardChemicalPotentialUnit | ISQChemistryMolecular::StandardChemicalPotentialValue |
| ISQChemistryMolecular::StandardEquilibriumConstantValue | attribute def |  |  |
| ISQCharacteristicNumbers::StantonNumberForMassTransferValue | attribute def |  |  |
| ISQCharacteristicNumbers::StantonNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::StarkNumberValue | attribute def |  |  |
| ISQMechanics::StaticFrictionCoefficientValue | attribute def |  |  |
| ISQCharacteristicNumbers::StefanNumberValue | attribute def |  |  |
| ISQChemistryMolecular::StoichiometricNumberOfSubstanceValue | attribute def |  |  |
| ISQCharacteristicNumbers::StokesNumberForDragValue | attribute def |  |  |
| ISQCharacteristicNumbers::StokesNumberForGravityValue | attribute def |  |  |
| ISQCharacteristicNumbers::StokesNumberForRotameterValue | attribute def |  |  |
| ISQCharacteristicNumbers::StokesNumberForVibratingParticlesValue | attribute def |  |  |
| ISQCharacteristicNumbers::StokesNumberValue | attribute def |  |  |
| ISQInformation::StorageCapacityUnit | attribute def |  |  |
| ISQInformation::StorageCapacityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::StorageCapacityValue |
| mRef | attribute | StorageCapacityUnit | ISQInformation::StorageCapacityValue |
| ISQInformation::StorageSizeUnit | alias |  |  |
| ISQInformation::StorageSizeValue | alias |  |  |
| ISQMechanics::StrainUnit | attribute def |  |  |
| ISQMechanics::StrainValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::StrainValue |
| mRef | attribute | StrainUnit | ISQMechanics::StrainValue |
| ISQMechanics::StressUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::StressUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::StressUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::StressUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::StressUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::StressValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::StressValue |
| mRef | attribute | StressUnit | ISQMechanics::StressValue |
| ScalarValues::String | datatype |  |  |
| ISQCharacteristicNumbers::StrouhalNumberValue | attribute def |  |  |
| ISQCondensedMatter::StructureFactorValue | attribute def |  |  |
| ISQCharacteristicNumbers::StuartElectricalNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::StuartNumberValue | attribute def |  |  |
| ISQAtomicNuclear::SurfaceActivityDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SurfaceActivityDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::SurfaceActivityDensityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::SurfaceActivityDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::SurfaceActivityDensityValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::SurfaceActivityDensityValue |
| mRef | attribute | SurfaceActivityDensityUnit | ISQAtomicNuclear::SurfaceActivityDensityValue |
| ISQThermodynamics::SurfaceCoefficientOfHeatTransferUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::SurfaceCoefficientOfHeatTransferUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::SurfaceCoefficientOfHeatTransferUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::SurfaceCoefficientOfHeatTransferUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::SurfaceCoefficientOfHeatTransferUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::SurfaceCoefficientOfHeatTransferValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::SurfaceCoefficientOfHeatTransferValue |
| mRef | attribute | SurfaceCoefficientOfHeatTransferUnit | ISQThermodynamics::SurfaceCoefficientOfHeatTransferValue |
| ISQElectromagnetism::SurfaceDensityOfElectricChargeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SurfaceDensityOfElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SurfaceDensityOfElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SurfaceDensityOfElectricChargeUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::SurfaceDensityOfElectricChargeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::SurfaceDensityOfElectricChargeValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::SurfaceDensityOfElectricChargeValue |
| mRef | attribute | SurfaceDensityOfElectricChargeUnit | ISQElectromagnetism::SurfaceDensityOfElectricChargeValue |
| ISQMechanics::SurfaceDensityUnit | alias |  |  |
| ISQMechanics::SurfaceDensityValue | alias |  |  |
| ISQMechanics::SurfaceMassDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::SurfaceMassDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::SurfaceMassDensityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::SurfaceMassDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::SurfaceMassDensityValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::SurfaceMassDensityValue |
| mRef | attribute | SurfaceMassDensityUnit | ISQMechanics::SurfaceMassDensityValue |
| ISQMechanics::SurfaceTensionUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::SurfaceTensionUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::SurfaceTensionUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::SurfaceTensionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::SurfaceTensionValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::SurfaceTensionValue |
| mRef | attribute | SurfaceTensionUnit | ISQMechanics::SurfaceTensionValue |
| ISQElectromagnetism::SusceptanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SusceptanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SusceptanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SusceptanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::SusceptanceUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::SusceptanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::SusceptanceValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::SusceptanceValue |
| mRef | attribute | SusceptanceUnit | ISQElectromagnetism::SusceptanceValue |
| SI::sievert | attribute | DoseEquivalentUnit |  |
| SI::'sievert per second' | attribute | DoseEquivalentUnit |  |
| SI::'siemens metre squared per mole' | attribute | MolarConductivityUnit |  |
| SI::tesla | attribute | MagneticFluxDensityUnit |  |
| ISQCharacteristicNumbers::TaylorNumberValue | attribute def |  |  |
| ISQ::TemperatureDifferenceUnit | attribute def |  |  |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQ::TemperatureDifferenceUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQ::TemperatureDifferenceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQ::TemperatureDifferenceValue | attribute def |  |  |
| num | attribute | Real | ISQ::TemperatureDifferenceValue |
| mRef | attribute | TemperatureDifferenceUnit | ISQ::TemperatureDifferenceValue |
| ISQThermodynamics::TemperatureUnit | alias |  |  |
| ISQThermodynamics::TemperatureValue | alias |  |  |
| ISQThermodynamics::ThermalConductanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductanceUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::ThermalConductanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::ThermalConductanceValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::ThermalConductanceValue |
| mRef | attribute | ThermalConductanceUnit | ISQThermodynamics::ThermalConductanceValue |
| ISQThermodynamics::ThermalConductivityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductivityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductivityUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalConductivityUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::ThermalConductivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::ThermalConductivityValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::ThermalConductivityValue |
| mRef | attribute | ThermalConductivityUnit | ISQThermodynamics::ThermalConductivityValue |
| ISQChemistryMolecular::ThermalDiffusionCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ThermalDiffusionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQChemistryMolecular::ThermalDiffusionCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQChemistryMolecular::ThermalDiffusionCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQChemistryMolecular::ThermalDiffusionCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::ThermalDiffusionCoefficientValue |
| mRef | attribute | ThermalDiffusionCoefficientUnit | ISQChemistryMolecular::ThermalDiffusionCoefficientValue |
| ISQChemistryMolecular::ThermalDiffusionFactorValue | attribute def |  |  |
| ISQChemistryMolecular::ThermalDiffusionRatioValue | attribute def |  |  |
| ISQThermodynamics::ThermalDiffusivityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalDiffusivityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalDiffusivityUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::ThermalDiffusivityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::ThermalDiffusivityValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::ThermalDiffusivityValue |
| mRef | attribute | ThermalDiffusivityUnit | ISQThermodynamics::ThermalDiffusivityValue |
| ISQThermodynamics::ThermalEfficiencyValue | attribute def |  |  |
| ISQThermodynamics::ThermalInsulanceUnit | attribute def |  |  |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalInsulanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalInsulanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalInsulanceUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::ThermalInsulanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::ThermalInsulanceValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::ThermalInsulanceValue |
| mRef | attribute | ThermalInsulanceUnit | ISQThermodynamics::ThermalInsulanceValue |
| ISQThermodynamics::ThermalResistanceUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalResistanceUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalResistanceUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalResistanceUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQThermodynamics::ThermalResistanceUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQThermodynamics::ThermalResistanceUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQThermodynamics::ThermalResistanceValue | attribute def |  |  |
| num | attribute | Real | ISQThermodynamics::ThermalResistanceValue |
| mRef | attribute | ThermalResistanceUnit | ISQThermodynamics::ThermalResistanceValue |
| ISQAtomicNuclear::ThermalUtilizationFactorUnit | attribute def |  |  |
| ISQAtomicNuclear::ThermalUtilizationFactorValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::ThermalUtilizationFactorValue |
| mRef | attribute | ThermalUtilizationFactorUnit | ISQAtomicNuclear::ThermalUtilizationFactorValue |
| ISQCondensedMatter::'ThermodynamicGrüneisenParameterValue' | attribute def |  |  |
| ISQBase::ThermodynamicTemperatureUnit | attribute def |  |  |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQBase::ThermodynamicTemperatureUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQBase::ThermodynamicTemperatureUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQBase::ThermodynamicTemperatureValue | attribute def |  |  |
| num | attribute | Real | ISQBase::ThermodynamicTemperatureValue |
| mRef | attribute | ThermodynamicTemperatureUnit | ISQBase::ThermodynamicTemperatureValue |
| ISQCondensedMatter::ThomsonCoefficientUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQCondensedMatter::ThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQCondensedMatter::ThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQCondensedMatter::ThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQCondensedMatter::ThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| thermodynamicTemperaturePF | attribute | QuantityPowerFactor | ISQCondensedMatter::ThomsonCoefficientUnit |
| quantity | attribute | ScalarQuantityValue | thermodynamicTemperaturePF |
| exponent | attribute | Real | thermodynamicTemperaturePF |
| quantityDimension | attribute | QuantityDimension | ISQCondensedMatter::ThomsonCoefficientUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQCondensedMatter::ThomsonCoefficientValue | attribute def |  |  |
| num | attribute | Real | ISQCondensedMatter::ThomsonCoefficientValue |
| mRef | attribute | ThomsonCoefficientUnit | ISQCondensedMatter::ThomsonCoefficientValue |
| ISQCharacteristicNumbers::ThrustCoefficientValue | attribute def |  |  |
| ISQSpaceTime::TimeUnit | alias |  |  |
| ISQSpaceTime::TimeValue | alias |  |  |
| ISQMechanics::TorqueUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::TorqueUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQMechanics::TorqueUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::TorqueUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::TorqueUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::TorqueValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::TorqueValue |
| mRef | attribute | TorqueUnit | ISQMechanics::TorqueValue |
| ISQAtomicNuclear::TotalAngularMomentumUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalAngularMomentumUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalAngularMomentumUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalAngularMomentumUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::TotalAngularMomentumUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::TotalAngularMomentumValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::TotalAngularMomentumValue |
| mRef | attribute | TotalAngularMomentumUnit | ISQAtomicNuclear::TotalAngularMomentumValue |
| ISQElectromagnetism::TotalCurrentDensityUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQElectromagnetism::TotalCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| electricCurrentPF | attribute | QuantityPowerFactor | ISQElectromagnetism::TotalCurrentDensityUnit |
| quantity | attribute | ScalarQuantityValue | electricCurrentPF |
| exponent | attribute | Real | electricCurrentPF |
| quantityDimension | attribute | QuantityDimension | ISQElectromagnetism::TotalCurrentDensityUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQElectromagnetism::TotalCurrentDensityValue | attribute def |  |  |
| num | attribute | Real | ISQElectromagnetism::TotalCurrentDensityValue |
| mRef | attribute | TotalCurrentDensityUnit | ISQElectromagnetism::TotalCurrentDensityValue |
| ISQAtomicNuclear::TotalIonizationValue | attribute def |  |  |
| ISQAtomicNuclear::TotalLinearStoppingPowerUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalLinearStoppingPowerUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| massPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalLinearStoppingPowerUnit |
| quantity | attribute | ScalarQuantityValue | massPF |
| exponent | attribute | Real | massPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalLinearStoppingPowerUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::TotalLinearStoppingPowerUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::TotalLinearStoppingPowerValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::TotalLinearStoppingPowerValue |
| mRef | attribute | TotalLinearStoppingPowerUnit | ISQAtomicNuclear::TotalLinearStoppingPowerValue |
| ISQAtomicNuclear::TotalMassStoppingPowerUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalMassStoppingPowerUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::TotalMassStoppingPowerUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::TotalMassStoppingPowerUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::TotalMassStoppingPowerValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::TotalMassStoppingPowerValue |
| mRef | attribute | TotalMassStoppingPowerUnit | ISQAtomicNuclear::TotalMassStoppingPowerValue |
| ISQInformation::TrafficCarriedIntensityUnit | attribute def |  |  |
| ISQInformation::TrafficCarriedIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::TrafficCarriedIntensityValue |
| mRef | attribute | TrafficCarriedIntensityUnit | ISQInformation::TrafficCarriedIntensityValue |
| ISQInformation::TrafficIntensityUnit | attribute def |  |  |
| ISQInformation::TrafficIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::TrafficIntensityValue |
| mRef | attribute | TrafficIntensityUnit | ISQInformation::TrafficIntensityValue |
| ISQInformation::TrafficLoadUnit | alias |  |  |
| ISQInformation::TrafficLoadValue | alias |  |  |
| ISQInformation::TrafficOfferedIntensityUnit | attribute def |  |  |
| ISQInformation::TrafficOfferedIntensityValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::TrafficOfferedIntensityValue |
| mRef | attribute | TrafficOfferedIntensityUnit | ISQInformation::TrafficOfferedIntensityValue |
| ISQInformation::TransferRateUnit | attribute def |  |  |
| durationPF | attribute | QuantityPowerFactor | ISQInformation::TransferRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQInformation::TransferRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQInformation::TransferRateValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::TransferRateValue |
| mRef | attribute | TransferRateUnit | ISQInformation::TransferRateValue |
| ISQInformation::TransinformationContentUnit | attribute def |  |  |
| ISQInformation::TransinformationContentValue | attribute def |  |  |
| num | attribute | Real | ISQInformation::TransinformationContentValue |
| mRef | attribute | TransinformationContentUnit | ISQInformation::TransinformationContentValue |
| ISQLight::TransmittanceOpticalDensityValue | attribute def |  |  |
| ISQLight::TransmittanceValue | attribute def |  |  |
| ISQChemistryMolecular::TransportNumberOfTheIonBValue | attribute def |  |  |
| ISQLight::TristimulusValuesForTheCie1931StandardColorimetricObserverUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::TristimulusValuesForTheCie1931StandardColorimetricObserverUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::TristimulusValuesForTheCie1931StandardColorimetricObserverUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::TristimulusValuesForTheCie1931StandardColorimetricObserverUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::TristimulusValuesForTheCie1931StandardColorimetricObserverValue | attribute def |  |  |
| num | attribute | Real | ISQLight::TristimulusValuesForTheCie1931StandardColorimetricObserverValue |
| mRef | attribute | TristimulusValuesForTheCie1931StandardColorimetricObserverUnit | ISQLight::TristimulusValuesForTheCie1931StandardColorimetricObserverValue |
| ISQLight::TristimulusValuesForTheCie1964StandardColorimetricObserverUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQLight::TristimulusValuesForTheCie1964StandardColorimetricObserverUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| luminousIntensityPF | attribute | QuantityPowerFactor | ISQLight::TristimulusValuesForTheCie1964StandardColorimetricObserverUnit |
| quantity | attribute | ScalarQuantityValue | luminousIntensityPF |
| exponent | attribute | Real | luminousIntensityPF |
| quantityDimension | attribute | QuantityDimension | ISQLight::TristimulusValuesForTheCie1964StandardColorimetricObserverUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQLight::TristimulusValuesForTheCie1964StandardColorimetricObserverValue | attribute def |  |  |
| num | attribute | Real | ISQLight::TristimulusValuesForTheCie1964StandardColorimetricObserverValue |
| mRef | attribute | TristimulusValuesForTheCie1964StandardColorimetricObserverUnit | ISQLight::TristimulusValuesForTheCie1964StandardColorimetricObserverValue |
| SI::volt | attribute | ElectricPotentialUnit |  |
| SI::'volt per kelvin' | attribute | SeebeckCoefficientForSubstancesAAndBUnit |  |
| SI::'volt per metre' | attribute | ElectricFieldStrengthUnit |  |
| ISQMechanics::ViscosityUnit | alias |  |  |
| ISQMechanics::ViscosityValue | alias |  |  |
| ISQMechanics::VolumeFlowRateUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQMechanics::VolumeFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| durationPF | attribute | QuantityPowerFactor | ISQMechanics::VolumeFlowRateUnit |
| quantity | attribute | ScalarQuantityValue | durationPF |
| exponent | attribute | Real | durationPF |
| quantityDimension | attribute | QuantityDimension | ISQMechanics::VolumeFlowRateUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQMechanics::VolumeFlowRateValue | attribute def |  |  |
| num | attribute | Real | ISQMechanics::VolumeFlowRateValue |
| mRef | attribute | VolumeFlowRateUnit | ISQMechanics::VolumeFlowRateValue |
| ISQChemistryMolecular::VolumeFractionUnit | attribute def |  |  |
| ISQChemistryMolecular::VolumeFractionValue | attribute def |  |  |
| num | attribute | Real | ISQChemistryMolecular::VolumeFractionValue |
| mRef | attribute | VolumeFractionUnit | ISQChemistryMolecular::VolumeFractionValue |
| ISQSpaceTime::VolumeUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQSpaceTime::VolumeUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQSpaceTime::VolumeUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQSpaceTime::VolumeValue | attribute def |  |  |
| num | attribute | Real | ISQSpaceTime::VolumeValue |
| mRef | attribute | VolumeUnit | ISQSpaceTime::VolumeValue |
| ISQAtomicNuclear::VolumicActivityUnit | alias |  |  |
| ISQAtomicNuclear::VolumicActivityValue | alias |  |  |
| ISQAtomicNuclear::VolumicCrossSectionUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::VolumicCrossSectionUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::VolumicCrossSectionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::VolumicCrossSectionValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::VolumicCrossSectionValue |
| mRef | attribute | VolumicCrossSectionUnit | ISQAtomicNuclear::VolumicCrossSectionValue |
| ISQElectromagnetism::VolumicElectricChargeUnit | alias |  |  |
| ISQElectromagnetism::VolumicElectricChargeValue | alias |  |  |
| ISQElectromagnetism::VolumicElectromagneticEnergyUnit | alias |  |  |
| ISQElectromagnetism::VolumicElectromagneticEnergyValue | alias |  |  |
| ISQAtomicNuclear::VolumicTotalCrossSectionUnit | attribute def |  |  |
| lengthPF | attribute | QuantityPowerFactor | ISQAtomicNuclear::VolumicTotalCrossSectionUnit |
| quantity | attribute | ScalarQuantityValue | lengthPF |
| exponent | attribute | Real | lengthPF |
| quantityDimension | attribute | QuantityDimension | ISQAtomicNuclear::VolumicTotalCrossSectionUnit |
| quantityPowerFactors | attribute | QuantityPowerFactor | quantityDimension |
| ISQAtomicNuclear::VolumicTotalCrossSectionValue | attribute def |  |  |
| num | attribute | Real | ISQAtomicNuclear::VolumicTotalCrossSectionValue |
| mRef | attribute | VolumicTotalCrossSectionUnit | ISQAtomicNuclear::VolumicTotalCrossSectionValue |
| SI::'volt to the power 2 per kelvin to the power 2' | attribute | LorenzCoefficientUnit |  |
| SI::'volt ampere' | attribute | PowerUnit |  |
| SI::watt | attribute | PowerUnit |  |
| SI::'watt per square metre kelvin' | attribute | CoefficientOfHeatTransferUnit |  |
| SI::'watt per square metre nm' | attribute | SpectralIrradianceUnit |  |
| SI::'watt per metre kelvin' | attribute | ThermalConductivityUnit |  |
| SI::'watt per steradian square metre' | attribute | RadianceUnit |  |
| SI::'watt per steradian square metre nm' | attribute | SpectralRadianceUnit |  |
| SI::'watt per steradian nm' | attribute | SpectralRadiantIntensityUnit |  |
| SI::'watt per kelvin' | attribute | ThermalConductanceUnit |  |
| SI::'watt per kilogram' | attribute | DoseEquivalentUnit |  |
| SI::'watt per square metre' | attribute | DensityOfHeatFlowRateUnit |  |
| SI::'watt per nm' | attribute | SpectralRadiantFluxUnit |  |
| SI::'watt per steradian' | attribute | RadiantIntensityUnit |  |
| ISQInformation::WaitingProbabilityValue | attribute def |  |  |
| ISQSpaceTime::WavenumberUnit | alias |  |  |
| ISQSpaceTime::WavenumberValue | alias |  |  |
| SI::weber | attribute | MagneticFluxUnit |  |
| SI::'weber per metre' | attribute | MagneticVectorPotentialUnit |  |
| SI::'weber metre' | attribute | ISQElectromagnetism::MagneticDipoleMomentUnit |  |
| ISQCharacteristicNumbers::WeberNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::WeissenbergNumberValue | attribute def |  |  |
| ISQCharacteristicNumbers::WomersleyNumberValue | attribute def |  |  |
| SI::'watt hour' | attribute | EnergyUnit |  |
| ISQMechanics::YoungModulusUnit | alias |  |  |
| ISQMechanics::YoungModulusValue | alias |  |  |
| ISQChemistryMolecular::absoluteActivity | attribute | AbsoluteActivityValue |  |
| ISQAtomicNuclear::absorbedDose | attribute | AbsorbedDoseValue |  |
| ISQAtomicNuclear::absorbedDoseRate | attribute | AbsorbedDoseRateValue |  |
| ISQLight::absorptance | attribute | AbsorptanceValue |  |
| ISQCharacteristicNumbers::absorptionNumber | attribute | AbsorptionNumberValue |  |
| ISQSpaceTime::acceleration | attribute | AccelerationValue |  |
| ISQCondensedMatter::acceptorDensity | attribute | AcceptorDensityValue |  |
| ISQAcoustics::acousticImpedance | attribute | AcousticImpedanceValue |  |
| ISQMechanics::actionQuantity | attribute | ActionQuantityValue |  |
| ISQElectromagnetism::activeEnergy | attribute | EnergyValue |  |
| ISQElectromagnetism::activePower | attribute | PowerValue |  |
| ISQChemistryMolecular::activityCoefficient | attribute | ActivityCoefficientValue |  |
| ISQAtomicNuclear::activityConcentration | alias |  |  |
| ISQAtomicNuclear::activityDensity | attribute | ActivityDensityValue |  |
| ISQChemistryMolecular::activityFactor | attribute | ActivityFactorValue |  |
| ISQChemistryMolecular::activityOfSolute | attribute | ActivityOfSoluteValue |  |
| ISQChemistryMolecular::activityOfSolvent | attribute | ActivityOfSolventValue |  |
| ISQElectromagnetism::admittance | attribute | AdmittanceValue |  |
| ISQCharacteristicNumbers::aeroelasticityParameter | alias |  |  |
| ISQChemistryMolecular::affinityOfAChemicalReaction | attribute | AffinityOfAChemicalReactionValue |  |
| ISQCharacteristicNumbers::'alfvénNumber' | attribute | 'AlfvénNumberValue' |  |
| ISQAtomicNuclear::alphaDisintegrationEnergy | attribute | EnergyValue |  |
| ISQSpaceTime::altitude | alias |  |  |
| ISQThermodynamics::amountOfHeat | alias |  |  |
| ISQBase::amountOfSubstance | attribute | AmountOfSubstanceValue |  |
| ISQChemistryMolecular::amountOfSubstanceConcentration | attribute | AmountOfSubstanceConcentrationValue |  |
| ISQChemistryMolecular::amountOfSubstanceFractionMoleFraction | attribute | AmountOfSubstanceFractionMoleFractionValue |  |
| ISQCharacteristicNumbers::'ampèreNumber' | attribute | 'AmpèreNumberValue' |  |
| ISQChemistryMolecular::angleOfOpticalRotation | attribute | AngularMeasureValue |  |
| ISQSpaceTime::angularAcceleration | attribute | AngularAccelerationValue |  |
| ISQSpaceTime::angularDisplacement | alias |  |  |
| ISQSpaceTime::angularFrequency | attribute | AngularFrequencyValue |  |
| ISQMechanics::angularImpulse | attribute | AngularImpulseValue |  |
| ISQSpaceTime::angularMeasure | attribute | AngularMeasureValue |  |
| ISQMechanics::angularMomentum | attribute | AngularMomentumValue |  |
| ISQCondensedMatter::angularReciprocalLatticeVectorMagnitude | attribute | AngularReciprocalLatticeVectorMagnitudeValue |  |
| ISQCondensedMatter::angularRepetency | alias |  |  |
| ISQSpaceTime::angularRepetency | attribute | AngularRepetencyValue |  |
| ISQSpaceTime::angularVelocity | attribute | AngularVelocityValue |  |
| ISQCondensedMatter::angularWavenumber | attribute | RepetencyValue |  |
| ISQSpaceTime::angularWavenumber | alias |  |  |
| ISQElectromagnetism::apparentPower | attribute | PowerValue |  |
| ISQSpaceTime::arcLength | alias |  |  |
| ISQCharacteristicNumbers::archimedesNumber | attribute | ArchimedesNumberValue |  |
| SI::arcmin | alias |  |  |
| SI::arcsec | alias |  |  |
| ISQSpaceTime::area | attribute | AreaValue |  |
| ISQElectromagnetism::areicElectricCharge | alias |  |  |
| ISQCharacteristicNumbers::arrheniusNumber | attribute | ArrheniusNumberValue |  |
| SI::'astronomical unit' | attribute | LengthUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::'astronomical unit' |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| isExact | attribute | Boolean | unitConversion |
| SI::'atomic mass unit' | attribute | MassUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::'atomic mass unit' |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| ISQAtomicNuclear::atomicAttenuationCoefficient | attribute | AtomicAttenuationCoefficientValue |  |
| ISQAtomicNuclear::atomicMass | attribute | MassValue |  |
| ISQAtomicNuclear::atomicNumber | attribute | CountValue |  |
| ISQCondensedMatter::atomicScatteringFactor | attribute | AtomicScatteringFactorValue |  |
| ISQSpaceTime::attenuation | attribute | AttenuationValue |  |
| SIPrefixes::atto | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::atto |
| symbol | attribute | String | SIPrefixes::atto |
| conversionFactor | attribute | Real | SIPrefixes::atto |
| ISQCharacteristicNumbers::atwoodNumber | attribute | AtwoodNumberValue |  |
| ISQInformation::averageConditionalInformationContent | alias |  |  |
| ISQAtomicNuclear::averageEnergyLossPerElementaryChargeProduced | attribute | AverageEnergyLossPerElementaryChargeProducedValue |  |
| ISQInformation::averageInformationRate | attribute | AverageInformationRateValue |  |
| ISQAtomicNuclear::averageLogarithmicEnergyDecrement | attribute | AverageLogarithmicEnergyDecrementValue |  |
| ISQInformation::averageTransinformationRate | attribute | AverageTransinformationRateValue |  |
| SI::barn | attribute | AreaUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::barn |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| ISQCharacteristicNumbers::bagnoldNumber | attribute | BagnoldNumberValue |  |
| ISQCharacteristicNumbers::bagnoldNumberForSolidParticles | attribute | BagnoldNumberForSolidParticlesValue |  |
| ISQCharacteristicNumbers::batchelorNumber | attribute | BatchelorNumberValue |  |
| ISQCharacteristicNumbers::bejanNumber | attribute | BejanNumberValue |  |
| ISQCharacteristicNumbers::bejanNumberForEntropy | attribute | BejanNumberForEntropyValue |  |
| ISQCharacteristicNumbers::bejanNumberForHeatTransfer | attribute | BejanNumberForHeatTransferValue |  |
| ISQCharacteristicNumbers::bejanNumberForMassTransfer | attribute | BejanNumberForMassTransferValue |  |
| ISQAtomicNuclear::betaDisintegrationEnergy | attribute | EnergyValue |  |
| ISQInformation::binaryDigitRate | attribute | BinaryDigitRateValue |  |
| ISQAtomicNuclear::bindingFraction | attribute | BindingFractionValue |  |
| ISQCharacteristicNumbers::binghamNumber | attribute | BinghamNumberValue |  |
| ISQCharacteristicNumbers::biotNumber | attribute | BiotNumberValue |  |
| ISQCharacteristicNumbers::biotNumberForMassTransfer | attribute | BiotNumberForMassTransferValue |  |
| SI::bit | attribute | StorageCapacityUnit |  |
| SI::'bit per second' | attribute | BinaryDigitRateUnit |  |
| ISQInformation::bitPeriod | alias |  |  |
| ISQInformation::bitRate | alias |  |  |
| ISQCharacteristicNumbers::blakeNumber | attribute | BlakeNumberValue |  |
| ISQCharacteristicNumbers::bodensteinNumber | attribute | BodensteinNumberValue |  |
| ISQAtomicNuclear::bohrMagneton | attribute | MagneticDipoleMomentValue |  |
| ISQAtomicNuclear::bohrRadius | attribute | LengthValue |  |
| ISQCharacteristicNumbers::boltzmannNumber | attribute | BoltzmannNumberValue |  |
| ISQCharacteristicNumbers::bondNumber | attribute | BondNumberValue |  |
| ISQCondensedMatter::braggAngle | attribute | AngularMeasureValue |  |
| ISQSpaceTime::breadth | alias |  |  |
| ISQCharacteristicNumbers::brinkmanNumber | attribute | BrinkmanNumberValue |  |
| ISQMechanics::bulkModulus | alias |  |  |
| ISQInformation::callIntensity | attribute | CallIntensityValue |  |
| ISQInformation::callingRate | alias |  |  |
| SI::candela | attribute | LuminousIntensityUnit |  |
| SI::'candela metre to the power minus 2' | attribute | LuminanceUnit |  |
| SI::'candela steradian' | attribute | LuminousFluxUnit |  |
| SI::'candela steradian kilogram to the power minus 1 metre to the power minus 2 second to the power 3' | attribute | LuminousEfficacyOfRadiationUnit |  |
| SI::'candela steradian metre to the power minus 2' | attribute | IlluminanceUnit |  |
| SI::'candela steradian metre to the power minus 2 second' | attribute | LuminousExposureUnit |  |
| SI::'candela steradian second' | attribute | LuminousEnergyUnit |  |
| ISQChemistryMolecular::canonicalPartitionFunction | attribute | CanonicalPartitionFunctionValue |  |
| ISQElectromagnetism::capacitance | attribute | CapacitanceValue |  |
| ISQCharacteristicNumbers::capillaryNumber | attribute | CapillaryNumberValue |  |
| ISQCharacteristicNumbers::carnotNumber | attribute | CarnotNumberValue |  |
| ISQCondensedMatter::carrierLifetime | attribute | DurationValue |  |
| ISQInformation::carrierPower | attribute | PowerValue |  |
| ISQSpaceTime::cartesianAcceleration3dVector | attribute | CartesianAcceleration3dVector |  |
| ISQSpaceTime::cartesianAngularAcceleration3dVector | attribute | CartesianAngularAcceleration3dVector |  |
| ISQMechanics::cartesianAngularImpulse3dVector | attribute | CartesianAngularImpulse3dVector |  |
| ISQMechanics::cartesianAngularMomentum3dVector | attribute | CartesianAngularMomentum3dVector |  |
| ISQCondensedMatter::cartesianAngularReciprocalLattice3dVector | attribute | CartesianAngularReciprocalLattice3dVector |  |
| ISQSpaceTime::cartesianAngularVelocity3dVector | attribute | CartesianAngularVelocity3dVector |  |
| ISQElectromagnetism::cartesianAreicElectricCurrent3dVector | alias |  |  |
| ISQCondensedMatter::cartesianBurgers3dVector | attribute | CartesianBurgers3dVector |  |
| ISQCondensedMatter::cartesianDisplacement3dVector | attribute | CartesianDisplacement3dVector |  |
| ISQSpaceTime::cartesianDisplacement3dVector | attribute | CartesianDisplacement3dVector |  |
| ISQElectromagnetism::cartesianDisplacementCurrentDensity3dVector | attribute | CartesianDisplacementCurrentDensity3dVector |  |
| ISQMechanics::cartesianDragForce3dVector | attribute | CartesianDragForce3dVector |  |
| ISQMechanics::cartesianDynamicFrictionForce3dVector | alias |  |  |
| ISQElectromagnetism::cartesianElectricCurrentDensity3dVector | attribute | CartesianElectricCurrentDensity3dVector |  |
| ISQElectromagnetism::cartesianElectricDipoleMoment3dVector | attribute | CartesianElectricDipoleMoment3dVector |  |
| ISQElectromagnetism::cartesianElectricDisplacement3dVector | alias |  |  |
| ISQElectromagnetism::cartesianElectricFieldStrength3dVector | attribute | CartesianElectricFieldStrength3dVector |  |
| ISQElectromagnetism::cartesianElectricFluxDensity3dVector | attribute | CartesianElectricFluxDensity3dVector |  |
| ISQElectromagnetism::cartesianElectricPolarization3dVector | attribute | CartesianElectricPolarization3dVector |  |
| ISQCondensedMatter::cartesianEquilibriumPosition3dVector | attribute | CartesianEquilibriumPosition3dVector |  |
| ISQMechanics::cartesianForce3dVector | attribute | CartesianForce3dVector |  |
| ISQCondensedMatter::cartesianFundamentalLattice3dVector | attribute | CartesianFundamentalLattice3dVector |  |
| ISQCondensedMatter::cartesianFundamentalReciprocalLattice3dVector | attribute | CartesianFundamentalReciprocalLattice3dVector |  |
| ISQMechanics::cartesianImpulse3dVector | attribute | CartesianImpulse3dVector |  |
| ISQMechanics::cartesianKineticFrictionForce3dVector | attribute | CartesianKineticFrictionForce3dVector |  |
| ISQCondensedMatter::cartesianLattice3dVector | attribute | CartesianLattice3dVector |  |
| ISQElectromagnetism::cartesianLinearElectricCurrentDensity3dVector | attribute | CartesianLinearElectricCurrentDensity3dVector |  |
| ISQElectromagnetism::cartesianLineicElectricCurrent3dVector | alias |  |  |
| ISQElectromagnetism::cartesianMagneticAreaMoment3dVector | alias |  |  |
| ISQAtomicNuclear::cartesianMagneticDipoleMoment3dVector | attribute | CartesianMagneticDipoleMoment3dVector |  |
| ISQElectromagnetism::cartesianMagneticDipoleMoment3dVector | attribute | CartesianMagneticDipoleMoment3dVector |  |
| ISQElectromagnetism::cartesianMagneticFieldStrength3dVector | attribute | CartesianMagneticFieldStrength3dVector |  |
| ISQElectromagnetism::cartesianMagneticFluxDensity3dVector | attribute | CartesianMagneticFluxDensity3dVector |  |
| ISQElectromagnetism::cartesianMagneticMoment3dVector | attribute | CartesianMagneticMoment3dVector |  |
| ISQElectromagnetism::cartesianMagneticPolarization3dVector | attribute | CartesianMagneticPolarization3dVector |  |
| ISQElectromagnetism::cartesianMagneticVectorPotential3dVector | attribute | CartesianMagneticVectorPotential3dVector |  |
| ISQElectromagnetism::cartesianMagnetization3dVector | attribute | CartesianMagnetization3dVector |  |
| ISQElectromagnetism::cartesianMagnetizingField3dVector | alias |  |  |
| ISQMechanics::cartesianMassFlow3dVector | attribute | CartesianMassFlow3dVector |  |
| ISQMechanics::cartesianMomentOfForce3dVector | attribute | CartesianMomentOfForce3dVector |  |
| ISQMechanics::cartesianMomentum3dVector | attribute | CartesianMomentum3dVector |  |
| ISQAtomicNuclear::cartesianParticleCurrentDensity3dVector | attribute | CartesianParticleCurrentDensity3dVector |  |
| ISQCondensedMatter::cartesianParticlePosition3dVector | attribute | CartesianParticlePosition3dVector |  |
| ISQSpaceTime::cartesianPosition3dVector | attribute | CartesianPosition3dVector |  |
| ISQElectromagnetism::cartesianPoynting3dVector | attribute | CartesianPoynting3dVector |  |
| ISQMechanics::cartesianRollingDrag3dVector | alias |  |  |
| ISQMechanics::cartesianRollingFrictionForce3dVector | alias |  |  |
| ISQMechanics::cartesianRollingResistance3dVector | attribute | CartesianRollingResistance3dVector |  |
| ISQAcoustics::cartesianSoundIntensity3dVector | attribute | CartesianSoundIntensity3dVector |  |
| ISQAcoustics::cartesianSoundParticleAcceleration3dVector | attribute | CartesianSoundParticleAcceleration3dVector |  |
| ISQAcoustics::cartesianSoundParticleDisplacement3dVector | attribute | CartesianSoundParticleDisplacement3dVector |  |
| ISQAcoustics::cartesianSoundParticleVelocity3dVector | attribute | CartesianSoundParticleVelocity3dVector |  |
| ISQAtomicNuclear::cartesianSpin3dVector | attribute | CartesianSpin3dVector |  |
| ISQMechanics::cartesianStaticFriction3dVector | alias |  |  |
| ISQMechanics::cartesianStaticFrictionForce3dVector | attribute | CartesianStaticFrictionForce3dVector |  |
| ISQAtomicNuclear::cartesianTotalAngularMomentum3dVector | attribute | CartesianTotalAngularMomentum3dVector |  |
| ISQElectromagnetism::cartesianTotalCurrentDensity3dVector | attribute | CartesianTotalCurrentDensity3dVector |  |
| ISQSpaceTime::cartesianVelocity3dVector | attribute | CartesianVelocity3dVector |  |
| ISQSpaceTime::cartesianWave3dVector | attribute | CartesianWave3dVector |  |
| ISQMechanics::cartesianWeight3dVector | attribute | CartesianWeight3dVector |  |
| ISQCharacteristicNumbers::cauchyNumber | attribute | CauchyNumberValue |  |
| ISQCharacteristicNumbers::cavitationNumber | attribute | CavitationNumberValue |  |
| ISQThermodynamics::celsiusTemperature | attribute | CelsiusTemperatureValue |  |
| SIPrefixes::centi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::centi |
| symbol | attribute | String | SIPrefixes::centi |
| conversionFactor | attribute | Real | SIPrefixes::centi |
| SI::centimetre | attribute | LengthUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::centimetre |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| ISQCharacteristicNumbers::chandrasekharNumber | attribute | ChandrasekharNumberValue |  |
| ISQInformation::channelCapacity | alias |  |  |
| ISQInformation::channelCapacityPerCharacter | attribute | ChannelCapacityPerCharacterValue |  |
| ISQInformation::channelTimeCapacity | attribute | ChannelTimeCapacityValue |  |
| ISQInformation::characterMeanEntropy | attribute | CharacterMeanEntropyValue |  |
| ISQInformation::characterMeanTransinformationContent | attribute | CharacterMeanTransinformationContentValue |  |
| ISQAcoustics::characteristicImpedanceOfAMediumForLongitudinalWaves | attribute | CharacteristicImpedanceOfAMediumForLongitudinalWavesValue |  |
| ISQAtomicNuclear::chargeNumber | attribute | ChargeNumberValue |  |
| ISQChemistryMolecular::chemicalPotential | attribute | ChemicalPotentialValue |  |
| ISQLight::chromaticityCoordinatesInTheCie1931StandardColorimetricSystem | attribute | ChromaticityCoordinatesInTheCie1931StandardColorimetricSystemValue |  |
| ISQLight::chromaticityCoordinatesInTheCie1964StandardColorimetricSystem | attribute | ChromaticityCoordinatesInTheCie1964StandardColorimetricSystemValue |  |
| ISQLight::cieColourMatchingFunctionsForTheCie1931StandardColorimetricObserver | attribute | CieColourMatchingFunctionsForTheCie1931StandardColorimetricObserverValue |  |
| ISQLight::cieColourMatchingFunctionsForTheCie1964StandardColorimetricObserver | attribute | CieColourMatchingFunctionsForTheCie1964StandardColorimetricObserverValue |  |
| ISQCharacteristicNumbers::clausiusNumber | attribute | ClausiusNumberValue |  |
| ISQInformation::clockFrequency | attribute | FrequencyValue |  |
| ISQInformation::clockRate | alias |  |  |
| ISQThermodynamics::coefficientOfHeatTransfer | attribute | CoefficientOfHeatTransferValue |  |
| ISQMechanics::coefficientOfStaticFriction | alias |  |  |
| ISQThermodynamics::coefficientOfThermalInsulance | alias |  |  |
| ISQElectromagnetism::coercivity | attribute | CoercivityValue |  |
| ISQCondensedMatter::coherenceLength | attribute | LengthValue |  |
| ISQCharacteristicNumbers::colburnNumber | alias |  |  |
| ISQLight::colourTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQInformation::completedCallIntensity | attribute | CompletedCallIntensityValue |  |
| ISQElectromagnetism::complexAdmittance | alias |  |  |
| ISQElectromagnetism::complexImpedance | alias |  |  |
| ISQElectromagnetism::complexPower | attribute | PowerValue |  |
| ISQMechanics::compressibility | attribute | CompressibilityValue |  |
| ISQCharacteristicNumbers::compressibilityNumber | attribute | CompressibilityNumberValue |  |
| ISQAtomicNuclear::comptonWavelength | attribute | LengthValue |  |
| ISQInformation::conditionalEntropy | attribute | ConditionalEntropyValue |  |
| ISQInformation::conditionalInformationContent | attribute | ConditionalInformationContentValue |  |
| ISQElectromagnetism::conductance | attribute | ConductanceValue |  |
| ISQElectromagnetism::conductanceForAlternatingCurrent | attribute | ConductanceValue |  |
| ISQElectromagnetism::conductivity | attribute | ConductivityValue |  |
| ISQLight::correlatedColourTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQElectromagnetism::couplingFactor | attribute | CouplingFactorValue |  |
| ISQCharacteristicNumbers::cowlingNumber | attribute | CowlingNumberValue |  |
| ISQAtomicNuclear::crossSection | attribute | AreaValue |  |
| ISQThermodynamics::cubicExpansionCoefficient | attribute | CubicExpansionCoefficientValue |  |
| ISQCondensedMatter::curieTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQChemistryMolecular::currentFractionOfTheIonB | alias |  |  |
| ISQElectromagnetism::currentLinkage | attribute | ElectricCurrentValue |  |
| ISQSpaceTime::curvature | attribute | CurvatureValue |  |
| ISQAtomicNuclear::cyclotronAngularFrequency | attribute | AngularFrequencyValue |  |
| ISQSpaceTime::cylindricalDisplacement3dVector | attribute | CylindricalDisplacement3dVector |  |
| ISQSpaceTime::cylindricalPosition3dVector | attribute | CylindricalPosition3dVector |  |
| SI::day | attribute | DurationUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::day |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| SI::decibel | attribute | SoundPressureLevelUnit |  |
| ISQSpaceTime::dampingCoefficient | attribute | DampingCoefficientValue |  |
| ISQCharacteristicNumbers::darcyFrictionFactor | attribute | DarcyFrictionFactorValue |  |
| ISQCharacteristicNumbers::deanNumber | attribute | DeanNumberValue |  |
| ISQCharacteristicNumbers::deborahNumber | attribute | DeborahNumberValue |  |
| ISQCondensedMatter::debyeAngularFrequency | attribute | AngularFrequencyValue |  |
| ISQCondensedMatter::debyeAngularRepetency | alias |  |  |
| ISQCondensedMatter::debyeAngularWavenumber | attribute | RepetencyValue |  |
| ISQCondensedMatter::debyeTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQCondensedMatter::debyeWallerFactor | attribute | DebyeWallerFactorValue |  |
| SI::decade | attribute | LogarithmicFrequencyRangeUnit |  |
| SIPrefixes::deca | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::deca |
| symbol | attribute | String | SIPrefixes::deca |
| conversionFactor | attribute | Real | SIPrefixes::deca |
| ISQLight::decadicAbsorbance | alias |  |  |
| ISQAtomicNuclear::decayConstant | attribute | DecayConstantValue |  |
| SIPrefixes::deci | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::deci |
| symbol | attribute | String | SIPrefixes::deci |
| conversionFactor | attribute | Real | SIPrefixes::deci |
| ISQInformation::decisionContent | attribute | DecisionContentValue |  |
| ISQChemistryMolecular::degeneracy | attribute | DegeneracyValue |  |
| SI::degree | attribute | AngularMeasureUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::degree |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| isExact | attribute | Boolean | unitConversion |
| SI::'degree celsius (absolute temperature scale)' | attribute | IntervalScale |  |
| unit | attribute | MeasurementUnit | SI::'degree celsius (absolute temperature scale)' |
| temperatureWaterAtFreezingPointInC | attribute | DefinitionalQuantityValue | SI::'degree celsius (absolute temperature scale)' |
| num | attribute | Number | temperatureWaterAtFreezingPointInC |
| definition | attribute | String | temperatureWaterAtFreezingPointInC |
| temperatureWaterAtTriplePointInC | attribute | DefinitionalQuantityValue | SI::'degree celsius (absolute temperature scale)' |
| num | attribute | Number | temperatureWaterAtTriplePointInC |
| definition | attribute | String | temperatureWaterAtTriplePointInC |
| celsiusToKelvinScaleMapping | attribute | QuantityValueMapping | SI::'degree celsius (absolute temperature scale)' |
| mappedQuantityValue | attribute | DefinitionalQuantityValue | celsiusToKelvinScaleMapping |
| referenceQuantityValue | attribute | DefinitionalQuantityValue | celsiusToKelvinScaleMapping |
| definitionalQuantityValues | attribute | DefinitionalQuantityValue | SI::'degree celsius (absolute temperature scale)' |
| quantityValueMapping | attribute | QuantityValueMapping | SI::'degree celsius (absolute temperature scale)' |
| zeroDegreeCelsiusInKelvin | attribute | ThermodynamicTemperatureValue | SI::'degree celsius (absolute temperature scale)' |
| zeroDegreeCelsiusToKelvinShift | attribute | CoordinateFramePlacement | SI::'degree celsius (absolute temperature scale)' |
| source | attribute | VectorMeasurementReference | zeroDegreeCelsiusToKelvinShift |
| origin | attribute | VectorQuantityValue | zeroDegreeCelsiusToKelvinShift |
| SI::'degree celsius (temperature difference)' | attribute | TemperatureDifferenceUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::'degree celsius (temperature difference)' |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| ISQChemistryMolecular::degreeOfDissociation | attribute | DegreeOfDissociationValue |  |
| ISQMechanics::density | alias |  |  |
| ISQThermodynamics::densityOfHeatFlowRate | attribute | DensityOfHeatFlowRateValue |  |
| ISQCondensedMatter::densityOfVibrationalStates | attribute | DensityOfVibrationalStatesValue |  |
| ISQSpaceTime::depth | alias |  |  |
| ISQThermodynamics::dewPointTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQSpaceTime::diameter | attribute | LengthValue |  |
| ISQAtomicNuclear::diffusionArea | attribute | AreaValue |  |
| ISQChemistryMolecular::diffusionCoefficient | attribute | DiffusionCoefficientValue |  |
| ISQAtomicNuclear::diffusionCoefficientForFluenceRate | attribute | LengthValue |  |
| ISQAtomicNuclear::diffusionCoefficientForParticleNumberDensity | alias |  |  |
| ISQAtomicNuclear::diffusionLength | attribute | LengthValue |  |
| ISQCondensedMatter::diffusionLengthForCondensedMatterPhysics | attribute | LengthValue |  |
| ISQAtomicNuclear::directionAndEnergyDistributionOfCrossSection | attribute | DirectionAndEnergyDistributionOfCrossSectionValue |  |
| ISQAtomicNuclear::directionDistributionOfCrossSection | attribute | DirectionDistributionOfCrossSectionValue |  |
| ISQAtomicNuclear::disintegrationConstant | alias |  |  |
| ISQSpaceTime::displacement3dVector | attribute | Displacement3dVector |  |
| ISQElectromagnetism::displacementCurrent | attribute | ElectricCurrentValue |  |
| ISQElectromagnetism::displacementCurrentDensity | attribute | DisplacementCurrentDensityValue |  |
| ISQChemistryMolecular::dissociationFraction | alias |  |  |
| ISQSpaceTime::distance | attribute | LengthValue |  |
| ISQCondensedMatter::donorDensity | attribute | DonorDensityValue |  |
| ISQAtomicNuclear::doseEquivalent | attribute | DoseEquivalentValue |  |
| ISQAtomicNuclear::doseEquivalentRate | attribute | DoseEquivalentValue |  |
| ISQMechanics::dragCoefficient | attribute | DragCoefficientValue |  |
| ISQMechanics::dragFactor | alias |  |  |
| ISQCharacteristicNumbers::dulongNumber | alias |  |  |
| ISQBase::duration | attribute | DurationValue |  |
| ISQCharacteristicNumbers::dynamicCapillaryNumber | attribute | DynamicCapillaryNumberValue |  |
| ISQMechanics::dynamicFrictionFactor | alias |  |  |
| ISQMechanics::dynamicViscosity | attribute | DynamicViscosityValue |  |
| SI::electronvolt | attribute | EnergyUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::electronvolt |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| isExact | attribute | Boolean | unitConversion |
| SI::'electronvolt per metre' | attribute | TotalLinearStoppingPowerUnit |  |
| SI::'electronvolt per square metre' | attribute | EnergyFluenceUnit |  |
| SI::'electronvolt joule kilogram metre squared second to the power minus 2' | attribute | HartreeEnergyUnit |  |
| SI::'electronvolt metre to the power minus 2 per kilogram' | attribute | TotalMassStoppingPowerUnit |  |
| ISQCharacteristicNumbers::eckertNumber | attribute | EckertNumberValue |  |
| ISQCondensedMatter::effectiveMass | attribute | MassValue |  |
| ISQCharacteristicNumbers::ekmanNumber | attribute | EkmanNumberValue |  |
| ISQCharacteristicNumbers::elasticityNumber | attribute | ElasticityNumberValue |  |
| ISQElectromagnetism::electricCharge | attribute | ElectricChargeValue |  |
| ISQElectromagnetism::electricChargeDensity | attribute | ElectricChargeDensityValue |  |
| ISQElectromagnetism::electricConstant | attribute | ElectricConstantValue |  |
| ISQBase::electricCurrent | attribute | ElectricCurrentValue |  |
| ISQElectromagnetism::electricCurrentDensity | attribute | ElectricCurrentDensityValue |  |
| ISQElectromagnetism::electricCurrentPhasor | attribute | ElectricCurrentValue |  |
| ISQElectromagnetism::electricDipoleMoment | attribute | ElectricDipoleMomentValue |  |
| ISQCharacteristicNumbers::electricFieldParameter | attribute | ElectricFieldParameterValue |  |
| ISQElectromagnetism::electricFieldStrength | attribute | ElectricFieldStrengthValue |  |
| ISQElectromagnetism::electricFlux | attribute | ElectricFluxValue |  |
| ISQElectromagnetism::electricFluxDensity | attribute | ElectricFluxDensityValue |  |
| ISQElectromagnetism::electricPolarization | attribute | ElectricPolarizationValue |  |
| ISQElectromagnetism::electricPotential | attribute | ElectricPotentialValue |  |
| ISQElectromagnetism::electricPotentialDifference | attribute | ElectricPotentialDifferenceValue |  |
| ISQElectromagnetism::electricPower | attribute | PowerValue |  |
| ISQElectromagnetism::electricSusceptibility | attribute | ElectricSusceptibilityValue |  |
| ISQElectromagnetism::electricTension | alias |  |  |
| ISQChemistryMolecular::electrolyticConductivity | attribute | ElectrolyticConductivityValue |  |
| ISQElectromagnetism::electromagneticEnergyDensity | attribute | ElectromagneticEnergyDensityValue |  |
| ISQCondensedMatter::electronAffinity | attribute | EnergyValue |  |
| ISQCondensedMatter::electronDensity | attribute | ElectronDensityValue |  |
| ISQAtomicNuclear::electronRadius | attribute | LengthValue |  |
| ISQAtomicNuclear::elementaryCharge | attribute | ElectricChargeValue |  |
| ISQLight::emissivity | attribute | EmissivityValue |  |
| ISQLight::emissivityAtASpecifiedWavelength | attribute | EmissivityAtASpecifiedWavelengthValue |  |
| ISQThermodynamics::energy | attribute | EnergyValue |  |
| ISQCondensedMatter::energyDensityOfStates | attribute | EnergyDensityOfStatesValue |  |
| ISQAtomicNuclear::energyDistributionOfCrossSection | attribute | EnergyDistributionOfCrossSectionValue |  |
| ISQAtomicNuclear::energyFluence | attribute | EnergyFluenceValue |  |
| ISQAtomicNuclear::energyFluenceRate | attribute | EnergyFluenceRateValue |  |
| ISQAtomicNuclear::energyImparted | attribute | EnergyValue |  |
| ISQThermodynamics::enthalpy | attribute | EnergyValue |  |
| ISQChemistryMolecular::enthalpyOfPhaseTransition | alias |  |  |
| ISQThermodynamics::entropy | attribute | EntropyValue |  |
| ISQInformation::entropyForInformationScience | attribute | EntropyForInformationScienceValue |  |
| ISQChemistryMolecular::equilibriumConstantOnConcentrationBasis | attribute | EquilibriumConstantOnConcentrationBasisValue |  |
| ISQChemistryMolecular::equilibriumConstantOnPressureBasis | attribute | EquilibriumConstantOnPressureBasisValue |  |
| ISQInformation::equivalentBinaryDigitRate | attribute | EquivalentBinaryDigitRateValue |  |
| ISQInformation::equivalentBinaryStorageCapacity | attribute | EquivalentBinaryStorageCapacityValue |  |
| ISQInformation::equivalentBitRate | alias |  |  |
| ISQInformation::equivocation | attribute | EquivocationValue |  |
| ISQInformation::errorProbability | attribute | ErrorProbabilityValue |  |
| ISQCharacteristicNumbers::eulerMagneticNumber | alias |  |  |
| ISQCharacteristicNumbers::eulerNumber | attribute | EulerNumberValue |  |
| SIPrefixes::exa | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::exa |
| symbol | attribute | String | SIPrefixes::exa |
| conversionFactor | attribute | Real | SIPrefixes::exa |
| SIPrefixes::exbi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::exbi |
| symbol | attribute | String | SIPrefixes::exbi |
| conversionFactor | attribute | Real | SIPrefixes::exbi |
| ISQCondensedMatter::exchangeIntegral | attribute | EnergyValue |  |
| ISQCharacteristicNumbers::expansionNumber | attribute | ExpansionNumberValue |  |
| ISQAtomicNuclear::exposure | attribute | ExposureValue |  |
| ISQAtomicNuclear::exposureRate | attribute | ExposureRateValue |  |
| ISQChemistryMolecular::extentOfReaction | attribute | AmountOfSubstanceValue |  |
| ISQSpaceTime::extinction | alias |  |  |
| ISQCharacteristicNumbers::'eötvösNumber' | alias |  |  |
| ISQCharacteristicNumbers::fanningNumber | attribute | FanningNumberValue |  |
| ISQAtomicNuclear::fastFissionFactor | attribute | FastFissionFactorValue |  |
| SIPrefixes::femto | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::femto |
| symbol | attribute | String | SIPrefixes::femto |
| conversionFactor | attribute | Real | SIPrefixes::femto |
| ISQCondensedMatter::fermiAngularRepetency | alias |  |  |
| ISQCondensedMatter::fermiAngularWavenumber | attribute | RepetencyValue |  |
| ISQCondensedMatter::fermiEnergy | attribute | EnergyValue |  |
| ISQCondensedMatter::fermiTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQMechanics::force | attribute | ForceValue |  |
| ISQCharacteristicNumbers::fourierNumber | attribute | FourierNumberValue |  |
| ISQCharacteristicNumbers::fourierNumberForMassTransfer | attribute | FourierNumberForMassTransferValue |  |
| ISQSpaceTime::frequency | attribute | FrequencyValue |  |
| ISQCharacteristicNumbers::froudeNumber | attribute | FroudeNumberValue |  |
| ISQCharacteristicNumbers::froudeNumberForHeatTransfer | attribute | FroudeNumberForHeatTransferValue |  |
| ISQChemistryMolecular::fugacity | attribute | FugacityValue |  |
| ISQCondensedMatter::fundamentalReciprocalLatticeVectorMagnitude | attribute | FundamentalReciprocalLatticeVectorMagnitudeValue |  |
| SI::gram | attribute | MassUnit |  |
| SI::'g per l' | attribute | MassConcentrationUnit |  |
| SI::'g per mole' | attribute | MolarMassUnit |  |
| ISQAtomicNuclear::gFactorOfAtom | alias |  |  |
| ISQAtomicNuclear::gFactorOfNucleusOrNuclearParticle | attribute | GFactorOfNucleusOrNuclearParticleValue |  |
| ISQCharacteristicNumbers::galileiNumber | attribute | GalileiNumberValue |  |
| ISQCondensedMatter::gapEnergy | attribute | EnergyValue |  |
| ISQMechanics::gaugePressure | attribute | PressureValue |  |
| ISQThermodynamics::gibbsEnergy | attribute | EnergyValue |  |
| ISQThermodynamics::gibbsFunction | alias |  |  |
| SIPrefixes::gibi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::gibi |
| symbol | attribute | String | SIPrefixes::gibi |
| conversionFactor | attribute | Real | SIPrefixes::gibi |
| SIPrefixes::giga | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::giga |
| symbol | attribute | String | SIPrefixes::giga |
| conversionFactor | attribute | Real | SIPrefixes::giga |
| ISQCharacteristicNumbers::goertlerNumber | attribute | GoertlerNumberValue |  |
| ISQCharacteristicNumbers::goertlerParameter | alias |  |  |
| ISQCharacteristicNumbers::graetzNumber | attribute | GraetzNumberValue |  |
| ISQCharacteristicNumbers::graetzNumberForMassTransfer | attribute | GraetzNumberForMassTransferValue |  |
| ISQChemistryMolecular::grandCanonicalPartitionFunction | attribute | GrandCanonicalPartitionFunctionValue |  |
| ISQChemistryMolecular::grandPartitionFunction | alias |  |  |
| ISQCharacteristicNumbers::grashofMagneticNumber | attribute | GrashofMagneticNumberValue |  |
| ISQCharacteristicNumbers::grashofNumber | attribute | GrashofNumberValue |  |
| ISQCharacteristicNumbers::grashofNumberForMassTransfer | attribute | GrashofNumberForMassTransferValue |  |
| ISQSpaceTime::groupSpeed | alias |  |  |
| ISQSpaceTime::groupVelocity | attribute | SpeedValue |  |
| ISQCondensedMatter::'grüneisenParameter' | attribute | 'GrüneisenParameterValue' |  |
| ISQAtomicNuclear::gyromagneticCoefficient | alias |  |  |
| ISQAtomicNuclear::gyromagneticCoefficientOfTheElectron | alias |  |  |
| ISQAtomicNuclear::gyromagneticRatio | attribute | GyromagneticRatioValue |  |
| ISQAtomicNuclear::gyromagneticRatioOfTheElectron | attribute | GyromagneticRatioOfTheElectronValue |  |
| ISQAtomicNuclear::gyroradius | attribute | LengthValue |  |
| SI::hour | attribute | DurationUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::hour |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| ISQCharacteristicNumbers::hagenNumber | attribute | HagenNumberValue |  |
| ISQAtomicNuclear::halfLife | attribute | DurationValue |  |
| ISQAtomicNuclear::halfValueThickness | attribute | LengthValue |  |
| ISQCondensedMatter::hallCoefficient | attribute | HallCoefficientValue |  |
| ISQCharacteristicNumbers::hallNumber | attribute | HallNumberValue |  |
| ISQInformation::hammingDistance | attribute | CountValue |  |
| ISQCharacteristicNumbers::hartmannNumber | attribute | HartmannNumberValue |  |
| ISQAtomicNuclear::hartreeEnergy | attribute | HartreeEnergyValue |  |
| ISQThermodynamics::heat | attribute | EnergyValue |  |
| ISQThermodynamics::heatCapacity | attribute | HeatCapacityValue |  |
| ISQThermodynamics::heatFlowRate | attribute | HeatFlowRateValue |  |
| ISQCharacteristicNumbers::heatTransferFactor | alias |  |  |
| ISQCharacteristicNumbers::heatTransferNumber | attribute | HeatTransferNumberValue |  |
| SIPrefixes::hecto | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::hecto |
| symbol | attribute | String | SIPrefixes::hecto |
| conversionFactor | attribute | Real | SIPrefixes::hecto |
| ISQCharacteristicNumbers::'hedströmNumber' | attribute | 'HedströmNumberValue' |  |
| ISQSpaceTime::height | attribute | LengthValue |  |
| ISQThermodynamics::helmholtzEnergy | attribute | EnergyValue |  |
| ISQThermodynamics::helmholtzFunction | alias |  |  |
| ISQCondensedMatter::holeDensity | attribute | HoleDensityValue |  |
| ISQCharacteristicNumbers::hookeNumber | attribute | HookeNumberValue |  |
| ISQAtomicNuclear::hyperfineStructureQuantumNumber | attribute | CountValue |  |
| ISQLight::illuminance | attribute | IlluminanceValue |  |
| ISQElectromagnetism::impedance | attribute | ImpedanceValue |  |
| ISQMechanics::impulse | attribute | ImpulseValue |  |
| ISQElectromagnetism::inductance | attribute | InductanceValue |  |
| ISQAtomicNuclear::infiniteMultiplicationFactor | attribute | InfiniteMultiplicationFactorValue |  |
| ISQInformation::informationContent | attribute | InformationContentValue |  |
| ISQElectromagnetism::instantaneousPower | alias |  |  |
| ISQAtomicNuclear::internalConversionFactor | attribute | InternalConversionFactorValue |  |
| ISQThermodynamics::internalEnergy | attribute | EnergyValue |  |
| ISQCondensedMatter::intrinsicCarrierDensity | attribute | IntrinsicCarrierDensityValue |  |
| ISQAtomicNuclear::ionDensity | alias |  |  |
| ISQAtomicNuclear::ionNumberDensity | attribute | IonNumberDensityValue |  |
| ISQChemistryMolecular::ionicStrength | attribute | IonicStrengthValue |  |
| ISQCondensedMatter::ionizationEnergy | attribute | EnergyValue |  |
| ISQAtomicNuclear::ionizationNumber | alias |  |  |
| ISQLight::irradiance | attribute | IrradianceValue |  |
| ISQInformation::irrelevance | attribute | IrrelevanceValue |  |
| ISQThermodynamics::isentropicCompressibility | attribute | IsentropicCompressibilityValue |  |
| ISQThermodynamics::isentropicExpansionFactor | alias |  |  |
| ISQThermodynamics::isentropicExponent | attribute | IsentropicExponentValue |  |
| ISQThermodynamics::isothermalCompressibility | attribute | IsothermalCompressibilityValue |  |
| ISQCharacteristicNumbers::jFactor | attribute | JFactorValue |  |
| ISQInformation::jointInformationContent | attribute | JointInformationContentValue |  |
| ISQCharacteristicNumbers::jouleMagneticNumber | attribute | JouleMagneticNumberValue |  |
| ISQThermodynamics::jouleThomsonCoefficient | attribute | JouleThomsonCoefficientValue |  |
| SI::kilojoule | attribute | EnergyUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::kilojoule |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| SI::kilowatt | attribute | PowerUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::kilowatt |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| ISQAtomicNuclear::kerma | attribute | KermaValue |  |
| ISQAtomicNuclear::kermaRate | attribute | KermaRateValue |  |
| SI::kilogram | attribute | MassUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::kilogram |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| SI::'kilogram to the power 2 metre to the power 4 second to the power minus 6 ampere to the power minus 2 kelvin to the power minus 2' | attribute | LorenzCoefficientUnit |  |
| SI::'kilogram to the power 2 metre to the power minus 2 second to the power minus 3' | attribute | SoundExposureUnit |  |
| SI::'kilogram to the power minus 1 ampere' | attribute | ExposureRateUnit |  |
| SI::'kilogram to the power minus 1 metre squared' | attribute | MassAttenuationCoefficientUnit |  |
| SI::'kilogram to the power minus 1 metre cubed' | attribute | SpecificVolumeUnit |  |
| SI::'kilogram to the power minus 1 metre to the power minus 2 second to the power 3 kelvin' | attribute | ThermalResistanceUnit |  |
| SI::'kilogram to the power minus 1 metre to the power minus 3 second to the power 3 ampere to the power 2' | attribute | ElectrolyticConductivityUnit |  |
| SI::'kilogram to the power minus 1 metre to the power minus 5 second to the power 2' | attribute | EnergyDensityOfStatesUnit |  |
| SI::'kilogram to the power minus 1 metre second to the power 2' | attribute | CompressibilityUnit |  |
| SI::'kilogram to the power minus 1 metre second to the power 2 kelvin' | attribute | JouleThomsonCoefficientUnit |  |
| SI::'kilogram to the power minus 1 second to the power 2' | attribute | EnergyDistributionOfCrossSectionUnit |  |
| SI::'kilogram to the power minus 1 second to the power 2 ampere' | attribute | MobilityUnit |  |
| SI::'kilogram to the power minus 1 second to the power 3 ampere to the power 2 mole to the power minus 1' | attribute | MolarConductivityUnit |  |
| SI::'kilogram to the power minus 1 second to the power 3 kelvin' | attribute | ThermalInsulanceUnit |  |
| SI::'kilogram to the power minus 1 second to the power minus 1' | attribute | SpecificActivityUnit |  |
| SI::'kilogram to the power minus 1 second ampere' | attribute | GyromagneticRatioUnit |  |
| SI::'kilogram mole to the power minus 1' | attribute | MolarMassUnit |  |
| SI::'kilogram metre squared' | attribute | MomentOfInertiaUnit |  |
| SI::'kilogram metre squared second to the power minus 2' | attribute | MomentOfForceUnit |  |
| SI::'kilogram metre squared second to the power minus 2 kelvin to the power minus 1' | attribute | HeatCapacityUnit |  |
| SI::'kilogram metre squared second to the power minus 2 kelvin to the power minus 1 mole to the power minus 1' | attribute | MolarHeatCapacityUnit |  |
| SI::'kilogram metre squared second to the power minus 2 mole to the power minus 1' | attribute | MolarInternalEnergyUnit |  |
| SI::'kilogram metre squared second to the power minus 3' | attribute | PowerUnit |  |
| SI::'kilogram metre squared second to the power minus 3 ampere to the power minus 1' | attribute | ElectricPotentialDifferenceUnit |  |
| SI::'kilogram metre squared second to the power minus 3 ampere to the power minus 1 kelvin to the power minus 1' | attribute | SeebeckCoefficientForSubstancesAAndBUnit |  |
| SI::'kilogram metre squared second to the power minus 3 kelvin to the power minus 1' | attribute | ThermalConductanceUnit |  |
| SI::'kilogram metre squared second to the power minus 3 steradian to the power minus 1' | attribute | RadiantIntensityUnit |  |
| SI::'kilogram metre squared second to the power minus 1' | attribute | AngularMomentumUnit |  |
| SI::'kilogram metre cubed second to the power minus 3 ampere to the power minus 2' | attribute | ResistivityUnit |  |
| SI::'kilogram metre to the power minus 2' | attribute | SurfaceMassDensityUnit |  |
| SI::'kilogram metre to the power minus 2 second to the power minus 2' | attribute | SpectralRadiantEnergyDensityInTermsOfWavelengthUnit |  |
| SI::'kilogram metre to the power minus 2 second to the power minus 1' | attribute | MassFlowUnit |  |
| SI::'kilogram metre to the power minus 3' | attribute | MassDensityUnit |  |
| SI::'kilogram metre to the power minus 1' | attribute | LinearMassDensityUnit |  |
| SI::'kilogram metre to the power minus 1 second to the power minus 2' | attribute | PressureUnit |  |
| SI::'kilogram metre to the power minus 1 second to the power minus 2 kelvin to the power minus 1' | attribute | PressureCoefficientUnit |  |
| SI::'kilogram metre to the power minus 1 second to the power minus 3' | attribute | SpectralIrradianceUnit |  |
| SI::'kilogram metre to the power minus 1 second to the power minus 3 steradian to the power minus 1' | attribute | SpectralRadianceUnit |  |
| SI::'kilogram metre to the power minus 1 second to the power minus 1' | attribute | DynamicViscosityUnit |  |
| SI::'kilogram metre to the power minus 4 second to the power minus 1' | attribute | AcousticImpedanceUnit |  |
| SI::'kilogram metre second to the power minus 2' | attribute | ForceUnit |  |
| SI::'kilogram metre second to the power minus 3' | attribute | SpectralRadiantFluxUnit |  |
| SI::'kilogram metre second to the power minus 3 kelvin to the power minus 1' | attribute | ThermalConductivityUnit |  |
| SI::'kilogram metre second to the power minus 3 steradian to the power minus 1' | attribute | SpectralRadiantIntensityUnit |  |
| SI::'kilogram metre second to the power minus 1' | attribute | MomentumUnit |  |
| SI::'kilogram second to the power minus 2' | attribute | SurfaceTensionUnit |  |
| SI::'kilogram second to the power minus 2 ampere to the power minus 1' | attribute | MagneticFluxDensityUnit |  |
| SI::'kilogram second to the power minus 3' | attribute | DensityOfHeatFlowRateUnit |  |
| SI::'kilogram second to the power minus 3 kelvin to the power minus 1' | attribute | CoefficientOfHeatTransferUnit |  |
| SI::'kilogram second to the power minus 3 steradian to the power minus 1' | attribute | RadianceUnit |  |
| SI::'kilogram second to the power minus 1' | attribute | MassFlowRateUnit |  |
| SIPrefixes::kibi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::kibi |
| symbol | attribute | String | SIPrefixes::kibi |
| conversionFactor | attribute | Real | SIPrefixes::kibi |
| ISQCharacteristicNumbers::kiebelNumber | alias |  |  |
| SIPrefixes::kilo | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::kilo |
| symbol | attribute | String | SIPrefixes::kilo |
| conversionFactor | attribute | Real | SIPrefixes::kilo |
| SI::kilometre | attribute | LengthUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::kilometre |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| SI::'kilometre per hour' | attribute | SpeedUnit |  |
| ISQMechanics::kinematicViscosity | attribute | KinematicViscosityValue |  |
| ISQMechanics::kineticEnergy | attribute | EnergyValue |  |
| ISQMechanics::kineticFrictionFactor | attribute | KineticFrictionFactorValue |  |
| ISQCharacteristicNumbers::knudsenNumber | attribute | KnudsenNumberValue |  |
| ISQCharacteristicNumbers::'kármanNumber' | alias |  |  |
| ISQCharacteristicNumbers::lagrangeNumber | attribute | LagrangeNumberValue |  |
| ISQCharacteristicNumbers::landauGinzburgNumber | attribute | LandauGinzburgNumberValue |  |
| ISQAtomicNuclear::landeFactor | attribute | LandeFactorValue |  |
| ISQCharacteristicNumbers::laplaceNumber | attribute | LaplaceNumberValue |  |
| ISQAtomicNuclear::larmorAngularFrequency | attribute | AngularFrequencyValue |  |
| ISQAtomicNuclear::larmorFrequency | attribute | LarmorFrequencyValue |  |
| ISQAtomicNuclear::larmorRadius | alias |  |  |
| ISQThermodynamics::latentHeat | attribute | EnergyValue |  |
| ISQChemistryMolecular::latentHeatOfPhaseTransition | attribute | EnergyValue |  |
| ISQCondensedMatter::latticePlaneSpacing | attribute | LengthValue |  |
| ISQCharacteristicNumbers::lavalNumber | attribute | LavalNumberValue |  |
| ISQElectromagnetism::leakageFactor | attribute | LeakageFactorValue |  |
| ISQBase::length | attribute | LengthValue |  |
| ISQAtomicNuclear::lethargy | attribute | LethargyValue |  |
| ISQAtomicNuclear::levelWidth | attribute | EnergyValue |  |
| ISQCharacteristicNumbers::lewisNumber | attribute | LewisNumberValue |  |
| ISQCharacteristicNumbers::liftCoefficient | attribute | LiftCoefficientValue |  |
| ISQLight::lightExposure | alias |  |  |
| ISQElectromagnetism::lightSpeed | alias |  |  |
| ISQInformation::lineDigitRate | alias |  |  |
| ISQLight::linearAbsorptionCoefficient | attribute | LinearAbsorptionCoefficientValue |  |
| ISQLight::linearAttenuationCoefficient | attribute | LinearAttenuationCoefficientValue |  |
| ISQAtomicNuclear::linearAttenuationCoefficientForIonizingRadiation | attribute | LinearAttenuationCoefficientForIonizingRadiationValue |  |
| ISQMechanics::linearDensity | alias |  |  |
| ISQElectromagnetism::linearDensityOfElectricCharge | attribute | LinearDensityOfElectricChargeValue |  |
| ISQElectromagnetism::linearElectricCurrentDensity | attribute | LinearElectricCurrentDensityValue |  |
| ISQAtomicNuclear::linearEnergyTransfer | attribute | LinearEnergyTransferValue |  |
| ISQThermodynamics::linearExpansionCoefficient | attribute | LinearExpansionCoefficientValue |  |
| ISQLight::linearExtinctionCoefficient | alias |  |  |
| ISQAtomicNuclear::linearIonization | attribute | LinearIonizationValue |  |
| ISQMechanics::linearMassDensity | attribute | LinearMassDensityValue |  |
| ISQAtomicNuclear::linearStoppingPower | alias |  |  |
| ISQElectromagnetism::lineicElectricCharge | alias |  |  |
| ISQElectromagnetism::linkedFlux | attribute | LinkedFluxValue |  |
| SI::lumen | attribute | LuminousFluxUnit |  |
| SI::'lumen per watt' | attribute | LuminousEfficacyOfRadiationUnit |  |
| SI::'lumen per square metre' | attribute | LuminousExitanceUnit |  |
| SI::'lumen second' | attribute | LuminousEnergyUnit |  |
| ISQCharacteristicNumbers::lockhartMartinelliParameter | attribute | LockhartMartinelliParameterValue |  |
| ISQSpaceTime::logarithmicDecrement | attribute | LogarithmicDecrementValue |  |
| ISQAcoustics::logarithmicFrequencyRange | attribute | LogarithmicFrequencyRangeValue |  |
| ISQCondensedMatter::londonPenetrationDepth | attribute | LengthValue |  |
| ISQCondensedMatter::longRangeOrderParameter | attribute | LongRangeOrderParameterValue |  |
| ISQCharacteristicNumbers::lorentzNumber | attribute | LorentzNumberValue |  |
| ISQCondensedMatter::lorenzCoefficient | attribute | LorenzCoefficientValue |  |
| ISQElectromagnetism::lossAngle | attribute | AngularMeasureValue |  |
| ISQElectromagnetism::lossFactor | attribute | LossFactorValue |  |
| ISQInformation::lossProbability | attribute | LossProbabilityValue |  |
| ISQCondensedMatter::lowerCriticalMagneticFluxDensity | attribute | MagneticFluxDensityValue |  |
| ISQLight::luminance | attribute | LuminanceValue |  |
| ISQLight::luminanceFactor | attribute | LuminanceFactorValue |  |
| ISQLight::luminousAbsorptance | attribute | LuminousAbsorptanceValue |  |
| ISQLight::luminousEfficacyOfASource | attribute | LuminousEfficacyOfASourceValue |  |
| ISQLight::luminousEfficacyOfRadiation | attribute | LuminousEfficacyOfRadiationValue |  |
| ISQLight::luminousEfficiency | attribute | LuminousEfficiencyValue |  |
| ISQLight::luminousEnergy | attribute | LuminousEnergyValue |  |
| ISQLight::luminousExitance | attribute | LuminousExitanceValue |  |
| ISQLight::luminousExposure | attribute | LuminousExposureValue |  |
| ISQLight::luminousFlux | attribute | LuminousFluxValue |  |
| ISQBase::luminousIntensity | attribute | LuminousIntensityValue |  |
| ISQLight::luminousReflectance | attribute | LuminousReflectanceValue |  |
| ISQLight::luminousTransmittance | attribute | LuminousTransmittanceValue |  |
| ISQCharacteristicNumbers::lundquistNumber | attribute | LundquistNumberValue |  |
| SI::lux | attribute | IlluminanceUnit |  |
| SI::'lux second' | attribute | LuminousExposureUnit |  |
| SI::metre | attribute | LengthUnit |  |
| SI::'metre per second' | attribute | SpeedUnit |  |
| SI::'m/s²' | alias |  |  |
| SI::millilitre | attribute | VolumeUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::millilitre |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| SI::'ml per l' | attribute | VolumeFractionUnit |  |
| SI::millinewton | attribute | ForceUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::millinewton |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| ISQCharacteristicNumbers::machMagneticNumber | alias |  |  |
| ISQCharacteristicNumbers::machNumber | attribute | MachNumberValue |  |
| ISQAtomicNuclear::macroscopicCrossSection | alias |  |  |
| ISQAtomicNuclear::macroscopicTotalCrossSection | alias |  |  |
| ISQElectromagnetism::magneticConstant | attribute | MagneticConstantValue |  |
| ISQAtomicNuclear::magneticDipoleMoment | attribute | MagneticDipoleMomentValue |  |
| ISQElectromagnetism::magneticDipoleMoment | attribute | MagneticDipoleMomentValue |  |
| ISQElectromagnetism::magneticFieldStrength | attribute | MagneticFieldStrengthValue |  |
| ISQElectromagnetism::magneticFlux | attribute | MagneticFluxValue |  |
| ISQElectromagnetism::magneticFluxDensity | attribute | MagneticFluxDensityValue |  |
| ISQElectromagnetism::magneticMoment | attribute | MagneticMomentValue |  |
| ISQCharacteristicNumbers::magneticNumber | attribute | MagneticNumberValue |  |
| ISQElectromagnetism::magneticPolarization | attribute | MagneticPolarizationValue |  |
| ISQCharacteristicNumbers::magneticPressureNumber | attribute | MagneticPressureNumberValue |  |
| ISQAtomicNuclear::magneticQuantumNumber | attribute | CountValue |  |
| ISQElectromagnetism::magneticSusceptibility | attribute | MagneticSusceptibilityValue |  |
| ISQElectromagnetism::magneticTension | attribute | ElectricCurrentValue |  |
| ISQElectromagnetism::magneticVectorPotential | attribute | MagneticVectorPotentialValue |  |
| ISQElectromagnetism::magnetization | attribute | MagnetizationValue |  |
| ISQAtomicNuclear::magnetogyricRatio | alias |  |  |
| ISQAtomicNuclear::magnetogyricRatioOfTheElectron | alias |  |  |
| ISQElectromagnetism::magnetomotiveForce | attribute | MagnetomotiveForceValue |  |
| ISQCharacteristicNumbers::marangoniNumber | attribute | MarangoniNumberValue |  |
| ISQBase::mass | attribute | MassValue |  |
| ISQLight::massAbsorptionCoefficient | attribute | MassAbsorptionCoefficientValue |  |
| ISQLight::massAttenuationCoefficient | attribute | MassAttenuationCoefficientValue |  |
| ISQAtomicNuclear::massAttenuationCoefficientForIonizingRadiation | attribute | MassAttenuationCoefficientForIonizingRadiationValue |  |
| ISQMechanics::massChangeRate | attribute | MassChangeRateValue |  |
| ISQChemistryMolecular::massConcentration | attribute | MassConcentrationValue |  |
| ISQThermodynamics::massConcentrationOfWater | attribute | MassConcentrationOfWaterValue |  |
| ISQThermodynamics::massConcentrationOfWaterVapourAbsoluteHumidity | attribute | MassConcentrationOfWaterVapourAbsoluteHumidityValue |  |
| ISQAtomicNuclear::massDefect | attribute | MassValue |  |
| ISQMechanics::massDensity | attribute | MassDensityValue |  |
| ISQAtomicNuclear::massEnergyTransferCoefficient | attribute | MassEnergyTransferCoefficientValue |  |
| ISQAtomicNuclear::massExcess | attribute | MassValue |  |
| ISQMechanics::massFlow | attribute | MassFlowValue |  |
| ISQMechanics::massFlowRate | attribute | MassFlowRateValue |  |
| ISQChemistryMolecular::massFraction | attribute | MassFractionValue |  |
| ISQThermodynamics::massFractionOfDryMatter | attribute | MassFractionOfDryMatterValue |  |
| ISQThermodynamics::massFractionOfWater | attribute | MassFractionOfWaterValue |  |
| ISQAtomicNuclear::massNumber | alias |  |  |
| ISQThermodynamics::massRatioOfWaterToDryMatter | attribute | MassRatioOfWaterToDryMatterValue |  |
| ISQThermodynamics::massRatioOfWaterVapourToDryGas | attribute | MassRatioOfWaterVapourToDryGasValue |  |
| ISQAtomicNuclear::massStoppingPower | alias |  |  |
| ISQCharacteristicNumbers::massTransferFactor | attribute | MassTransferFactorValue |  |
| ISQAtomicNuclear::massicActivity | alias |  |  |
| ISQThermodynamics::massieuFunction | attribute | MassieuFunctionValue |  |
| ISQAtomicNuclear::maximumBetaParticleEnergy | attribute | EnergyValue |  |
| ISQInformation::maximumEntropy | attribute | MaximumEntropyValue |  |
| ISQLight::maximumLuminousEfficacy | attribute | MaximumLuminousEfficacyValue |  |
| ISQThermodynamics::maximumThermalEfficiency | attribute | MaximumThermalEfficiencyValue |  |
| ISQInformation::meanConditionalInformationContent | alias |  |  |
| ISQAtomicNuclear::meanDurationOfLife | attribute | DurationValue |  |
| ISQAtomicNuclear::meanEnergyImparted | attribute | EnergyValue |  |
| ISQChemistryMolecular::meanFreePath | attribute | LengthValue |  |
| ISQAtomicNuclear::meanFreePathForAtomicPhysics | attribute | LengthValue |  |
| ISQCondensedMatter::meanFreePathOfElectrons | attribute | LengthValue |  |
| ISQCondensedMatter::meanFreePathOfPhonons | attribute | LengthValue |  |
| ISQAtomicNuclear::meanLifeTime | alias |  |  |
| ISQAtomicNuclear::meanLinearRange | attribute | LengthValue |  |
| ISQAtomicNuclear::meanMassRange | attribute | MeanMassRangeValue |  |
| ISQInformation::meanQueueLength | attribute | MeanQueueLengthValue |  |
| ISQInformation::meanTransinformationContent | attribute | MeanTransinformationContentValue |  |
| SIPrefixes::mebi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::mebi |
| symbol | attribute | String | SIPrefixes::mebi |
| conversionFactor | attribute | Real | SIPrefixes::mebi |
| ISQMechanics::mechanicalEfficiency | attribute | MechanicalEfficiencyValue |  |
| ISQMechanics::mechanicalEnergy | attribute | EnergyValue |  |
| ISQMechanics::mechanicalPower | attribute | PowerValue |  |
| ISQMechanics::mechanicalWork | attribute | EnergyValue |  |
| SIPrefixes::mega | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::mega |
| symbol | attribute | String | SIPrefixes::mega |
| conversionFactor | attribute | Real | SIPrefixes::mega |
| SI::'metre cubed' | attribute | VolumeUnit |  |
| SI::'metre cubed mole to the power minus 1' | attribute | MolarVolumeUnit |  |
| SI::'metre cubed per coulomb cubic metre second to the power minus 1 ampere to the power minus 1' | attribute | HallCoefficientUnit |  |
| SI::'metre cubed second to the power minus 1' | attribute | VolumeFlowRateUnit |  |
| SI::'metre second to the power minus 1' | attribute | SpeedUnit |  |
| SI::'metre second to the power minus 2' | attribute | AccelerationUnit |  |
| SI::'metre squared' | attribute | AreaUnit |  |
| SI::'metre squared ampere' | attribute | ISQAtomicNuclear::MagneticDipoleMomentUnit |  |
| SI::'metre squared kelvin per watt' | attribute | ThermalInsulanceUnit |  |
| SI::'metre squared mole to the power minus 1' | attribute | MolarAbsorptionCoefficientUnit |  |
| SI::'metre squared per joule' | attribute | EnergyDistributionOfCrossSectionUnit |  |
| SI::'metre squared per joule steradian' | attribute | DirectionAndEnergyDistributionOfCrossSectionUnit |  |
| SI::'metre squared per volt second' | attribute | MobilityUnit |  |
| SI::'metre squared second to the power minus 1' | attribute | KinematicViscosityUnit |  |
| SI::'metre squared second to the power minus 2' | attribute | SpecificEnergyUnit |  |
| SI::'metre squared second to the power minus 2 kelvin to the power minus 1' | attribute | SpecificHeatCapacityUnit |  |
| SI::'metre squared second to the power minus 3' | attribute | DoseEquivalentUnit |  |
| SI::'metre squared steradian to the power minus 1' | attribute | DirectionDistributionOfCrossSectionUnit |  |
| SI::'metre to the power 4' | attribute | SecondAxialMomentOfAreaUnit |  |
| SI::'metre to the power 4 second to the power minus 2' | attribute | TotalMassStoppingPowerUnit |  |
| SI::'metre to the power minus 1' | attribute | CurvatureUnit |  |
| SI::'metre to the power minus 2' | attribute | PhotonExposureUnit |  |
| SI::'metre to the power minus 2 second to the power minus 1' | attribute | PhotonIrradianceUnit |  |
| SI::'metre to the power minus 2 second to the power minus 1 steradian to the power minus 1' | attribute | PhotonRadianceUnit |  |
| SI::'metre to the power minus 3' | attribute | ParticleConcentrationUnit |  |
| SI::'metre to the power minus 3 second' | attribute | DensityOfVibrationalStatesUnit |  |
| SI::'metre to the power minus 3 second to the power minus 1' | attribute | ActivityDensityUnit |  |
| SI::'metric ton' | alias |  |  |
| SIPrefixes::micro | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::micro |
| symbol | attribute | String | SIPrefixes::micro |
| conversionFactor | attribute | Real | SIPrefixes::micro |
| ISQChemistryMolecular::microcanonicalPartitionFunction | attribute | CountValue |  |
| ISQAtomicNuclear::migrationArea | attribute | AreaValue |  |
| ISQAtomicNuclear::migrationLength | attribute | LengthValue |  |
| SIPrefixes::milli | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::milli |
| symbol | attribute | String | SIPrefixes::milli |
| conversionFactor | attribute | Real | SIPrefixes::milli |
| SI::millimetre | attribute | LengthUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::millimetre |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| SI::minute | attribute | DurationUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::minute |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| SI::'minute (angle)' | attribute | AngularMeasureUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::'minute (angle)' |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| isExact | attribute | Boolean | unitConversion |
| ISQAtomicNuclear::mobility | attribute | MobilityValue |  |
| ISQCondensedMatter::mobilityRatio | attribute | MobilityRatioValue |  |
| ISQInformation::modulationRate | attribute | ModulationRateValue |  |
| ISQElectromagnetism::modulusOfAdmittance | attribute | ModulusOfAdmittanceValue |  |
| ISQMechanics::modulusOfCompression | attribute | ModulusOfCompressionValue |  |
| ISQMechanics::modulusOfElasticity | attribute | ModulusOfElasticityValue |  |
| ISQElectromagnetism::modulusOfImpedance | attribute | ModulusOfImpedanceValue |  |
| ISQMechanics::modulusOfRigidity | attribute | ModulusOfRigidityValue |  |
| SI::mole | attribute | AmountOfSubstanceUnit |  |
| SI::'mole per l' | attribute | AmountOfSubstanceConcentrationUnit |  |
| SI::'mole per kilogram' | attribute | MolalityUnit |  |
| SI::'mole per cubic metre' | attribute | EquilibriumConstantOnConcentrationBasisUnit |  |
| ISQChemistryMolecular::molality | attribute | MolalityValue |  |
| ISQLight::molarAbsorptionCoefficient | attribute | MolarAbsorptionCoefficientValue |  |
| ISQAtomicNuclear::molarAttenuationCoefficient | attribute | MolarAttenuationCoefficientValue |  |
| ISQChemistryMolecular::molarConductivity | attribute | MolarConductivityValue |  |
| ISQChemistryMolecular::molarEnthalpy | attribute | MolarEnthalpyValue |  |
| ISQChemistryMolecular::molarEntropy | attribute | MolarEntropyValue |  |
| ISQChemistryMolecular::molarGasConstant | attribute | MolarGasConstantValue |  |
| ISQChemistryMolecular::molarGibbsEnergy | attribute | MolarGibbsEnergyValue |  |
| ISQChemistryMolecular::molarHeatCapacity | attribute | MolarHeatCapacityValue |  |
| ISQChemistryMolecular::molarHelmholtzEnergy | attribute | MolarHelmholtzEnergyValue |  |
| ISQChemistryMolecular::molarInternalEnergy | attribute | MolarInternalEnergyValue |  |
| ISQChemistryMolecular::molarMass | attribute | MolarMassValue |  |
| ISQChemistryMolecular::molarOpticalRotatoryPower | attribute | MolarOpticalRotatoryPowerValue |  |
| ISQChemistryMolecular::molarVolume | attribute | MolarVolumeValue |  |
| SI::'mole kilogram to the power minus 1' | attribute | IonicStrengthUnit |  |
| SI::'mole metre to the power minus 3' | attribute | AmountOfSubstanceConcentrationUnit |  |
| ISQChemistryMolecular::molecularConcentration | attribute | ParticleConcentrationValue |  |
| ISQChemistryMolecular::molecularPartitionFunction | attribute | MolecularPartitionFunctionValue |  |
| ISQMechanics::momentOfForce | attribute | MomentOfForceValue |  |
| ISQMechanics::momentOfInertia | attribute | MomentOfInertiaValue |  |
| ISQMechanics::momentOfInertiaTensor | attribute | Cartesian3dMomentOfInertiaTensor |  |
| ISQMechanics::momentum | attribute | MomentumValue |  |
| ISQCharacteristicNumbers::moodyFrictionFactor | alias |  |  |
| ISQCharacteristicNumbers::mortonNumber | attribute | MortonNumberValue |  |
| ISQAtomicNuclear::multiplicationFactor | attribute | MultiplicationFactorValue |  |
| ISQChemistryMolecular::'multiplicity' | alias |  |  |
| ISQElectromagnetism::mutualInductance | attribute | InductanceValue |  |
| SIPrefixes::nano | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::nano |
| symbol | attribute | String | SIPrefixes::nano |
| conversionFactor | attribute | Real | SIPrefixes::nano |
| SI::nanometre | attribute | LengthUnit |  |
| unitConversion | attribute | ConversionByPrefix | SI::nanometre |
| prefix | attribute | UnitPrefix | unitConversion |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| ISQLight::napierianAbsorbance | attribute | NapierianAbsorbanceValue |  |
| SI::'natural unit of information' | attribute | InformationContentUnit |  |
| SI::'natural unit of information per second' | attribute | AverageInformationRateUnit |  |
| ISQCharacteristicNumbers::nazeNumber | attribute | NazeNumberValue |  |
| ISQAtomicNuclear::neutronNumber | attribute | CountValue |  |
| ISQAtomicNuclear::neutronYieldPerAbsorption | attribute | CountValue |  |
| ISQAtomicNuclear::neutronYieldPerFission | attribute | CountValue |  |
| ISQElectromagnetism::nonActivePower | attribute | PowerValue |  |
| ISQAtomicNuclear::nonLeakageProbability | attribute | NonLeakageProbabilityValue |  |
| ISQMechanics::normalStress | attribute | NormalStressValue |  |
| ISQAtomicNuclear::nuclearActivity | attribute | NuclearActivityValue |  |
| ISQAtomicNuclear::nuclearMagneton | attribute | MagneticDipoleMomentValue |  |
| ISQAtomicNuclear::nuclearPrecessionAngularFrequency | attribute | AngularFrequencyValue |  |
| ISQAtomicNuclear::nuclearQuadrupoleMoment | attribute | NuclearQuadrupoleMomentValue |  |
| ISQAtomicNuclear::nuclearRadius | attribute | LengthValue |  |
| ISQAtomicNuclear::nuclearSpinQuantumNumber | attribute | CountValue |  |
| ISQAtomicNuclear::nucleonNumber | attribute | CountValue |  |
| ISQAtomicNuclear::nuclidicMass | attribute | MassValue |  |
| ISQChemistryMolecular::numberOfEntities | attribute | CountValue |  |
| ISQChemistryMolecular::numberOfMoles | alias |  |  |
| ISQLight::numberOfPhotons | alias |  |  |
| ISQElectromagnetism::numberOfTurnsInAWinding | attribute | CountValue |  |
| ISQCharacteristicNumbers::nusseltElectricNumber | attribute | NusseltElectricNumberValue |  |
| ISQCharacteristicNumbers::nusseltNumber | attribute | NusseltNumberValue |  |
| ISQCharacteristicNumbers::nusseltNumberForMassTransfer | attribute | NusseltNumberForMassTransferValue |  |
| ISQCondensedMatter::'néelTemperature' | attribute | ThermodynamicTemperatureValue |  |
| SI::octet | attribute | StorageCapacityUnit |  |
| SI::'octet per second' | attribute | TransferRateUnit |  |
| SI::octave | attribute | LogarithmicFrequencyRangeUnit |  |
| SI::ohm | attribute | ResistanceUnit |  |
| SI::'ohm metre' | attribute | ResistivityUnit |  |
| ISQCharacteristicNumbers::ohnesorgeNumber | attribute | OhnesorgeNumberValue |  |
| ISQLight::opticalDensity | alias |  |  |
| ISQAtomicNuclear::orbitalAngularMomentumQuantumNumber | attribute | CountValue |  |
| ISQChemistryMolecular::osmoticCoefficientOfSolventA | alias |  |  |
| ISQChemistryMolecular::osmoticFactorOfSolvent | attribute | OsmoticFactorOfSolventValue |  |
| ISQChemistryMolecular::osmoticPressure | attribute | OsmoticPressureValue |  |
| ISQAtomicNuclear::packingFraction | attribute | PackingFractionValue |  |
| ISQChemistryMolecular::partialPressure | attribute | PartialPressureValue |  |
| ISQChemistryMolecular::particleConcentration | attribute | ParticleConcentrationValue |  |
| ISQAtomicNuclear::particleCurrentDensity | attribute | ParticleCurrentDensityValue |  |
| ISQAtomicNuclear::particleEmissionRate | attribute | ParticleEmissionRateValue |  |
| ISQAtomicNuclear::particleFluence | attribute | ParticleFluenceValue |  |
| ISQAtomicNuclear::particleFluenceRate | attribute | ParticleFluenceRateValue |  |
| ISQAtomicNuclear::particleNumberDensity | attribute | ParticleNumberDensityValue |  |
| ISQAtomicNuclear::particleSourceDensity | attribute | ParticleSourceDensityValue |  |
| ISQChemistryMolecular::partitionFunctionOfAMolecule | alias |  |  |
| ISQSpaceTime::pathLength | attribute | LengthValue |  |
| SIPrefixes::pebi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::pebi |
| symbol | attribute | String | SIPrefixes::pebi |
| conversionFactor | attribute | Real | SIPrefixes::pebi |
| ISQCondensedMatter::peltierCoefficientForSubstancesAAndB | attribute | ElectricPotentialDifferenceValue |  |
| ISQSpaceTime::period | alias |  |  |
| ISQSpaceTime::periodDuration | attribute | DurationValue |  |
| ISQInformation::periodOfBinaryDigits | attribute | DurationValue |  |
| ISQInformation::periodOfDataElements | attribute | DurationValue |  |
| ISQElectromagnetism::permeability | attribute | PermeabilityValue |  |
| ISQElectromagnetism::permeabilityOfVacuum | alias |  |  |
| ISQElectromagnetism::permeance | attribute | PermeanceValue |  |
| ISQElectromagnetism::permittivity | attribute | PermittivityValue |  |
| ISQElectromagnetism::permittivityOfVacuum | alias |  |  |
| SIPrefixes::peta | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::peta |
| symbol | attribute | String | SIPrefixes::peta |
| conversionFactor | attribute | Real | SIPrefixes::peta |
| ISQSpaceTime::phaseAngle | attribute | AngularMeasureValue |  |
| ISQSpaceTime::phaseCoefficient | attribute | PhaseCoefficientValue |  |
| ISQElectromagnetism::phaseDifference | attribute | PhaseDifferenceValue |  |
| ISQSpaceTime::phaseSpeed | alias |  |  |
| ISQElectromagnetism::phaseSpeedOfElectromagneticWaves | attribute | PhaseSpeedOfElectromagneticWavesValue |  |
| ISQSpaceTime::phaseVelocity | attribute | PhaseVelocityValue |  |
| ISQLight::photonEnergy | attribute | EnergyValue |  |
| ISQLight::photonExitance | attribute | PhotonExitanceValue |  |
| ISQLight::photonExposure | attribute | PhotonExposureValue |  |
| ISQLight::photonFlux | attribute | PhotonFluxValue |  |
| ISQLight::photonIntensity | attribute | PhotonIntensityValue |  |
| ISQLight::photonIrradiance | attribute | PhotonIrradianceValue |  |
| ISQLight::photonNumber | attribute | PhotonNumberValue |  |
| ISQLight::photonRadiance | attribute | PhotonRadianceValue |  |
| SIPrefixes::pico | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::pico |
| symbol | attribute | String | SIPrefixes::pico |
| conversionFactor | attribute | Real | SIPrefixes::pico |
| ISQThermodynamics::planckFunction | attribute | PlanckFunctionValue |  |
| ISQSpaceTime::planeAngle | alias |  |  |
| ISQSpaceTime::planetaryPosition3dVector | attribute | PlanetaryPosition3dVector |  |
| ISQCharacteristicNumbers::plasticityNumber | alias |  |  |
| ISQCharacteristicNumbers::poiseuilleNumber | attribute | PoiseuilleNumberValue |  |
| ISQMechanics::poissonNumber | attribute | PoissonNumberValue |  |
| ISQCharacteristicNumbers::pomerantsevNumber | attribute | PomerantsevNumberValue |  |
| ISQSpaceTime::position3dVector | attribute | Position3dVector |  |
| ISQMechanics::potentialEnergy | attribute | EnergyValue |  |
| ISQMechanics::power | attribute | PowerValue |  |
| ISQCharacteristicNumbers::powerCoefficient | alias |  |  |
| ISQElectromagnetism::powerFactor | attribute | PowerFactorValue |  |
| ISQCharacteristicNumbers::powerNumber | attribute | PowerNumberValue |  |
| ISQElectromagnetism::poyntingVectorMagnitude | attribute | PoyntingVectorMagnitudeValue |  |
| ISQCharacteristicNumbers::prandtlMagneticNumber | attribute | PrandtlMagneticNumberValue |  |
| ISQCharacteristicNumbers::prandtlNumber | attribute | PrandtlNumberValue |  |
| ISQMechanics::pressure | attribute | PressureValue |  |
| ISQThermodynamics::pressureCoefficient | attribute | PressureCoefficientValue |  |
| ISQAtomicNuclear::principalQuantumNumber | attribute | CountValue |  |
| ISQSpaceTime::propagationCoefficient | attribute | PropagationCoefficientValue |  |
| ISQAtomicNuclear::properMass | alias |  |  |
| ISQAtomicNuclear::protonNumber | alias |  |  |
| ISQCharacteristicNumbers::'pécletNumber' | attribute | 'PécletNumberValue' |  |
| ISQCharacteristicNumbers::'pécletNumberForMassTransfer' | attribute | 'PécletNumberForMassTransferValue' |  |
| ISQElectromagnetism::qualityFactor | attribute | QualityFactorValue |  |
| ISQAtomicNuclear::qualityFactorForIonizingRadiation | attribute | QualityFactorForIonizingRadiationValue |  |
| ISQLight::quantityOfIllumination | alias |  |  |
| ISQLight::quantityOfLight | alias |  |  |
| ISQInformation::quantizingDistortionRate | attribute | PowerValue |  |
| ISQAtomicNuclear::quantumNumber | attribute | QuantumNumberValue |  |
| SI::radian | attribute | AngularMeasureUnit |  |
| SI::'radian per metre' | attribute | PhaseCoefficientUnit |  |
| ISQSpaceTime::radialDistance | attribute | LengthValue |  |
| SI::'radian metre squared per kilogram to the power 1' | attribute | SpecificOpticalRotatoryPowerUnit |  |
| SI::'radian metre squared per mole' | attribute | MolarOpticalRotatoryPowerUnit |  |
| SI::'radian second to the power minus 1' | attribute | AngularVelocityUnit |  |
| SI::'radian second to the power minus 2' | attribute | AngularAccelerationUnit |  |
| ISQLight::radiance | attribute | RadianceValue |  |
| ISQLight::radianceFactor | attribute | RadianceFactorValue |  |
| ISQLight::radiantEmittance | alias |  |  |
| ISQLight::radiantEnergy | attribute | EnergyValue |  |
| ISQLight::radiantEnergyDensity | attribute | RadiantEnergyDensityValue |  |
| ISQAtomicNuclear::radiantEnergyForIonizingRadiation | attribute | EnergyValue |  |
| ISQLight::radiantExitance | attribute | RadiantExitanceValue |  |
| ISQLight::radiantExposure | attribute | RadiantExposureValue |  |
| ISQLight::radiantFlux | attribute | RadiantFluxValue |  |
| ISQLight::radiantIntensity | attribute | RadiantIntensityValue |  |
| ISQLight::radiantPower | alias |  |  |
| ISQSpaceTime::radius | attribute | LengthValue |  |
| ISQSpaceTime::radiusOfCurvature | attribute | LengthValue |  |
| ISQThermodynamics::ratioOfSpecificHeatCapacities | attribute | RatioOfSpecificHeatCapacitiesValue |  |
| ISQCharacteristicNumbers::rayleighNumber | attribute | RayleighNumberValue |  |
| ISQElectromagnetism::reactance | attribute | ReactanceValue |  |
| ISQAtomicNuclear::reactionEnergy | attribute | EnergyValue |  |
| ISQElectromagnetism::reactivePower | attribute | PowerValue |  |
| ISQAtomicNuclear::reactorTimeConstant | attribute | DurationValue |  |
| ISQAtomicNuclear::recombinationCoefficient | attribute | RecombinationCoefficientValue |  |
| ISQInformation::redundancy | attribute | RedundancyValue |  |
| ISQCharacteristicNumbers::reechNumber | attribute | ReechNumberValue |  |
| ISQLight::reflectance | attribute | ReflectanceValue |  |
| ISQLight::reflectanceFactor | attribute | ReflectanceFactorValue |  |
| ISQLight::refractiveIndex | attribute | RefractiveIndexValue |  |
| ISQChemistryMolecular::relativeActivityOfSolute | alias |  |  |
| ISQChemistryMolecular::relativeActivityOfSolvent | alias |  |  |
| ISQChemistryMolecular::relativeAtomicMass | attribute | RelativeAtomicMassValue |  |
| ISQMechanics::relativeDensity | alias |  |  |
| ISQInformation::relativeEntropy | attribute | RelativeEntropyValue |  |
| ISQThermodynamics::relativeHumidity | attribute | RelativeHumidityValue |  |
| ISQMechanics::relativeLinearStrain | attribute | RelativeLinearStrainValue |  |
| ISQThermodynamics::relativeMassConcentrationOfVapour | attribute | RelativeMassConcentrationOfVapourValue |  |
| ISQAtomicNuclear::relativeMassDefect | attribute | RelativeMassDefectValue |  |
| ISQMechanics::relativeMassDensity | attribute | RelativeMassDensityValue |  |
| ISQAtomicNuclear::relativeMassExcess | attribute | RelativeMassExcessValue |  |
| ISQThermodynamics::relativeMassRatioOfVapour | attribute | RelativeMassRatioOfVapourValue |  |
| ISQElectromagnetism::relativePermeability | attribute | RelativePermeabilityValue |  |
| ISQElectromagnetism::relativePermittivity | attribute | RelativePermittivityValue |  |
| ISQThermodynamics::relativePressureCoefficient | attribute | RelativePressureCoefficientValue |  |
| ISQInformation::relativeRedundancy | attribute | RelativeRedundancyValue |  |
| ISQMechanics::relativeVolumeStrain | attribute | RelativeVolumeStrainValue |  |
| ISQCondensedMatter::relaxationTime | attribute | DurationValue |  |
| ISQElectromagnetism::reluctance | attribute | ReluctanceValue |  |
| ISQSpaceTime::repetency | attribute | RepetencyValue |  |
| ISQCondensedMatter::residualResistivity | attribute | ResistivityValue |  |
| ISQElectromagnetism::resistance | attribute | ResistanceValue |  |
| ISQElectromagnetism::resistanceToAlternatingCurrent | attribute | ResistanceToAlternatingCurrentValue |  |
| ISQElectromagnetism::resistivity | attribute | ResistivityValue |  |
| ISQAtomicNuclear::resonanceEnergy | attribute | EnergyValue |  |
| ISQAtomicNuclear::resonanceEscapeProbability | attribute | ResonanceEscapeProbabilityValue |  |
| ISQAtomicNuclear::restEnergy | attribute | EnergyValue |  |
| ISQAtomicNuclear::restMass | attribute | MassValue |  |
| ISQAcoustics::reverberationTime | attribute | DurationValue |  |
| ISQCharacteristicNumbers::reynoldsElectricNumber | attribute | ReynoldsElectricNumberValue |  |
| ISQCharacteristicNumbers::reynoldsMagneticNumber | attribute | ReynoldsMagneticNumberValue |  |
| ISQCharacteristicNumbers::reynoldsNumber | attribute | ReynoldsNumberValue |  |
| ISQCondensedMatter::richardsonConstant | attribute | RichardsonConstantValue |  |
| ISQCharacteristicNumbers::richardsonNumber | attribute | RichardsonNumberValue |  |
| ISQCharacteristicNumbers::robertsNumber | attribute | RobertsNumberValue |  |
| ISQMechanics::rollingResistanceFactor | attribute | RollingResistanceFactorValue |  |
| ISQCharacteristicNumbers::rossbyNumber | attribute | RossbyNumberValue |  |
| ISQSpaceTime::rotation | attribute | CountValue |  |
| ISQSpaceTime::rotationalDisplacement | attribute | AngularMeasureValue |  |
| ISQSpaceTime::rotationalFrequency | attribute | FrequencyValue |  |
| ISQAtomicNuclear::rydbergConstant | attribute | RydbergConstantValue |  |
| SI::second | attribute | DurationUnit |  |
| ISQElectromagnetism::scalarMagneticPotential | attribute | ElectricCurrentValue |  |
| ISQCharacteristicNumbers::schmidtNumber | attribute | SchmidtNumberValue |  |
| SI::'second (angle)' | attribute | AngularMeasureUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::'second (angle)' |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| isExact | attribute | Boolean | unitConversion |
| SI::'second ampere' | attribute | ElectricChargeUnit |  |
| SI::'second to the power minus 1' | attribute | AngularVelocityUnit |  |
| SI::'second to the power minus 1 steradian to the power minus 1' | attribute | PhotonIntensityUnit |  |
| SI::'second to the power minus 2' | attribute | AngularAccelerationUnit |  |
| ISQMechanics::secondAxialMomentOfArea | attribute | SecondAxialMomentOfAreaValue |  |
| ISQMechanics::secondPolarMomentOfArea | attribute | SecondPolarMomentOfAreaValue |  |
| ISQMechanics::sectionModulus | attribute | SectionModulusValue |  |
| ISQCondensedMatter::seebeckCoefficientForSubstancesAAndB | attribute | SeebeckCoefficientForSubstancesAAndBValue |  |
| ISQElectromagnetism::selfInductance | alias |  |  |
| ISQMechanics::shearModulus | alias |  |  |
| ISQMechanics::shearStrain | attribute | ShearStrainValue |  |
| ISQMechanics::shearStress | attribute | ShearStressValue |  |
| ISQCondensedMatter::shortRangeOrderParameter | attribute | ShortRangeOrderParameterValue |  |
| ISQInformation::signalEnergyPerBinaryDigit | attribute | EnergyValue |  |
| ISQAtomicNuclear::slowingDownArea | attribute | AreaValue |  |
| ISQAtomicNuclear::slowingDownDensity | attribute | SlowingDownDensityValue |  |
| ISQAtomicNuclear::slowingDownLength | attribute | LengthValue |  |
| ISQSpaceTime::solidAngularMeasure | attribute | SolidAngularMeasureValue |  |
| ISQCharacteristicNumbers::sommerfeldNumber | attribute | SommerfeldNumberValue |  |
| ISQAcoustics::soundEnergy | attribute | EnergyValue |  |
| ISQAcoustics::soundEnergyDensity | attribute | SoundEnergyDensityValue |  |
| ISQAcoustics::soundExposure | attribute | SoundExposureValue |  |
| ISQAcoustics::soundExposureLevel | attribute | SoundExposureLevelValue |  |
| ISQAcoustics::soundIntensity | attribute | SoundIntensityValue |  |
| ISQAcoustics::soundPower | attribute | PowerValue |  |
| ISQAcoustics::soundPowerLevel | attribute | SoundPowerLevelValue |  |
| ISQAcoustics::soundPressure | attribute | PressureValue |  |
| ISQAcoustics::soundPressureLevel | attribute | SoundPressureLevelValue |  |
| ISQElectromagnetism::sourceTension | alias |  |  |
| ISQElectromagnetism::sourceVoltage | attribute | SourceVoltageValue |  |
| ISQAtomicNuclear::specificActivity | attribute | SpecificActivityValue |  |
| ISQThermodynamics::specificEnergy | attribute | SpecificEnergyValue |  |
| ISQAtomicNuclear::specificEnergyImparted | attribute | AbsorbedDoseValue |  |
| ISQThermodynamics::specificEnthalpy | attribute | SpecificEnthalpyValue |  |
| ISQThermodynamics::specificEntropy | attribute | SpecificEntropyValue |  |
| ISQThermodynamics::specificGasConstant | attribute | SpecificGasConstantValue |  |
| ISQThermodynamics::specificGibbsEnergy | attribute | SpecificEnergyValue |  |
| ISQThermodynamics::specificGibbsFunction | alias |  |  |
| ISQThermodynamics::specificHeatCapacity | attribute | SpecificHeatCapacityValue |  |
| ISQThermodynamics::specificHeatCapacityAtConstantPressure | attribute | SpecificHeatCapacityAtConstantPressureValue |  |
| ISQThermodynamics::specificHeatCapacityAtConstantVolume | attribute | SpecificHeatCapacityAtConstantVolumeValue |  |
| ISQThermodynamics::specificHeatCapacityAtSaturatedVapourPressure | attribute | SpecificHeatCapacityAtSaturatedVapourPressureValue |  |
| ISQThermodynamics::specificHelmholtzEnergy | attribute | SpecificEnergyValue |  |
| ISQThermodynamics::specificHelmholtzFunction | alias |  |  |
| ISQThermodynamics::specificInternalEnergy | attribute | SpecificEnergyValue |  |
| ISQChemistryMolecular::specificOpticalRotatoryPower | attribute | SpecificOpticalRotatoryPowerValue |  |
| ISQThermodynamics::specificThermodynamicEnergy | alias |  |  |
| ISQMechanics::specificVolume | attribute | SpecificVolumeValue |  |
| ISQLight::spectralIrradiance | attribute | SpectralIrradianceValue |  |
| ISQLight::spectralLuminousEfficacy | attribute | SpectralLuminousEfficacyValue |  |
| ISQLight::spectralLuminousEfficiency | attribute | SpectralLuminousEfficiencyValue |  |
| ISQLight::spectralRadiance | attribute | SpectralRadianceValue |  |
| ISQLight::spectralRadiantEnergy | attribute | SpectralRadiantEnergyValue |  |
| ISQLight::spectralRadiantEnergyDensityInTermsOfWavelength | attribute | SpectralRadiantEnergyDensityInTermsOfWavelengthValue |  |
| ISQLight::spectralRadiantEnergyDensityInTermsOfWavenumber | attribute | SpectralRadiantEnergyDensityInTermsOfWavenumberValue |  |
| ISQLight::spectralRadiantExitance | attribute | SpectralRadiantExitanceValue |  |
| ISQLight::spectralRadiantExposure | attribute | SpectralRadiantExposureValue |  |
| ISQLight::spectralRadiantFlux | attribute | SpectralRadiantFluxValue |  |
| ISQLight::spectralRadiantIntensity | attribute | SpectralRadiantIntensityValue |  |
| ISQLight::spectralRadiantPower | alias |  |  |
| ISQSpaceTime::speed | attribute | SpeedValue |  |
| ISQElectromagnetism::speedOfLight | attribute | SpeedOfLightValue |  |
| ISQLight::speedOfLightInAMedium | attribute | SpeedOfLightInAMediumValue |  |
| ISQSpaceTime::sphericalDisplacement3dVector | attribute | SphericalDisplacement3dVector |  |
| ISQSpaceTime::sphericalPosition3dVector | attribute | SphericalPosition3dVector |  |
| ISQAtomicNuclear::spin | attribute | SpinValue |  |
| ISQAtomicNuclear::spinQuantumNumber | attribute | CountValue |  |
| SI::steradian | attribute | SolidAngularMeasureUnit |  |
| ISQChemistryMolecular::standardAbsoluteActivityInMixture | attribute | StandardAbsoluteActivityInMixtureValue |  |
| ISQChemistryMolecular::standardAbsoluteActivityInSolution | attribute | StandardAbsoluteActivityInSolutionValue |  |
| ISQChemistryMolecular::standardAbsoluteActivityOfSolvent | attribute | StandardAbsoluteActivityOfSolventValue |  |
| ISQChemistryMolecular::standardAmountOfSubstanceConcentration | attribute | AmountOfSubstanceConcentrationValue |  |
| ISQChemistryMolecular::standardChemicalPotential | attribute | StandardChemicalPotentialValue |  |
| ISQChemistryMolecular::standardEquilibriumConstant | attribute | StandardEquilibriumConstantValue |  |
| ISQCharacteristicNumbers::stantonNumber | attribute | StantonNumberValue |  |
| ISQCharacteristicNumbers::stantonNumberForMassTransfer | attribute | StantonNumberForMassTransferValue |  |
| ISQCharacteristicNumbers::starkNumber | attribute | StarkNumberValue |  |
| ISQMechanics::staticFrictionCoefficient | attribute | StaticFrictionCoefficientValue |  |
| ISQMechanics::staticFrictionFactor | alias |  |  |
| ISQAcoustics::staticPressure | attribute | PressureValue |  |
| ISQChemistryMolecular::statisticalWeightOfSubsystem | attribute | CountValue |  |
| ISQCharacteristicNumbers::stefanNumber | attribute | StefanNumberValue |  |
| ISQChemistryMolecular::stoichiometricNumberOfSubstance | attribute | StoichiometricNumberOfSubstanceValue |  |
| ISQCharacteristicNumbers::stokesNumber | attribute | StokesNumberValue |  |
| ISQCharacteristicNumbers::stokesNumberForDrag | attribute | StokesNumberForDragValue |  |
| ISQCharacteristicNumbers::stokesNumberForGravity | attribute | StokesNumberForGravityValue |  |
| ISQCharacteristicNumbers::stokesNumberForRotameter | attribute | StokesNumberForRotameterValue |  |
| ISQCharacteristicNumbers::stokesNumberForVibratingParticles | attribute | StokesNumberForVibratingParticlesValue |  |
| ISQInformation::storageCapacity | attribute | StorageCapacityValue |  |
| ISQInformation::storageSize | alias |  |  |
| ISQMechanics::strain | attribute | StrainValue |  |
| ISQMechanics::strainTensor | attribute | Cartesian3dStrainTensor |  |
| ISQMechanics::stress | attribute | StressValue |  |
| ISQMechanics::stressTensor | attribute | Cartesian3dStressTensor |  |
| ISQCharacteristicNumbers::strouhalNumber | attribute | StrouhalNumberValue |  |
| ISQCondensedMatter::structureFactor | attribute | StructureFactorValue |  |
| ISQCharacteristicNumbers::stuartElectricalNumber | attribute | StuartElectricalNumberValue |  |
| ISQCharacteristicNumbers::stuartNumber | attribute | StuartNumberValue |  |
| ISQCondensedMatter::superconductionTransitionTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQCondensedMatter::superconductorEnergyGap | attribute | EnergyValue |  |
| ISQCharacteristicNumbers::suratmanNumber | alias |  |  |
| ISQAtomicNuclear::surfaceActivityDensity | attribute | SurfaceActivityDensityValue |  |
| ISQThermodynamics::surfaceCoefficientOfHeatTransfer | attribute | SurfaceCoefficientOfHeatTransferValue |  |
| ISQMechanics::surfaceDensity | alias |  |  |
| ISQElectromagnetism::surfaceDensityOfElectricCharge | attribute | SurfaceDensityOfElectricChargeValue |  |
| ISQMechanics::surfaceMassDensity | attribute | SurfaceMassDensityValue |  |
| ISQMechanics::surfaceTension | attribute | SurfaceTensionValue |  |
| ISQElectromagnetism::susceptance | attribute | SusceptanceValue |  |
| ISQCharacteristicNumbers::taylorNumber | attribute | TaylorNumberValue |  |
| SIPrefixes::tebi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::tebi |
| symbol | attribute | String | SIPrefixes::tebi |
| conversionFactor | attribute | Real | SIPrefixes::tebi |
| ISQThermodynamics::temperature | alias |  |  |
| ISQ::temperatureDifference | attribute | TemperatureDifferenceValue |  |
| SIPrefixes::tera | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::tera |
| symbol | attribute | String | SIPrefixes::tera |
| conversionFactor | attribute | Real | SIPrefixes::tera |
| ISQThermodynamics::thermalConductance | attribute | ThermalConductanceValue |  |
| ISQThermodynamics::thermalConductivity | attribute | ThermalConductivityValue |  |
| ISQChemistryMolecular::thermalDiffusionCoefficient | attribute | ThermalDiffusionCoefficientValue |  |
| ISQChemistryMolecular::thermalDiffusionFactor | attribute | ThermalDiffusionFactorValue |  |
| ISQChemistryMolecular::thermalDiffusionRatio | attribute | ThermalDiffusionRatioValue |  |
| ISQThermodynamics::thermalDiffusivity | attribute | ThermalDiffusivityValue |  |
| ISQThermodynamics::thermalEfficiency | attribute | ThermalEfficiencyValue |  |
| ISQThermodynamics::thermalInsulance | attribute | ThermalInsulanceValue |  |
| ISQThermodynamics::thermalResistance | attribute | ThermalResistanceValue |  |
| ISQAtomicNuclear::thermalUtilizationFactor | attribute | ThermalUtilizationFactorValue |  |
| ISQCondensedMatter::thermodynamicCriticalMagneticFluxDensity | attribute | MagneticFluxDensityValue |  |
| ISQThermodynamics::thermodynamicEnergy | alias |  |  |
| ISQChemistryMolecular::thermodynamicEquilibriumConstant | alias |  |  |
| ISQCondensedMatter::'thermodynamicGrüneisenParameter' | attribute | 'ThermodynamicGrüneisenParameterValue' |  |
| ISQBase::thermodynamicTemperature | attribute | ThermodynamicTemperatureValue |  |
| ISQCondensedMatter::thermoelectricVoltageBetweenSubstancesAAndB | attribute | ElectricPotentialDifferenceValue |  |
| ISQSpaceTime::thickness | attribute | LengthValue |  |
| ISQCondensedMatter::thomsonCoefficient | attribute | ThomsonCoefficientValue |  |
| ISQCharacteristicNumbers::thomsonNumber | alias |  |  |
| ISQCharacteristicNumbers::thrustCoefficient | attribute | ThrustCoefficientValue |  |
| ISQSpaceTime::time | alias |  |  |
| ISQSpaceTime::timeConstant | attribute | DurationValue |  |
| SI::tonne | attribute | MassUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::tonne |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| ISQMechanics::torque | attribute | TorqueValue |  |
| ISQAtomicNuclear::totalAngularMomentum | attribute | TotalAngularMomentumValue |  |
| ISQAtomicNuclear::totalAngularMomentumQuantumNumber | attribute | CountValue |  |
| ISQAtomicNuclear::totalCrossSection | attribute | AreaValue |  |
| ISQElectromagnetism::totalCurrent | attribute | ElectricCurrentValue |  |
| ISQElectromagnetism::totalCurrentDensity | attribute | TotalCurrentDensityValue |  |
| ISQAtomicNuclear::totalIonization | attribute | TotalIonizationValue |  |
| ISQAtomicNuclear::totalLinearStoppingPower | attribute | TotalLinearStoppingPowerValue |  |
| ISQAtomicNuclear::totalMassStoppingPower | attribute | TotalMassStoppingPowerValue |  |
| ISQInformation::trafficCarriedIntensity | attribute | TrafficCarriedIntensityValue |  |
| ISQInformation::trafficIntensity | attribute | TrafficIntensityValue |  |
| ISQInformation::trafficLoad | alias |  |  |
| ISQInformation::trafficOfferedIntensity | attribute | TrafficOfferedIntensityValue |  |
| ISQInformation::transferRate | attribute | TransferRateValue |  |
| ISQInformation::transinformationContent | attribute | TransinformationContentValue |  |
| ISQLight::transmittance | attribute | TransmittanceValue |  |
| ISQLight::transmittanceDensity | alias |  |  |
| ISQLight::transmittanceOpticalDensity | attribute | TransmittanceOpticalDensityValue |  |
| ISQChemistryMolecular::transportNumberOfTheIonB | attribute | TransportNumberOfTheIonBValue |  |
| ISQLight::tristimulusValuesForTheCie1931StandardColorimetricObserver | attribute | TristimulusValuesForTheCie1931StandardColorimetricObserverValue |  |
| ISQLight::tristimulusValuesForTheCie1964StandardColorimetricObserver | attribute | TristimulusValuesForTheCie1964StandardColorimetricObserverValue |  |
| ISQAtomicNuclear::unifiedAtomicMassConstant | attribute | MassValue |  |
| ISQSpaceTime::universalCartesianSpatial3dCoordinateFrame | attribute | CartesianSpatial3dCoordinateFrame |  |
| mRefs | attribute | LengthUnit | ISQSpaceTime::universalCartesianSpatial3dCoordinateFrame |
| transformation | attribute | CoordinateTransformation | ISQSpaceTime::universalCartesianSpatial3dCoordinateFrame |
| ISQCondensedMatter::upperCriticalMagneticFluxDensity | attribute | MagneticFluxDensityValue |  |
| SI::'volt ampere reactive' | attribute | PowerUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::'volt ampere reactive' |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
| ISQMechanics::viscosity | alias |  |  |
| ISQElectromagnetism::voltage | attribute | ElectricPotentialDifferenceValue |  |
| ISQElectromagnetism::voltagePhasor | attribute | ElectricPotentialDifferenceValue |  |
| ISQSpaceTime::volume | attribute | VolumeValue |  |
| ISQAcoustics::volumeFlowRate | alias |  |  |
| ISQMechanics::volumeFlowRate | attribute | VolumeFlowRateValue |  |
| ISQChemistryMolecular::volumeFraction | attribute | VolumeFractionValue |  |
| ISQAcoustics::volumeVelocity | attribute | SpeedValue |  |
| ISQAtomicNuclear::volumicActivity | alias |  |  |
| ISQAtomicNuclear::volumicCrossSection | attribute | VolumicCrossSectionValue |  |
| ISQElectromagnetism::volumicElectricCharge | alias |  |  |
| ISQElectromagnetism::volumicElectromagneticEnergy | alias |  |  |
| ISQAtomicNuclear::volumicTotalCrossSection | attribute | VolumicTotalCrossSectionValue |  |
| ISQInformation::waitingProbability | attribute | WaitingProbabilityValue |  |
| ISQSpaceTime::wavelength | attribute | LengthValue |  |
| ISQSpaceTime::wavenumber | alias |  |  |
| ISQCharacteristicNumbers::weberNumber | attribute | WeberNumberValue |  |
| ISQCharacteristicNumbers::weissenbergNumber | attribute | WeissenbergNumberValue |  |
| ISQSpaceTime::width | attribute | LengthValue |  |
| ISQCharacteristicNumbers::womersleyNumber | attribute | WomersleyNumberValue |  |
| ISQMechanics::work | alias |  |  |
| ISQCondensedMatter::workFunction | attribute | EnergyValue |  |
| SIPrefixes::yobi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::yobi |
| symbol | attribute | String | SIPrefixes::yobi |
| conversionFactor | attribute | Real | SIPrefixes::yobi |
| SIPrefixes::yocto | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::yocto |
| symbol | attribute | String | SIPrefixes::yocto |
| conversionFactor | attribute | Real | SIPrefixes::yocto |
| SIPrefixes::yotta | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::yotta |
| symbol | attribute | String | SIPrefixes::yotta |
| conversionFactor | attribute | Real | SIPrefixes::yotta |
| ISQMechanics::youngModulus | alias |  |  |
| SIPrefixes::zebi | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::zebi |
| symbol | attribute | String | SIPrefixes::zebi |
| conversionFactor | attribute | Real | SIPrefixes::zebi |
| SIPrefixes::zepto | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::zepto |
| symbol | attribute | String | SIPrefixes::zepto |
| conversionFactor | attribute | Real | SIPrefixes::zepto |
| SIPrefixes::zetta | attribute | UnitPrefix |  |
| longName | attribute | String | SIPrefixes::zetta |
| symbol | attribute | String | SIPrefixes::zetta |
| conversionFactor | attribute | Real | SIPrefixes::zetta |
| SI::'ångström' | attribute | LengthUnit |  |
| unitConversion | attribute | ConversionByConvention | SI::'ångström' |
| referenceUnit | attribute | MeasurementUnit | unitConversion |
| conversionFactor | attribute | Real | unitConversion |
