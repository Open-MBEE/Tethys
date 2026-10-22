// The launch segment: the fictional Arcturus-5H heavy launcher, its adapter and the launch window.
package TethysLaunch {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;

    part def LaunchVehicle {
        doc /* A heavy-class launcher characterised by the mass it delivers to a given C3. */
        attribute performanceAtC3 : MassValue;
        attribute characteristicEnergyKm2PerS2 : Real;
        port payloadAdapter : ~MechanicalPort;
    }
    part def LaunchSite {
        doc /* The pad and its processing facilities. */
        attribute latitude : AngularMeasureValue;
    }
    part def LaunchWindow {
        doc /* The span of days in which the escape trajectory closes with the available C3. */
        attribute opens : DurationValue;
        attribute closes : DurationValue;
    }
    part arcturus5H : LaunchVehicle {
        doc /* Arcturus-5H: 17 200 kg to C3 = 2 km²/s², the Tethys direct-escape case. */
        attribute :>> performanceAtC3 = 17200 [kg];
        attribute :>> characteristicEnergyKm2PerS2 = 2.0;
    }
}
