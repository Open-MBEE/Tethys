// Wren: the free-flying inspector the tug releases at the target to image it, sound its
// interior and measure its mass before the capture commit.
package TethysInspector {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;

    part def CubesatBus {
        doc /* A 12U bus: structure, body-mounted arrays and battery, avionics, attitude
             * control and the proximity-link transceiver. */
        attribute mass : MassValue;
        port proximity : RfPort;
        port umbilical : ~UmbilicalPort;
    }
    part def ImagingPayload {
        doc /* Visible and thermal cameras and a bistatic radar sounder that uses the tug's
             * transmitter to probe the target's interior. */
        attribute mass : MassValue;
    }
    part def ColdGasPropulsion {
        doc /* Cold-gas thrusters for the slow circumnavigation of the target. */
        attribute mass : MassValue;
        attribute propellantMass : MassValue;
    }
    part def Inspector {
        doc /* The Wren inspector: a cubesat bus, its imaging payload and cold-gas propulsion. */
        attribute wetMass : MassValue;
        part bus : CubesatBus;
        part payload : ImagingPayload;
        part propulsion : ColdGasPropulsion;
        port carrierAttachment : ~MechanicalPort;
        port stowedThermal : ~ThermalPort;
    }

    part wren : Inspector {
        doc /* The flight inspector: 24 kg wet. */
        attribute :>> wetMass = 24.0 [kg];
    }
}
