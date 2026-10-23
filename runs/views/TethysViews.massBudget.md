<!-- TethysViews::massBudget — table rendering (render budgetTable) -->
| Element | Kind | Type | Declared in |
| --- | --- | --- | --- |
| TethysBudgets::massBudget | part | MassBudget |  |
| TethysTugStructure::argentDesign | part | ArgentTug |  |
| sep | part | ArgentPropulsion | TethysTugStructure::argentDesign |
| xenonMass | attribute | MassValue | sep |
| rcs | part | ArgentReactionControl | TethysTugStructure::argentDesign |
| hydrazineMass | attribute | MassValue | rcs |
| captureSystem | part | ArgentCapture | TethysTugStructure::argentDesign |
| maximumBodyMass | attribute | MassValue | captureSystem |
| dryMass | attribute | MassValue | TethysTugStructure::argentDesign |
| wetMass | attribute | MassValue | TethysTugStructure::argentDesign |
| TethysInspector::wren | part | Inspector |  |
| wetMass | attribute | MassValue | TethysInspector::wren |
