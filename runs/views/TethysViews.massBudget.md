<!-- TethysViews::massBudget — table rendering (render budgetTable) -->
| Element | Kind | Type | Declared in |
| --- | --- | --- | --- |
| TethysTug::argent | part | Tug |  |
| dryMass | attribute | MassValue | TethysTug::argent |
| wetMass | attribute | MassValue | TethysTug::argent |
| eps | part | ElectricalPower | TethysTug::argent |
| arrayPowerAtOneAu | attribute | PowerValue | eps |
| sep | part | SolarElectricPropulsion | TethysTug::argent |
| xenonMass | attribute | MassValue | sep |
| thrusterCount | attribute | Natural | sep |
| operatingThrusters | attribute | Natural | sep |
| specificImpulse | attribute | DurationValue | sep |
| maximumPower | attribute | PowerValue | sep |
| rcs | part | ReactionControl | TethysTug::argent |
| hydrazineMass | attribute | MassValue | rcs |
| captureSystem | part | CaptureSystem | TethysTug::argent |
| maximumBodyDiameter | attribute | LengthValue | captureSystem |
| maximumBodyMass | attribute | MassValue | captureSystem |
| TethysInspector::wren | part | Inspector |  |
| wetMass | attribute | MassValue | TethysInspector::wren |
