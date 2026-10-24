# Autonomy and sequencing application design description

## Purpose

*Application definition*

| name | type | documentation |
| --- | --- | --- |
| AutonomyApplication |  | The autonomy and sequencing engine: runs the on-board sequences the ground<br>loads as tables and the autonomous abort-to-hold-point sequence. |

*Behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| AutonomySoftware |  | The autonomy application running the sequencing engine. |

## Ports

*Ports of the application*

| name | type | documentation |
| --- | --- | --- |
| sequences | TethysFlightSoftware::TablePort |  |

*Ports added by the behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| command | TethysModes::CommandPort |  |

## State machine

*Exhibited state machines*

| name | type | documentation |
| --- | --- | --- |

## Parameter table

*Parameters: id, value, range, unit*

| parameterId | value | minimum | maximum | unitSymbol | inRange |
| --- | --- | --- | --- | --- | --- |
| 33 | 86400 | 3600 | 604800 | s | true |
| 34 | 1 | 0 | 3 | 1 | true |
| 35 | 600 | 0 | 86400 | s | true |
| 36 | 60 | 1 | 3600 | s | true |

## Rate, worst-case execution time and deadline

*Scheduled task*

| name | period | wcet | deadline | utilisation | activeModes |
| --- | --- | --- | --- | --- | --- |
| autonomyTask | 0.125 \[s\] | 0.01 \[s\] | 0.125 \[s\] | 0.08 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |

## Commands, telemetry, events and packets owned

*Commands*

| mnemonic | opcodeNumber | criticality | hazardous | documentation |
| --- | --- | --- | --- | --- |
| AUT\_LOAD\_SEQUENCE | 2305 | routine | false | Load a command sequence into an engine. |
| AUT\_START\_SEQUENCE | 2306 | critical | false | Start the sequence loaded in an engine. |
| AUT\_STOP\_SEQUENCE | 2307 | critical | false | Stop and unload the sequence in an engine. |
| AUT\_PAUSE\_SEQUENCE | 2308 | routine | false | Pause the sequence in an engine. |
| AUT\_RESUME\_SEQUENCE | 2309 | routine | false | Resume a paused sequence. |
| AUT\_SET\_SEQUENCE\_PARAMETER | 2310 | routine | false | Set a sequence parameter by index. |
| AUT\_ENABLE\_AUTONOMY | 2311 | critical | false | Enable on-board autonomy at the given level. |
| AUT\_DISABLE\_AUTONOMY | 2312 | critical | false | Disable on-board autonomy; sequences run but rules do not fire. |
| AUT\_SET\_RULE\_ENABLE | 2313 | critical | false | Enable or disable an autonomy rule. |
| AUT\_CLEAR\_RULE\_HISTORY | 2314 | routine | false | Clear the rule firing history. |
| AUT\_SET\_WAYPOINT | 2315 | critical | false | Add a proximity-operations waypoint. |
| AUT\_CLEAR\_WAYPOINTS | 2316 | critical | false | Clear the waypoint list. |
| AUT\_SET\_PLAN\_HORIZON | 2317 | routine | false | Set the planning horizon of the autonomy executive. |
| AUT\_ENGINE\_ENABLE\_1 | 2318 | routine | false | Enable sequence engine 1. |
| AUT\_ENGINE\_DISABLE\_1 | 2319 | routine | false | Disable sequence engine 1. |
| AUT\_ENGINE\_ENABLE\_2 | 2320 | routine | false | Enable sequence engine 2. |
| AUT\_ENGINE\_DISABLE\_2 | 2321 | routine | false | Disable sequence engine 2. |
| AUT\_ENGINE\_ENABLE\_3 | 2322 | routine | false | Enable sequence engine 3. |
| AUT\_ENGINE\_DISABLE\_3 | 2323 | routine | false | Disable sequence engine 3. |
| AUT\_ENGINE\_ENABLE\_4 | 2324 | routine | false | Enable sequence engine 4. |
| AUT\_ENGINE\_DISABLE\_4 | 2325 | routine | false | Disable sequence engine 4. |

*Telemetry points*

