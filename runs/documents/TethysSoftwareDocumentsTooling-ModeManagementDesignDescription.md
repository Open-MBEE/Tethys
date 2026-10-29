# Mode management application design description

## Purpose

*Application definition*

| name | type | documentation |
| --- | --- | --- |
| ModeManagementApplication |  | Mode and safe-mode management: the tug mode machine realised in software, taking<br>ground commands and on-board events on the command port and holding the current<br>mode every other application reads. |

*Behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| ModeManagementSoftware |  | The mode manager: TugModes exhibited as the software mode machine on \`command\`,<br>beside the dispatcher that turns each mode command it receives on \`dispatch\`<br>(the command ingest's second copy of the uplink) into the application commands<br>the mode's SubsystemConfiguration row implies and reports each dispatch on the<br>event port. FDIR requests arrive on \`fdirRequests\`; the dispatcher raises them on<br>the application for the mode machine and sheds the applications. |

## Ports

*Ports of the application*

| name | type | documentation |
| --- | --- | --- |
| command | TethysModes::CommandPort |  |

*Ports added by the behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| dispatch | TethysModes::CommandPort |  |
| fdirRequests | TethysModes::CommandPort |  |
| sepCommands | TethysModes::CommandPort |  |
| telecomCommands | TethysModes::CommandPort |  |
| powerCommands | TethysModes::CommandPort |  |
| thermalCommands | TethysModes::CommandPort |  |
| captureCommands | TethysModes::CommandPort |  |
| inspectorCommands | TethysModes::CommandPort |  |
| autonomyCommands | TethysModes::CommandPort |  |

## State machine

*Exhibited state machines*

| name | type | documentation |
| --- | --- | --- |
| modes | TethysModes::TugModes |  |
| dispatcher |  |  |

*States*

| name | type | documentation |
| --- | --- | --- |
| flightMode |  |  |
| sepString |  | The solar-electric propulsion string: off until commissioning, standby<br>between arcs, thrusting during one and during the approach until the<br>rendezvous range update, burning the disposal arc until its duration<br>elapses and then off for good; off in safe mode. |
| telecom |  | Deep-space link: low-gain omni from launch and in safe mode, high-gain<br>when pointed; the proximity relay is on with the inspector in flight. |
| attitudeControl |  | Reaction wheels for cruise and thrust; hydrazine thrusters for proximity<br>operations, capture and despin, and for the sun-pointed safe mode. |
| captureMechanism |  | Capture bag: stowed until CaptureGo, deployed during capture, cinched on<br>completion, released at disposal. |

## Parameter table

*Parameters: id, value, range, unit*

| parameterId | value | minimum | maximum | unitSymbol | inRange |
| --- | --- | --- | --- | --- | --- |
| 41 | 300 | 1 | 3600 | s | true |
| 42 | 600 | 10 | 3600 | s | true |
| 43 | 11 | 0 | 11 | 1 | true |
| 44 | 1 | 0 | 1 | 1 | true |

## Rate, worst-case execution time and deadline

*Scheduled task*

| name | period | wcet | deadline | utilisation | activeModes |
| --- | --- | --- | --- | --- | --- |
| modeManagementTask | 0.125 \[s\] | 0.003 \[s\] | 0.125 \[s\] | 0.024 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |

## Commands, telemetry, events and packets owned

*Commands*

| mnemonic | opcodeNumber | criticality | hazardous | documentation |
| --- | --- | --- | --- | --- |
| MOD\_SET\_MODE | 2817 | critical | true | Transition the tug to a commanded mode. |
| MOD\_CONFIRM\_MODE | 2818 | critical | false | Confirm a pending two-step mode transition. |
| MOD\_CANCEL\_PENDING\_MODE | 2819 | routine | false | Cancel a pending two-step mode transition. |
| MOD\_LOAD\_MODE\_TABLE | 2820 | critical | false | Load the mode × subsystem table. |
| MOD\_ENABLE\_AUTO\_TRANSITION | 2821 | critical | false | Allow on-board events to drive mode transitions. |
| MOD\_DISABLE\_AUTO\_TRANSITION | 2822 | critical | false | Only ground commands may drive mode transitions. |
| MOD\_HOLD\_MODE | 2823 | routine | false | Hold the current mode against events. |
| MOD\_RESUME\_MODE | 2824 | routine | false | Release a mode hold. |
| MOD\_SET\_TRANSITION\_TIMEOUT | 2825 | routine | false | Set the time a transition may take before it is declared failed. |

*Telemetry points*

| mnemonic | pointId | kind | rate | unitSymbol |
| --- | --- | --- | --- | --- |
| MOD\_CURRENT\_MODE | 11001 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_PREVIOUS\_MODE | 11002 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_MODE\_TIME | 11003 | housekeeping | 1 \[Hz\] | s |
| MOD\_TRANSITION\_COUNT | 11004 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_PENDING\_MODE | 11005 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_AUTO\_TRANSITION\_EN | 11006 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_MODE\_TABLE\_ID | 11007 | housekeeping | 0.1 \[Hz\] | 1 |
| MOD\_MODE\_TABLE\_CRC | 11008 | engineering | 0.1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_01 | 11009 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_02 | 11010 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_03 | 11011 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_04 | 11012 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_05 | 11013 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_06 | 11014 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_07 | 11015 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_08 | 11016 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_09 | 11017 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_10 | 11018 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_11 | 11019 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_SUBSYSTEM\_STATE\_12 | 11020 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_MODE\_HOLD | 11021 | housekeeping | 1 \[Hz\] | 1 |
| MOD\_TRANSITION\_TIMEOUT | 11022 | engineering | 0.1 \[Hz\] | s |

*Events (the fault-relevant ones are the fault-protection interface)*

| mnemonic | eventId | severity | fdirRelevant | text |
| --- | --- | --- | --- | --- |
| MOD\_EVT\_STARTED | 1101 | info | false | application started |
| MOD\_EVT\_STOPPED | 1102 | warning | false | application stopped |
| MOD\_EVT\_CMD\_ACCEPTED | 1103 | info | false | command accepted |
| MOD\_EVT\_CMD\_REJECTED | 1104 | warning | false | command rejected |
| MOD\_EVT\_TABLE\_LOADED | 1105 | info | false | parameter table loaded |
| MOD\_EVT\_TABLE\_INVALID | 1106 | fault | true | parameter table failed validation |
| MOD\_EVT\_WATCHDOG\_MISSED | 1107 | fault | true | application missed its watchdog window |
| MOD\_EVT\_MODE\_CHANGE\_SEEN | 1108 | info | false | application applied a mode change |
| MOD\_EVT\_MODE\_ENTERED | 1109 | info | false | mode entered |
| MOD\_EVT\_MODE\_PENDING | 1110 | info | false | two-step transition pending |
| MOD\_EVT\_MODE\_REJECTED | 1111 | warning | false | transition rejected by table |
| MOD\_EVT\_TRANSITION\_TIMEOUT | 1112 | fault | true | transition did not complete |
| MOD\_EVT\_AUTO\_TRANSITION | 1113 | warning | false | event-driven transition |

*Packets*

| mnemonic | apid | apidClass | rate | lengthOctets | layoutConsistent |
| --- | --- | --- | --- | --- | --- |
| MOD\_HK\_01 | 42 | housekeeping | 1 \[Hz\] | 41 | true |
| MOD\_ENG\_01 | 43 | housekeeping | 0.1 \[Hz\] | 20 | true |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| modeManagement | safeModeEntry, modeTransitions, modeManagementApplication | 3 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| modeManagement | levelA | The mode manager: safe-mode entry, the capture-mode inhibit, the command dispatcher. |

One volume per application of the Argent flight software, in the order of TethysFlightSoftware::ArgentFlightSoftware. Every table is a query over TethysFlightSoftware, TethysFlightBehaviour, TethysFlightTiming, TethysFlightDictionary, TethysSoftwareRequirements and TethysSoftwareAssurance.
