package F_SW802 {
    private import ScalarValues::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::*;
    private import VerificationCases::*;
    enum def V { planned; pass; }
    part def S { attribute x : Real = 1.0; }
    part s : S;
    verification def D { subject s0 : S; attribute verdict : V default = V::planned; in attribute m : Real; PassIf(m > 0.0) }
    verification u1 : D { subject s0 = s; in m = 2.0; attribute :>> verdict = V::pass; }
    verification u2 : D { subject s0 = s; }
    part reg {
        ref verification cases : D [*] = (u1, u2);
        attribute n : Natural = size(cases);
        attribute v1 : V = u1.verdict;
        attribute v2 : V = u2.verdict;
        attribute verdicts : V [*] = (u1.verdict, u2.verdict);
        attribute passes : Natural = size(verdicts->select { in v : V; v == V::pass });
    }
}
