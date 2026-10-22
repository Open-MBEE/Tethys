// The ground segment: the fictional Meridian deep-space network, mission operations, flight
// dynamics and the data system that turns characterisation data into the capture decision.
package TethysGround {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;

    part def DeepSpaceStation {
        doc /* A deep-space antenna site: its aperture, G/T and EIRP set the link budgets. */
        attribute antennaDiameter : LengthValue;
        attribute longitude : AngularMeasureValue;
        port uplinkDownlink : ~RfPort;
    }
    part def MissionOperationsCentre {
        doc /* Planning, commanding and monitoring of the flight system. */
    }
    part def FlightDynamicsFacility {
        doc /* Low-thrust trajectory design, orbit determination of the tug and of the target,
             * and the DRO insertion design. */
    }
    part def ScienceDataSystem {
        doc /* Processing, archiving and distribution of characterisation and science data
             * products, including the shape and mass models that gate the capture commit. */
    }
    part def GroundNetwork {
        doc /* The Meridian network: three stations about 120° apart in longitude. */
        part stations : DeepSpaceStation[3];
        part moc : MissionOperationsCentre;
        part fdf : FlightDynamicsFacility;
        part sds : ScienceDataSystem;
    }
}
