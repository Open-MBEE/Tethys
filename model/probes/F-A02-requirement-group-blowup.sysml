// Probe: a requirement that `require`s twelve sibling requirements. OpenSysML `-validate` takes
// about 1 s with nine, 9 s with ten and does not finish in 10 min with twelve (time grows ~8x per
// added member); the pilot validates this file in a few seconds. The model keeps every
// requirement group at six members or fewer until this is fixed.
package RequirementGroupBlowup {
    requirement r00;
    requirement r01;
    requirement r02;
    requirement r03;
    requirement r04;
    requirement r05;
    requirement r06;
    requirement r07;
    requirement r08;
    requirement r09;
    requirement r10;
    requirement r11;
    requirement grp {
        require r00;
        require r01;
        require r02;
        require r03;
        require r04;
        require r05;
        require r06;
        require r07;
        require r08;
        require r09;
        require r10;
        require r11;
    }
}