| mnemonic | pointId | kind | rate | unitSymbol |
| --- | --- | --- | --- | --- |
| AUT\_SEQ\_STATE\_01 | 9001 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_STATE\_02 | 9002 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_STATE\_03 | 9003 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_STATE\_04 | 9004 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_STEP\_01 | 9005 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_STEP\_02 | 9006 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_STEP\_03 | 9007 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_STEP\_04 | 9008 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_ID\_01 | 9009 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_ID\_02 | 9010 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_ID\_03 | 9011 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_ID\_04 | 9012 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_SEQ\_TIME\_TO\_NEXT\_01 | 9013 | engineering | 1 \[Hz\] | s |
| AUT\_SEQ\_TIME\_TO\_NEXT\_02 | 9014 | engineering | 1 \[Hz\] | s |
| AUT\_SEQ\_TIME\_TO\_NEXT\_03 | 9015 | engineering | 1 \[Hz\] | s |
| AUT\_SEQ\_TIME\_TO\_NEXT\_04 | 9016 | engineering | 1 \[Hz\] | s |
| AUT\_RULE\_FIRED\_COUNT\_01 | 9017 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_02 | 9018 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_03 | 9019 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_04 | 9020 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_05 | 9021 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_06 | 9022 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_07 | 9023 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_08 | 9024 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_09 | 9025 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_10 | 9026 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_11 | 9027 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_12 | 9028 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_13 | 9029 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_14 | 9030 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_15 | 9031 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_FIRED\_COUNT\_16 | 9032 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_01 | 9033 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_02 | 9034 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_03 | 9035 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_04 | 9036 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_05 | 9037 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_06 | 9038 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_07 | 9039 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_08 | 9040 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_09 | 9041 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_10 | 9042 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_11 | 9043 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_12 | 9044 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_13 | 9045 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_14 | 9046 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_15 | 9047 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_RULE\_ENABLED\_16 | 9048 | engineering | 0.1 \[Hz\] | 1 |
| AUT\_WAYPOINT\_INDEX | 9049 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_WAYPOINT\_RANGE | 9050 | housekeeping | 1 \[Hz\] | m |
| AUT\_AUTONOMY\_LEVEL | 9051 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_PLAN\_HORIZON | 9052 | engineering | 0.1 \[Hz\] | s |
| AUT\_ENGINE\_ENABLED\_01 | 9053 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_ENGINE\_ENABLED\_02 | 9054 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_ENGINE\_ENABLED\_03 | 9055 | housekeeping | 1 \[Hz\] | 1 |
| AUT\_ENGINE\_ENABLED\_04 | 9056 | housekeeping | 1 \[Hz\] | 1 |

*Events (the fault-relevant ones are the fault-protection interface)*

| mnemonic | eventId | severity | fdirRelevant | text |
| --- | --- | --- | --- | --- |
| AUT\_EVT\_STARTED | 901 | info | false | application started |
| AUT\_EVT\_STOPPED | 902 | warning | false | application stopped |
| AUT\_EVT\_CMD\_ACCEPTED | 903 | info | false | command accepted |
| AUT\_EVT\_CMD\_REJECTED | 904 | warning | false | command rejected |
| AUT\_EVT\_TABLE\_LOADED | 905 | info | false | parameter table loaded |
| AUT\_EVT\_TABLE\_INVALID | 906 | fault | true | parameter table failed validation |
| AUT\_EVT\_WATCHDOG\_MISSED | 907 | fault | true | application missed its watchdog window |
| AUT\_EVT\_MODE\_CHANGE\_SEEN | 908 | info | false | application applied a mode change |
| AUT\_EVT\_SEQUENCE\_STARTED | 909 | info | false | sequence started |
| AUT\_EVT\_SEQUENCE\_COMPLETE | 910 | info | false | sequence complete |
| AUT\_EVT\_SEQUENCE\_FAILED | 911 | fault | true | sequence step failed |
| AUT\_EVT\_RULE\_FIRED | 912 | warning | false | autonomy rule fired |
| AUT\_EVT\_WAYPOINT\_REACHED | 913 | info | false | waypoint reached |
| AUT\_EVT\_PLAN\_INFEASIBLE | 914 | fault | true | plan infeasible within horizon |

*Packets*

| mnemonic | apid | apidClass | rate | lengthOctets | layoutConsistent |
| --- | --- | --- | --- | --- | --- |
| AUT\_HK\_01 | 68 | guidance | 1 \[Hz\] | 61 | true |
| AUT\_ENG\_01 | 69 | guidance | 1 \[Hz\] | 96 | true |
| AUT\_ENG\_02 | 70 | guidance | 0.1 \[Hz\] | 28 | true |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| autonomy | sequencingEngine, autonomyApplication | 2 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| autonomy | levelA | The sequencing engine and the autonomous capture abort. |

One volume per application of the Argent flight software, in the order of TethysFlightSoftware::ArgentFlightSoftware. Every table is a query over TethysFlightSoftware, TethysFlightBehaviour, TethysFlightTiming, TethysFlightDictionary, TethysSoftwareRequirements and TethysSoftwareAssurance.
