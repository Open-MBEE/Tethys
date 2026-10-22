package TethysInspectorDetail {
    doc /* The Wren inspector in detail: the units of its bus, imaging and radar payload,
         * cold-gas propulsion and proximity relay, the data products it returns, its
         * circumnavigation campaign as a timeline of events, and the flight article as an
         * individual whose timeslices and snapshots carry the mass before and after release.
         * TethysInspector (the backbone) keeps the top-level `wren`; everything here refines
         * it. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RealFunctions::*;
    private import TethysEnvironment::*;
    private import TethysInterfaces::*;
    private import TethysInspector::*;

    metadata def FlightMeasured {
        doc /* Marks an element whose values are measured in flight (telemetry, navigation
             * solutions) rather than designed: the reader must not take them as allocations. */
    }

    enum def SpinState {
        doc /* The rotation state of a small body as the characterisation reports it:
             * principal-axis rotation about the maximum-inertia axis, or non-principal-axis
             * tumbling, which the capture envelope excludes. */
        principalAxis;
        tumbling;
    }

    item def ImageFrame {
        doc /* One camera frame of the target: the solar phase angle it was taken at, which the
             * shape model needs spread over many values, and its compressed size on the link. */
        attribute phaseAngle : AngularMeasureValue;
        attribute frameSize : StorageCapacityValue;
    }
    item def RadarEcho {
        doc /* One bistatic radar echo: the tug transmits, Wren receives on the far side of the
             * body, and the two-way delay through the interior sounds its density structure. */
        attribute delay : DurationValue;
        attribute sampleSize : StorageCapacityValue;
    }
    item def RangingTone {
        doc /* A proximity-link ranging tone; its round trip measures the Wren–tug range the
             * gravity-perturbation mass estimate and the collision-avoidance monitor use. */
        attribute range : LengthValue;
    }
    item def TargetCharacterisation {
        doc /* The product of the characterisation phase: the body's size, mass and spin state
             * with the uncertainty the capture-commit decision is taken against. */
        attribute meanDiameter : LengthValue;
        attribute mass : MassValue;
        attribute massUncertaintyFraction : Real;
        attribute rotationPeriod : DurationValue;
        attribute spinState : SpinState;
    }

    part def BusStructure {
        doc /* The 12U aluminium frame, deployment rails and the dispenser interface. */
        attribute mass : MassValue;
    }
    part def SolarArray {
        doc /* Body-mounted triple-junction cells; sized for the 1.0–1.07 AU of the
             * characterisation phase. */
        attribute mass : MassValue;
        attribute endOfLifePower : PowerValue;
    }
    part def Battery {
        doc /* Lithium-ion battery that carries the eclipse behind the body and the imaging
             * peaks. */
        attribute mass : MassValue;
        attribute capacity : EnergyValue;
    }
    part def Avionics {
        doc /* Command and data handling, including the image compressor and the solid-state
             * recorder. */
        attribute mass : MassValue;
        attribute recorderCapacity : StorageCapacityValue;
    }
    part def AttitudeControl {
        doc /* Star tracker, sun sensors, gyros and reaction wheels; the wheels hold the cameras
             * on the body during a pass, the cold gas desaturates them. */
        attribute mass : MassValue;
        attribute pointingKnowledge : AngularMeasureValue;
    }
    part def ProximityTransceiver {
        doc /* The proximity-link transceiver: Wren's half of InspectorRelayLink, with the radar
             * receive chain's timing reference. */
        attribute mass : MassValue;
        attribute transmitPower : PowerValue;
        attribute dataRate : BinaryDigitRateValue;
        attribute maximumRange : LengthValue;
        port link : RfPort;
    }
    part def WrenBus :> CubesatBus {
        doc /* The Wren bus as built: the units behind the backbone's CubesatBus. */
        part structure : BusStructure;
        part arrays : SolarArray;
        part battery : Battery;
        part avionics : Avionics;
        part adcs : AttitudeControl;
        part transceiver : ProximityTransceiver;
    }

    part def Camera {
        doc /* A camera of the imaging payload: its focal length sets the pixel scale at the
             * 20–100 m of the circumnavigation. */
        attribute mass : MassValue;
        attribute focalLength : LengthValue;
        attribute fieldOfView : AngularMeasureValue;
        out item frames : ImageFrame [*] ordered;
    }
    part def RadarReceiver {
        doc /* The bistatic radar receiver; the tug's transmitter is its other half. */
        attribute mass : MassValue;
        attribute centreFrequency : FrequencyValue;
        out item echoes : RadarEcho [*] ordered;
    }
    part def WrenPayload :> ImagingPayload {
        doc /* The imaging payload as built: visible and thermal cameras and the radar
             * receiver. */
        part visibleCamera : Camera;
        part thermalCamera : Camera;
        part radarReceiver : RadarReceiver;
        out item characterisation : TargetCharacterisation;
    }

    part def ColdGasTank {
        doc /* The nitrogen tank; its fill is the propellantMass of the backbone's
             * ColdGasPropulsion. */
        attribute mass : MassValue;
        attribute maximumPressure : PressureValue;
    }
    part def ColdGasThruster {
        doc /* One of the thrusters; eight give six-axis control for forced motion. */
        attribute thrust : ForceValue;
        attribute specificImpulse : DurationValue;
    }
    part def WrenColdGas :> ColdGasPropulsion {
        doc /* The cold-gas system as built: tank, eight thrusters, and the Δv it affords from
             * the rocket equation against the wet mass. */
        part tank : ColdGasTank;
        part thrusters : ColdGasThruster [8];
        attribute specificImpulse : DurationValue;
        attribute propellantRemaining : MassValue;
    }

    part def WrenInspector :> Inspector {
        doc /* Wren refined: the backbone's three subsystems redefined by their as-built
             * definitions, and the mass as it stands at a moment of the flight (the wet mass
             * is the design value). */
        part :>> bus : WrenBus;
        part :>> payload : WrenPayload;
        part :>> propulsion : WrenColdGas;
        attribute currentMass : MassValue;
        assert constraint massRollUp {
            doc /* The unit masses and the propellant fill fit under the wet mass. */
            bus.structure.mass + bus.arrays.mass + bus.battery.mass + bus.avionics.mass
                + bus.adcs.mass + bus.transceiver.mass
                + payload.visibleCamera.mass + payload.thermalCamera.mass
                + payload.radarReceiver.mass
                + propulsion.tank.mass + propulsion.propellantMass <= wetMass
        }
    }

    individual part def WrenFlightArticle :> WrenInspector {
        doc /* The one Wren that flies: the unit masses as weighed, the nitrogen fill, and the
             * timeslices of its life from stowed to retired. */
    }

    individual part wrenFM : WrenFlightArticle :> wren {
        doc /* The Wren flight model, 24 kg wet: 13.1 kg bus, 4.5 kg payload, 3.0 kg cold-gas
             * hardware, 1.6 kg nitrogen and 1.8 kg of mass margin at the inspector level. */
        part :>> bus {
            part :>> structure { attribute :>> mass = 4.0 [kg]; }
            part :>> arrays { attribute :>> mass = 2.4 [kg]; attribute :>> endOfLifePower = 38.0 [W]; }
            part :>> battery { attribute :>> mass = 1.8 [kg]; attribute :>> capacity = 324.0e3 [J]; }
            part :>> avionics { attribute :>> mass = 1.6 [kg]; attribute :>> recorderCapacity = 64.0e9 [bit]; }
            part :>> adcs { attribute :>> mass = 2.2 [kg]; attribute :>> pointingKnowledge = 0.02 ['°']; }
            part :>> transceiver {
                attribute :>> mass = 1.1 [kg];
                attribute :>> transmitPower = 2.0 [W];
                attribute :>> dataRate = 256.0e3 ['bit/s'];
                attribute :>> maximumRange = 5.0e3 [m];
            }
        }
        part :>> payload {
            part :>> visibleCamera { attribute :>> mass = 1.4 [kg]; attribute :>> focalLength = 0.105 [m]; attribute :>> fieldOfView = 4.8 ['°']; }
            part :>> thermalCamera { attribute :>> mass = 1.2 [kg]; attribute :>> focalLength = 0.050 [m]; attribute :>> fieldOfView = 10.0 ['°']; }
            part :>> radarReceiver { attribute :>> mass = 1.9 [kg]; attribute :>> centreFrequency = 60.0e6 [Hz]; }
        }
        part :>> propulsion {
            part :>> tank { attribute :>> mass = 1.9 [kg]; attribute :>> maximumPressure = 25.0e6 [Pa]; }
            part :>> thrusters { attribute :>> thrust = 0.05 [N]; attribute :>> specificImpulse = 62.0 [s]; }
            attribute :>> mass = 3.0 [kg];
            attribute :>> propellantMass = 1.6 [kg];
            attribute :>> specificImpulse = 62.0 [s];
        }

        timeslice stowed {
            doc /* On the dispenser from launch to release: kept alive and charged over the
                 * umbilical, checked out before release. */
        }
        timeslice freeFlying {
            doc /* From release to the end of the campaign: the circumnavigation, imaging and
                 * sounding. */
        }
        timeslice retired {
            doc /* After the campaign: parked in a sun-side hold and later left on a slow
                 * drift away from the stack, with the propellant residual below. */
        }
        first stowed then freeFlying;
        first freeFlying then retired;
        snapshot atRelease :> stowed.endShot {
            doc /* Wren as released: the full 24 kg wet mass leaves the stack. */
            attribute :>> currentMass = 24.0 [kg];
            part :>> propulsion { attribute :>> propellantRemaining = 1.6 [kg]; }
        }
        snapshot atEndOfCampaign :> freeFlying.endShot {
            doc /* Wren at the end of the campaign: 1.2 kg of the 1.6 kg of nitrogen spent on
                 * forced motion and wheel desaturation. */
            #FlightMeasured attribute :>> currentMass = 22.8 [kg];
            part :>> propulsion { #FlightMeasured attribute :>> propellantRemaining = 0.4 [kg]; }
        }
        attribute propellantSpent : MassValue = atRelease.currentMass - atEndOfCampaign.currentMass;
    }

    calc def ForcedMotionDeltaVPerOrbit {
        doc /* Δv in m/s one forced-motion circumnavigation costs at radius r (m) with period
             * T (s) when the body's gravity is negligible: the centripetal acceleration
             * 4π²r/T² held for one period. */
        in radiusM : Real;
        in periodS : Real;
        return deltaVMPerS : Real = 4.0 * pi * pi * radiusM / periodS;
    }
    calc def CampaignDeltaV {
        doc /* Δv in m/s of a campaign of n forced-motion orbits plus the station-keeping
             * against solar radiation pressure a_srp (m/s²) over the campaign duration (s). */
        in orbits : Real;
        in deltaVPerOrbitMPerS : Real;
        in srpAccelerationMPerS2 : Real;
        in durationS : Real;
        return deltaVMPerS : Real = orbits * deltaVPerOrbitMPerS + srpAccelerationMPerS2 * durationS;
    }
    calc def ColdGasDeltaV {
        doc /* Δv in m/s the cold-gas fill affords: the rocket equation with Isp (s), wet mass
             * (kg) and propellant mass (kg). */
        in specificImpulseS : Real;
        in wetMassKg : Real;
        in propellantMassKg : Real;
        return deltaVMPerS : Real = RocketEquationDeltaV(specificImpulseS, wetMassKg, wetMassKg - propellantMassKg);
    }

    occurrence def CircumnavigationCampaign {
        doc /* Wren's characterisation campaign as a timeline: release, link acquisition, the
             * circumnavigation passes at 20–100 m with imaging over many phase angles and
             * bistatic sounding behind the body, the close passes for the gravity-perturbation
             * mass estimate, and the retreat to a hold once the characterisation is delivered. */
        event occurrence checkoutComplete {
            doc /* Wren checked out on the umbilical: power, link, wheels and camera health. */
        }
        event occurrence release {
            doc /* The dispenser releases Wren at a few cm/s; the backbone's inspectorRelease. */
        }
        event occurrence linkAcquired {
            doc /* The proximity link closes; Wren is under tug-relayed command. */
        }
        occurrence imagingPasses {
            doc /* The forced-motion orbits at 50 m, each a sweep through phase angle. */
        }
        occurrence radarSounding {
            doc /* The passes on the anti-tug side of the body where the bistatic echo is
                 * received. */
        }
        occurrence closePasses {
            doc /* The 20 m passes whose trajectory deflection gives the mass estimate. */
        }
        event occurrence characterisationDelivered {
            doc /* Shape, spin state and mass to the tug for the capture-readiness review. */
        }
        event occurrence retreatToHold {
            doc /* Wren leaves the 20–100 m zone for its hold before the tug approaches. */
        }
        first checkoutComplete then release;
        first release then linkAcquired;
        first linkAcquired then imagingPasses;
        first imagingPasses then radarSounding;
        first radarSounding then closePasses;
        first closePasses then characterisationDelivered;
        first characterisationDelivered then retreatToHold;
        attribute circumnavigationRadius : LengthValue;
        attribute circumnavigationPeriod : DurationValue;
        attribute orbitCount : Natural;
        attribute duration : DurationValue;
    }

    individual def WrenCampaign :> CircumnavigationCampaign {
        doc /* The one campaign Wren flies at Amaranth. */
    }
    variation individual def WrenCampaignOutcome :> CircumnavigationCampaign {
        doc /* The campaign as it may unfold: nominal, or cut short by a proximity-link loss
             * (the tug completes a camera-only characterisation), or never started because the
             * dispenser does not release (the tug-only variant). */
        variant occurrence nominal {
            doc /* The full campaign of the timeline above. */
        }
        variant occurrence linkLost {
            doc /* Wren retreats autonomously; imaging ends at the last relayed frame. */
        }
        variant occurrence notReleased {
            doc /* No campaign; the tug characterises from its own cameras. */
        }
    }

    individual #FlightMeasured campaign : WrenCampaign {
        doc /* The Amaranth campaign: 50 m orbits of 6 h, 96 of them over 24 days with 2 cm/s
             * station-keeping against SRP; the Δv is bounded by CampaignDeltaV against
             * ColdGasDeltaV below. */
        attribute :>> circumnavigationRadius = 50.0 [m];
        attribute :>> circumnavigationPeriod = 21600.0 [s];
        attribute :>> orbitCount = 96;
        attribute :>> duration = 2073600.0 [s];
    }

    requirement def CircumnavigationDeltaVRequirement {
        doc /* The cold-gas fill shall afford the campaign's Δv with a factor of two: the
             * forced-motion orbits, SRP station-keeping, and the retreats. */
        attribute affordedDeltaV : SpeedValue;
        attribute campaignDeltaV : SpeedValue;
        require constraint { affordedDeltaV >= 2.0 * campaignDeltaV }
    }
    requirement <'TR-040'> circumnavigationDeltaV : CircumnavigationDeltaVRequirement {
        doc /* 42 m/s afforded (Isp 62 s, 1.6 kg of 24 kg) against 8.9 m/s for 96 orbits of
             * 4π²·50/21600 = 0.091 m/s plus SRP; the factor is 4.7. */
        attribute :>> affordedDeltaV = 42.0 ['m/s'];
        attribute :>> campaignDeltaV = 8.9 ['m/s'];
    }
}
