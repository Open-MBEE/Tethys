# Telecom application design description

## Purpose

*Application definition*

| name | type | documentation |
| --- | --- | --- |
| TelecomApplication |  | Telecommunications: transponder configuration, rate and band selection and the<br>frame layer under the space-ground packet interface, whose flight side is this<br>application's space link port. |

*Behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| TelecomSoftware |  | The telecom application exhibiting the antenna and rate manager. |

## Ports

*Ports of the application*

| name | type | documentation |
| --- | --- | --- |
| transponder | TethysInterfaces::DataBusPort |  |
| spaceLink | TethysIcds::PacketPort |  |

*Ports added by the behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| command | TethysModes::CommandPort |  |

## State machine

*Exhibited state machines*

| name | type | documentation |
| --- | --- | --- |
| manager | TethysFlightBehaviour::TelecomManager |  |

*States*

| name | type | documentation |
| --- | --- | --- |
| safeRate |  |  |
| highGainIdle |  |  |
| pass |  |  |
| relaying |  |  |

## Parameter table

*Parameters: id, value, range, unit*

| parameterId | value | minimum | maximum | unitSymbol | inRange |
| --- | --- | --- | --- | --- | --- |
| 21 | 2e+06 | 10 | 4e+06 | Hz | true |
| 22 | 2000 | 7.8125 | 4000 | Hz | true |
| 23 | 0.005 | 0.0001 | 0.02 | rad/s | true |
| 24 | 60 | 5 | 100 | W | true |

## Rate, worst-case execution time and deadline

*Scheduled task*

| name | period | wcet | deadline | utilisation | activeModes |
| --- | --- | --- | --- | --- | --- |
| telecomTask | 0.125 \[s\] | 0.005 \[s\] | 0.125 \[s\] | 0.04 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |

## Commands, telemetry, events and packets owned

*Commands*

| mnemonic | opcodeNumber | criticality | hazardous | documentation |
| --- | --- | --- | --- | --- |
| COM\_TRANSMITTER\_ON | 1537 | critical | true | Enable the transmitter on the selected transponder. |
| COM\_TRANSMITTER\_OFF | 1538 | critical | false | Disable the transmitter. |
| COM\_SELECT\_TRANSPONDER | 1539 | critical | false | Select the prime transponder. |
| COM\_SELECT\_ANTENNA | 1540 | critical | false | Route the transmitter to the high-gain or a low-gain antenna. |
| COM\_SET\_DOWNLINK\_RATE | 1541 | routine | false | Set the downlink symbol rate. |
| COM\_SET\_UPLINK\_RATE | 1542 | routine | false | Set the expected uplink bit rate. |
| COM\_RANGING\_ON | 1543 | routine | false | Enable the ranging channel turn-around. |
| COM\_RANGING\_OFF | 1544 | routine | false | Disable the ranging channel turn-around. |
| COM\_HGA\_POINT | 1545 | critical | false | Point the high-gain antenna. |
| COM\_HGA\_TRACK\_EARTH | 1546 | routine | false | Return the high-gain antenna to Earth tracking. |
| COM\_HGA\_STOW | 1547 | critical | false | Stow the high-gain antenna. |
| COM\_SET\_PASS\_WINDOW | 1548 | routine | false | Load the next ground pass window. |
| COM\_SET\_CODING | 1549 | routine | false | Select the downlink coding: convolutional, Reed–Solomon, turbo or LDPC. |
| COM\_SET\_TRANSMIT\_POWER | 1550 | critical | false | Set the transmitter output power. |
| COM\_DOWNLINK\_RATE\_PRESET\_1 | 1551 | routine | false | Select downlink rate preset 1 of the link table. |
| COM\_DOWNLINK\_RATE\_PRESET\_2 | 1552 | routine | false | Select downlink rate preset 2 of the link table. |
| COM\_DOWNLINK\_RATE\_PRESET\_3 | 1553 | routine | false | Select downlink rate preset 3 of the link table. |
| COM\_DOWNLINK\_RATE\_PRESET\_4 | 1554 | routine | false | Select downlink rate preset 4 of the link table. |
| COM\_DOWNLINK\_RATE\_PRESET\_5 | 1555 | routine | false | Select downlink rate preset 5 of the link table. |
| COM\_DOWNLINK\_RATE\_PRESET\_6 | 1556 | routine | false | Select downlink rate preset 6 of the link table. |

*Telemetry points*

