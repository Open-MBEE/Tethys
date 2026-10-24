// Probe: fixed-point response-time analysis (Joseph & Pandya) as a recursive calc def:
// R = C + ceiling(R / T_high) * C_high iterated to a fixed point (ceiling as -floor(-x), since
// RealFunctions has floor and round only). KerML 8.3.4.8.3 (invocation
// expressions may invoke any Function, including the one being defined) — a construct a
// schedulability engine evaluates natively.
package F_SW196 {
    private import ScalarValues::*;
    private import RealFunctions::*;
    calc def ResponseTime {
        in c : Real;
        in highC : Real;
        in highT : Real;
        in r : Real;
        return response : Real =
            if c + (-floor(-(r / highT))) * highC == r ? r
            else ResponseTime(c, highC, highT, c + (-floor(-(r / highT))) * highC);
    }
    attribute lowTaskResponse : Real = ResponseTime(3.0, 12.0, 62.5, 3.0);
    attribute oneStep : Real = 3.0 + (-floor(-(3.0 / 62.5))) * 12.0;
    attribute meetsDeadline : Boolean = lowTaskResponse <= 62.5;
}
