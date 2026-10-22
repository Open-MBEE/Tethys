// The target body as a system element: the thing the mission is about, with the properties the
// capture system and the return trajectory depend on, and the surface the capture bag contacts.
package TethysTarget {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;
    private import TethysEnvironment::*;

    part def SmallBody {
        doc /* A small natural body: its bulk properties as known before and after
             * characterisation, and the contact surface the capture mechanism loads. */
        attribute meanDiameter : LengthValue;
        attribute bulkDensity : MassDensityValue;
        attribute mass : MassValue;
        attribute rotationPeriod : DurationValue;
        port surface : ~MechanicalPort;
    }

    part amaranth : SmallBody {
        doc /* 2031 QX "Amaranth" as designed to: the pre-arrival estimates in
             * TethysEnvironment::amaranth. The as-characterised individual lives in the
             * as-built package. */
        attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
        attribute :>> bulkDensity = TethysEnvironment::amaranth.bulkDensity;
        attribute :>> mass = TethysEnvironment::amaranth.mass;
        attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
    }
}
