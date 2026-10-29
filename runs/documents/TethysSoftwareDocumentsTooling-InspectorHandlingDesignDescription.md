# Inspector handling application design description

## Purpose

*Application definition*

| name | type | documentation |
| --- | --- | --- |
| InspectorHandlingApplication |  | Inspector handling: checkout, release, the proximity relay of the inspector's<br>commands and telemetry, and retirement. |

*Behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| InspectorHandlingSoftware |  | The inspector application exhibiting Wren's handling machine. |

## Ports

*Ports of the application*

| name | type | documentation |
| --- | --- | --- |
| inspectorCommands | TethysModes::CommandPort |  |
| relay | TethysInterfaces::DataBusPort |  |

*Ports added by the behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| command | TethysModes::CommandPort |  |

## State machine

*Exhibited state machines*

| name | type | documentation |
| --- | --- | --- |
| handler | TethysFlightBehaviour::InspectorHandler |  |

*States*

| name | type | documentation |
| --- | --- | --- |
| stowed |  |  |
| checkout |  |  |
| released |  |  |
| relayingImagery |  |  |
| retired |  |  |

## Parameter table

*Parameters: id, value, range, unit*

| parameterId | value | minimum | maximum | unitSymbol | inRange |
| --- | --- | --- | --- | --- | --- |
| 25 | 0.05 | 0.02 | 0.2 | m/s | true |
| 26 | 10 | 1 | 600 | s | true |
| 27 | 1e+06 | 1000 | 2e+06 | Hz | true |
| 28 | 7200 | 600 | 86400 | s | true |

## Rate, worst-case execution time and deadline

*Scheduled task*

| name | period | wcet | deadline | utilisation | activeModes |
| --- | --- | --- | --- | --- | --- |
| inspectorHandlingTask | 0.5 \[s\] | 0.003 \[s\] | 0.5 \[s\] | 0.006 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |

## Commands, telemetry, events and packets owned

*Commands*

| mnemonic | opcodeNumber | criticality | hazardous | documentation |
| --- | --- | --- | --- | --- |
| INS\_ARM\_RELEASE | 1793 | critical | true | Arm the inspector release mechanism. |
| INS\_SAFE\_RELEASE | 1794 | critical | false | Disarm the inspector release mechanism. |
| INS\_RELEASE\_INSPECTOR | 1795 | hazardous | true | Release the inspector; irreversible. |
| INS\_FORWARD\_COMMAND | 1796 | critical | false | Forward a command block to the inspector over the relay link. |
| INS\_START\_IMAGING\_SESSION | 1797 | routine | false | Start an inspector imaging session of the given duration. |
| INS\_STOP\_IMAGING\_SESSION | 1798 | routine | false | Stop the inspector imaging session. |
| INS\_SET\_IMAGE\_COMPRESSION | 1799 | routine | false | Set the image compression ratio relayed to the inspector. |
| INS\_SELECT\_RELAY\_RATE | 1800 | routine | false | Set the relay link data rate. |
| INS\_STORE\_IMAGE\_SEGMENT | 1801 | routine | false | Store a relayed image segment in the recorder. |
| INS\_DOWNLINK\_IMAGE | 1802 | routine | false | Queue a stored inspector image for downlink. |
| INS\_RETIRE\_INSPECTOR | 1803 | hazardous | true | Command the inspector to its disposal state; irreversible. |
| INS\_SET\_RELAY\_WINDOW | 1804 | routine | false | Load the next relay contact window. |
| INS\_ENABLE\_RELAY | 1805 | routine | false | Enable the relay receiver. |
| INS\_DISABLE\_RELAY | 1806 | routine | false | Disable the relay receiver. |

*Telemetry points*