| mnemonic | pointId | kind | rate | unitSymbol |
| --- | --- | --- | --- | --- |
| COM\_TX\_POWER\_01 | 6001 | housekeeping | 1 \[Hz\] | W |
| COM\_TX\_POWER\_02 | 6002 | housekeeping | 1 \[Hz\] | W |
| COM\_RX\_AGC\_01 | 6003 | housekeeping | 1 \[Hz\] | 1 |
| COM\_RX\_AGC\_02 | 6004 | housekeeping | 1 \[Hz\] | 1 |
| COM\_RX\_LOCK\_01 | 6005 | housekeeping | 1 \[Hz\] | 1 |
| COM\_RX\_LOCK\_02 | 6006 | housekeeping | 1 \[Hz\] | 1 |
| COM\_CARRIER\_LOCK | 6007 | housekeeping | 1 \[Hz\] | 1 |
| COM\_SYMBOL\_RATE | 6008 | housekeeping | 0.1 \[Hz\] | 1 |
| COM\_UPLINK\_RATE | 6009 | engineering | 0.1 \[Hz\] | 1 |
| COM\_FRAME\_COUNT | 6010 | engineering | 1 \[Hz\] | 1 |
| COM\_FRAME\_ERRORS | 6011 | engineering | 1 \[Hz\] | 1 |
| COM\_SSPA\_T\_01 | 6012 | housekeeping | 0.1 \[Hz\] | K |
| COM\_SSPA\_T\_02 | 6013 | housekeeping | 0.1 \[Hz\] | K |
| COM\_SSPA\_I\_01 | 6014 | engineering | 1 \[Hz\] | A |
| COM\_SSPA\_I\_02 | 6015 | engineering | 1 \[Hz\] | A |
| COM\_HGA\_AZ | 6016 | housekeeping | 1 \[Hz\] | rad |
| COM\_HGA\_EL | 6017 | housekeeping | 1 \[Hz\] | rad |
| COM\_ANTENNA\_SEL | 6018 | housekeeping | 1 \[Hz\] | 1 |
| COM\_RANGING\_STATE | 6019 | housekeeping | 1 \[Hz\] | 1 |
| COM\_DOPPLER | 6020 | engineering | 1 \[Hz\] | 1 |
| COM\_TWO\_WAY\_RANGE | 6021 | engineering | 0.1 \[Hz\] | m |
| COM\_LINK\_MARGIN | 6022 | housekeeping | 1 \[Hz\] | 1 |
| COM\_PASS\_REMAINING | 6023 | engineering | 1 \[Hz\] | s |
| COM\_EXCITER\_T\_01 | 6024 | engineering | 0.1 \[Hz\] | K |
| COM\_EXCITER\_T\_02 | 6025 | engineering | 0.1 \[Hz\] | K |
| COM\_XPDR\_STATE\_01 | 6026 | housekeeping | 1 \[Hz\] | 1 |
| COM\_XPDR\_STATE\_02 | 6027 | housekeeping | 1 \[Hz\] | 1 |
| COM\_HGA\_T\_01 | 6028 | engineering | 0.1 \[Hz\] | K |
| COM\_HGA\_T\_02 | 6029 | engineering | 0.1 \[Hz\] | K |
| COM\_RELAY\_RX\_LOCK | 6030 | housekeeping | 1 \[Hz\] | 1 |
| COM\_RELAY\_RATE | 6031 | engineering | 0.1 \[Hz\] | 1 |
| COM\_RELAY\_FRAME\_COUNT | 6032 | engineering | 1 \[Hz\] | 1 |
| COM\_RELAY\_LINK\_MARGIN | 6033 | housekeeping | 1 \[Hz\] | 1 |
| COM\_CODING\_SEL | 6034 | engineering | 0.1 \[Hz\] | 1 |
| COM\_HGA\_MOTOR\_I\_01 | 6035 | engineering | 1 \[Hz\] | A |
| COM\_HGA\_MOTOR\_I\_02 | 6036 | engineering | 1 \[Hz\] | A |

*Events (the fault-relevant ones are the fault-protection interface)*

| mnemonic | eventId | severity | fdirRelevant | text |
| --- | --- | --- | --- | --- |
| COM\_EVT\_STARTED | 601 | info | false | application started |
| COM\_EVT\_STOPPED | 602 | warning | false | application stopped |
| COM\_EVT\_CMD\_ACCEPTED | 603 | info | false | command accepted |
| COM\_EVT\_CMD\_REJECTED | 604 | warning | false | command rejected |
| COM\_EVT\_TABLE\_LOADED | 605 | info | false | parameter table loaded |
| COM\_EVT\_TABLE\_INVALID | 606 | fault | true | parameter table failed validation |
| COM\_EVT\_WATCHDOG\_MISSED | 607 | fault | true | application missed its watchdog window |
| COM\_EVT\_MODE\_CHANGE\_SEEN | 608 | info | false | application applied a mode change |
| COM\_EVT\_CARRIER\_ACQUIRED | 609 | info | false | uplink carrier acquired |
| COM\_EVT\_CARRIER\_LOST | 610 | warning | false | uplink carrier lost |
| COM\_EVT\_PASS\_START | 611 | info | false | ground pass started |
| COM\_EVT\_PASS\_END | 612 | info | false | ground pass ended |
| COM\_EVT\_TX\_OVERTEMP | 613 | fault | true | transmitter over temperature |
| COM\_EVT\_HGA\_POINTING\_ERROR | 614 | warning | false | high-gain pointing error |
| COM\_EVT\_RELAY\_ACQUIRED | 615 | info | false | relay link acquired |
| COM\_EVT\_RELAY\_LOST | 616 | warning | false | relay link lost |

*Packets*

| mnemonic | apid | apidClass | rate | lengthOctets | layoutConsistent |
| --- | --- | --- | --- | --- | --- |
| COM\_HK\_01 | 256 | relay | 1 \[Hz\] | 48 | true |
| COM\_ENG\_01 | 257 | relay | 1 \[Hz\] | 59 | true |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| telecom | telemetryRatesByMode, telecomApplication | 2 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| telecom | levelB | The space link. |

One volume per application of the Argent flight software, in the order of TethysFlightSoftware::ArgentFlightSoftware. Every table is a query over TethysFlightSoftware, TethysFlightBehaviour, TethysFlightTiming, TethysFlightDictionary, TethysSoftwareRequirements and TethysSoftwareAssurance.
