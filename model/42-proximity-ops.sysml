package TethysProximityOps {
    doc /* Proximity operations at Amaranth: the modes the tug and Wren move through from
         * arrival to departure, the capture sequence as actions from characterisation through
         * commit, approach, contact and cinch to despin, the target as an individual whose
         * timeslices carry its spin state before and after, the stack before and after Wren's
         * release, and the imagery, radar and characterisation flows over the proximity link. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysEnvironment::*;
    private import TethysInterfaces::*;
    private import TethysTug::Tug;
    private import TethysTug::argent;
    private import TethysInspector::wren;
    private import TethysTarget::SmallBody;
    private import TethysTarget::SpinState;
    private import TethysInspectorDetail::*;
    private import TethysCaptureSystem::*;

    part def ProximityDataHandler {
        doc /* The tug-side end of the proximity link: where Wren's frames, echoes and the
             * characterisation arrive for the shape, spin and mass solutions. */
        in item imagery : ImageFrame [*] ordered;
        in item radar : RadarEcho [*] ordered;
        in item characterisation : TargetCharacterisation;
    }
    flow def ProximityLinkFlow {
        doc /* A transfer over the proximity link, carrying the rate it is budgeted at. */
        end source;
        end target;
        attribute linkRate : BinaryDigitRateValue;
    }

    individual part def AmaranthFlightTarget :> SmallBody {
        doc /* Amaranth as the one body the mission meets, as opposed to the cases it may be. */
    }
    individual part amaranthFM : AmaranthFlightTarget {
        doc /* Amaranth across the capture: its size and mass from TethysEnvironment, rotating at
             * its natural period until contact and held to one rotation a day after the despin
             * — the residual the tug's attitude control carries. */
        attribute :>> meanDiameter = amaranth.meanDiameter;
        attribute :>> bulkDensity = amaranth.bulkDensity;
        attribute :>> mass = amaranth.mass;
        timeslice spinning {
            doc /* Before contact: principal-axis rotation at the measured period. */
            attribute :>> rotationPeriod = amaranth.rotationPeriod;
            attribute :>> spinState = SpinState::principalAxis;
        }
        timeslice despun {
            doc /* After the despin: rotating with the stack, once a day. */
            attribute :>> rotationPeriod = 8.64e4 [s];
            attribute :>> spinState = SpinState::principalAxis;
        }
        first spinning then despun;
        snapshot atContact :> spinning.endShot {
            doc /* The instant the bag touches the body: the last moment of the free spin. */
        }
        snapshot atDespinComplete :> despun.startShot {
            doc /* The instant the despin torque drops to zero. */
        }
    }

    part def ProximityStack {
        doc /* The tug with Wren still on its dispenser, as one body for navigation. */
        attribute totalMass : MassValue;
    }
    individual part def ProximityStackFM :> ProximityStack {
        doc /* The flight stack. */
    }
    individual part proxStackFM : ProximityStackFM {
        doc /* The stack before and after Wren's release: 12 624 kg, then 12 600 kg. */
        snapshot beforeRelease {
            doc /* Argent wet plus Wren wet. */
            attribute :>> totalMass = argent.wetMass + wren.wetMass;
        }
        snapshot afterRelease {
            doc /* Argent alone. */
            attribute :>> totalMass = argent.wetMass;
        }
        succession separation first beforeRelease then afterRelease;
    }

    action def CollectData {
        doc /* Gather Wren's frames and echoes off the proximity link for the characterisation. */
        out item imagery : ImageFrame [*] ordered;
        out item radar : RadarEcho [*] ordered;
    }
    action def Characterise {
        doc /* Turn Wren's frames and echoes into the shape, spin and mass solution. */
        in item imagery : ImageFrame [*] ordered;
        in item radar : RadarEcho [*] ordered;
        out characterisation : TargetCharacterisation;
    }
    action def CommitDecision {
        doc /* The go/no-go: the characterisation held against the mechanism's envelope, with
             * the mass taken at the top of its reported uncertainty so an estimate that may
             * exceed the limit is a no-go. */
        in characterisation : TargetCharacterisation;
        in mechanism : CaptureMechanism;
        attribute upperMass : MassValue = characterisation.mass * (1.0 + characterisation.massUncertaintyFraction);
        out go : Boolean = characterisation.meanDiameter <= mechanism.maximumBodyDiameter
            and upperMass <= mechanism.maximumBodyMass
            and 0.1 * upperMass * characterisation.meanDiameter * characterisation.meanDiameter
                * 2.0 * pi / characterisation.rotationPeriod <= mechanism.maximumAngularMomentum
            and characterisation.spinState == SpinState::principalAxis;
    }
    action def FinalApproach {
        doc /* The approach from the standoff along the spin axis, inside the corridor, at a
             * closing speed under the contact limit. */
        attribute standoffRange : LengthValue;
        attribute closingSpeed : SpeedValue;
        attribute corridorHalfAngle : AngularMeasureValue;
    }
    action def Cinch {
        doc /* Close the bag behind the body and tension the lines to preload. */
        attribute preload : ForceValue;
        attribute duration : DurationValue;
    }
    action def Despin {
        doc /* React the body's angular momentum through the bag with the reaction control at a
             * constant torque; the duration and propellant follow from the body's angular
             * momentum (TethysCaptureSystem::DespinDuration, DespinPropellant) and so vary with
             * the target case. */
        attribute torque : TorqueValue;
        attribute duration : DurationValue;
        attribute propellant : MassValue;
    }
    action def Retreat {
        doc /* Back away to a hold range and wait for the ground. */
        attribute holdRange : LengthValue;
    }
    action def CaptureSequence {
        doc /* Characterise, decide, and either approach, meet the body, cinch and despin, or
             * retreat: the sequence from the end of Wren's campaign to a captured, despun
             * body. Contact is the event the sequence waits on; the despin runs to its
             * computed duration. */
        in system : CaptureMechanism;
        action collect : CollectData;
        succession flow imageryToCharacterise of ImageFrame from collect.imagery to characterise.imagery;
        flow of RadarEcho from collect.radar to characterise.radar;
        action characterise : Characterise;
        then action commit : CommitDecision {
            in characterisation = characterise.characterisation;
            in mechanism = system;
        }
        then decide;
            if commit.go then approach;
            else retreat;
        action approach : FinalApproach {
            attribute :>> standoffRange = 50.0 [m];
            attribute :>> closingSpeed = 0.05 ['m/s'];
            attribute :>> corridorHalfAngle = 5.0 ['°'];
        }
        then accept contact : ContactLoad;
        then action cinch : Cinch {
            attribute :>> preload = 2.5e3 [N];
            attribute :>> duration = 600.0 [s];
        }
        then action despin : Despin {
            attribute :>> torque = 120.0 ['N⋅m'];
        }
        then done;
        action retreat : Retreat {
            attribute :>> holdRange = 2000.0 [m];
        }
        then done;
    }

    state def ProximityOpsModes {
        doc /* The proximity-operations modes: hold at the standoff, circumnavigation while Wren
             * flies, approach once committed, cinched once the body is in the bag, retreat on
             * any abort, back to hold after a retreat. Wren's imaging and sounding run as
             * parallel regions during the circumnavigation. */
        attribute linkUp : Boolean;
        attribute commitGo : Boolean;
        attribute abort : Boolean;
        attribute contactMade : Boolean;
        entry; then hold;
        state hold;
        state circumnavigating parallel {
            state imaging;
            state sounding;
        }
        state approaching;
        state cinched;
        state retreating;
        transition first hold accept when linkUp then circumnavigating;
        transition first circumnavigating accept when commitGo then approaching;
        transition first circumnavigating accept when abort then retreating;
        transition first approaching accept when abort then retreating;
        transition first approaching accept when contactMade then cinched;
        transition first retreating accept after 7200.0 [s] then hold;
    }

    part proximityOperations {
        doc /* The proximity-operations context: the tug, Wren and the data handler with the
             * flows between them, and the modes the tug exhibits. */
        part tug : Tug :> argent;
        part inspector : WrenInspector;
        part dataHandler : ProximityDataHandler;
        flow imageryLink : ProximityLinkFlow of ImageFrame
            from inspector.payload.visibleCamera.frames to dataHandler.imagery {
            attribute :>> linkRate = 200.0e3 ['bit/s'];
        }
        flow radarLink : ProximityLinkFlow of RadarEcho
            from inspector.payload.radarReceiver.echoes to dataHandler.radar {
            attribute :>> linkRate = 50.0e3 ['bit/s'];
        }
        flow of TargetCharacterisation from inspector.payload.characterisation to dataHandler.characterisation;
        message characterisationReport of TargetCharacterisation from inspector to dataHandler;
        exhibit state modes : ProximityOpsModes {
            doc /* The nominal pass: link up, commit, contact, no abort. */
            attribute :>> linkUp = true;
            attribute :>> commitGo = true;
            attribute :>> abort = false;
            attribute :>> contactMade = true;
        }
    }
    part captureOperation {
        doc /* The capture as performed on Amaranth: the sequence with Wren's characterisation
             * of the body bound to its first step and the as-built mechanism as its system. */
        part target :> amaranthFM;
        item targetCharacterisation : TargetCharacterisation {
            doc /* What Wren reports about Amaranth: the body as it is, mass to 10 %. */
            attribute :>> meanDiameter = target.meanDiameter;
            attribute :>> mass = target.mass;
            attribute :>> massUncertaintyFraction = 0.1;
            attribute :>> rotationPeriod = target.spinning.rotationPeriod;
            attribute :>> spinState = target.spinning.spinState;
        }
        perform action capture : CaptureSequence {
            in system = captureMechanism;
        }
        bind capture.characterise.characterisation = targetCharacterisation;
    }

    requirement def RetreatRangeRequirement {
        doc /* A retreat shall hold at no less than ten body diameters of the largest body in
             * the envelope, outside its gravity-perturbation and ejecta reach. */
        attribute holdRange : LengthValue;
        attribute bodyDiameter : LengthValue;
        require constraint { holdRange >= 10.0 * bodyDiameter }
    }
    requirement <'TR-043'> retreatRange : RetreatRangeRequirement {
        doc /* 2 000 m against a 10 m body. */
        attribute :>> holdRange = 2000.0 [m];
        attribute :>> bodyDiameter = 10.0 [m];
    }
}