| mnemonic | pointId | kind | rate | unitSymbol |
| --- | --- | --- | --- | --- |
| INS\_INSP\_RANGE | 7001 | housekeeping | 1 \[Hz\] | m |
| INS\_INSP\_BEARING\_01 | 7002 | housekeeping | 1 \[Hz\] | rad |
| INS\_INSP\_BEARING\_02 | 7003 | housekeeping | 1 \[Hz\] | rad |
| INS\_INSP\_RANGE\_RATE | 7004 | housekeeping | 1 \[Hz\] | m/s |
| INS\_INSP\_STATE | 7005 | housekeeping | 1 \[Hz\] | 1 |
| INS\_INSP\_BATT\_V | 7006 | housekeeping | 0.1 \[Hz\] | V |
| INS\_INSP\_BATT\_SOC | 7007 | housekeeping | 0.1 \[Hz\] | 1 |
| INS\_INSP\_T\_01 | 7008 | engineering | 0.1 \[Hz\] | K |
| INS\_INSP\_T\_02 | 7009 | engineering | 0.1 \[Hz\] | K |
| INS\_INSP\_T\_03 | 7010 | engineering | 0.1 \[Hz\] | K |
| INS\_INSP\_T\_04 | 7011 | engineering | 0.1 \[Hz\] | K |
| INS\_INSP\_T\_05 | 7012 | engineering | 0.1 \[Hz\] | K |
| INS\_INSP\_T\_06 | 7013 | engineering | 0.1 \[Hz\] | K |
| INS\_INSP\_T\_07 | 7014 | engineering | 0.1 \[Hz\] | K |
| INS\_INSP\_T\_08 | 7015 | engineering | 0.1 \[Hz\] | K |
| INS\_IMAGE\_COUNT | 7016 | engineering | 0.1 \[Hz\] | 1 |
| INS\_IMAGE\_QUEUE | 7017 | engineering | 0.1 \[Hz\] | 1 |
| INS\_SEGMENTS\_RX | 7018 | engineering | 1 \[Hz\] | 1 |
| INS\_SEGMENT\_ERRORS | 7019 | engineering | 1 \[Hz\] | 1 |
| INS\_RELAY\_MARGIN | 7020 | housekeeping | 1 \[Hz\] | 1 |
| INS\_CAM\_T\_01 | 7021 | engineering | 0.1 \[Hz\] | K |
| INS\_CAM\_T\_02 | 7022 | engineering | 0.1 \[Hz\] | K |
| INS\_CAM\_STATE\_01 | 7023 | engineering | 1 \[Hz\] | 1 |
| INS\_CAM\_STATE\_02 | 7024 | engineering | 1 \[Hz\] | 1 |
| INS\_INSP\_PROPELLANT | 7025 | housekeeping | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_01 | 7026 | engineering | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_02 | 7027 | engineering | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_03 | 7028 | engineering | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_04 | 7029 | engineering | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_05 | 7030 | engineering | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_06 | 7031 | engineering | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_07 | 7032 | engineering | 0.1 \[Hz\] | 1 |
| INS\_INSP\_THR\_PULSES\_08 | 7033 | engineering | 0.1 \[Hz\] | 1 |
| INS\_RELEASE\_MECH\_STATE | 7034 | housekeeping | 1 \[Hz\] | 1 |
| INS\_RELEASE\_ARMED | 7035 | housekeeping | 1 \[Hz\] | 1 |
| INS\_LAST\_CONTACT\_AGE | 7036 | housekeeping | 0.1 \[Hz\] | s |
| INS\_IMAGE\_COMPRESSION | 7037 | engineering | 0.1 \[Hz\] | 1 |

*Events (the fault-relevant ones are the fault-protection interface)*

| mnemonic | eventId | severity | fdirRelevant | text |
| --- | --- | --- | --- | --- |
| INS\_EVT\_STARTED | 701 | info | false | application started |
| INS\_EVT\_STOPPED | 702 | warning | false | application stopped |
| INS\_EVT\_CMD\_ACCEPTED | 703 | info | false | command accepted |
| INS\_EVT\_CMD\_REJECTED | 704 | warning | false | command rejected |
| INS\_EVT\_TABLE\_LOADED | 705 | info | false | parameter table loaded |
| INS\_EVT\_TABLE\_INVALID | 706 | fault | true | parameter table failed validation |
| INS\_EVT\_WATCHDOG\_MISSED | 707 | fault | true | application missed its watchdog window |
| INS\_EVT\_MODE\_CHANGE\_SEEN | 708 | info | false | application applied a mode change |
| INS\_EVT\_RELEASE\_ARMED | 709 | warning | false | inspector release armed |
| INS\_EVT\_RELEASED | 710 | critical | true | inspector released |
| INS\_EVT\_IMAGE\_RECEIVED | 711 | info | false | inspector image complete |
| INS\_EVT\_SEGMENT\_LOST | 712 | warning | false | image segment lost |
| INS\_EVT\_INSPECTOR\_SAFE | 713 | fault | true | inspector reported safe mode |
| INS\_EVT\_INSPECTOR\_RETIRED | 714 | critical | true | inspector retired |
| INS\_EVT\_CONTACT\_LOST | 715 | fault | true | inspector contact overdue |

*Packets*

| mnemonic | apid | apidClass | rate | lengthOctets | layoutConsistent |
| --- | --- | --- | --- | --- | --- |
| INS\_HK\_01 | 320 | imaging | 1 \[Hz\] | 43 | true |
| INS\_ENG\_01 | 321 | imaging | 1 \[Hz\] | 82 | true |
| INS\_ENG\_02 | 322 | imaging | 0.1 \[Hz\] | 13 | true |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| inspectorHandling | inspectorHandlingApplication | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| inspectorHandling | levelC | Inspector release and relay. |

One volume per application of the Argent flight software, in the order of TethysFlightSoftware::ArgentFlightSoftware. Every table is a query over TethysFlightSoftware, TethysFlightBehaviour, TethysFlightTiming, TethysFlightDictionary, TethysSoftwareRequirements and TethysSoftwareAssurance.
