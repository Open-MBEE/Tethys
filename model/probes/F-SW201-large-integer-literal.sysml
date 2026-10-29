// Probe: an integer literal above 2^31-1 bound to a Natural. KerML §8.2.3.1 LiteralInteger carries an
// unbounded Integer value and ScalarValues::Natural is unbounded, so the literal is legal.
// OpenSysML: evaluates (big = 4294967295, bigSum = 4294967295). Pilot 2026-08: "error: For input
// string: "4294967295"" — the literal is read as a 32-bit int. Spelling it as a product is accepted.
package F_SW201 {
    private import ScalarValues::*;
    attribute big : Natural = 4294967295;
    attribute bigProduct : Natural = 65535 * 65536 + 65535;
    attribute bigSum : Natural = bigProduct;
    attribute small : Natural = 2147483647;
}
