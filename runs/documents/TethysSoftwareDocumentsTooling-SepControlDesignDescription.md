# Electric propulsion control application design description

## Purpose

*Application definition*

| name | type | documentation |
| --- | --- | --- |
| SepControlApplication |  | Solar electric propulsion control: thruster start, throttle and stop, power<br>processing unit management and the thrust-arc sequence. |

*Behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| SepControlSoftware |  | The propulsion application exhibiting the SEP string controller. |

## Ports

*Ports of the application*

| name | type | documentation |
| --- | --- | --- |
| thrusters | TethysInterfaces::DataBusPort |  |

*Ports added by the behavioural specialisation*

| name | type | documentation |
| --- | --- | --- |
| command | TethysModes::CommandPort |  |

## State machine

*Exhibited state machines*

| name | type | documentation |
| --- | --- | --- |
| controller | TethysFlightBehaviour::SepStringController |  |

*States*

| name | type | documentation |
| --- | --- | --- |
| off |  |  |
| standby |  |  |
| thrusting |  |  |
| disposalBurn |  |  |
| restarting |  |  |
| restartingDisposal |  | The restart delay after a flameout during the disposal burn; the burn<br>resumes for its full duration, so it stays bounded. |

## Parameter table

*Parameters: id, value, range, unit*

| parameterId | value | minimum | maximum | unitSymbol | inRange |
| --- | --- | --- | --- | --- | --- |
| 9 | 0.2 | 0.1 | 0.5 | 1 | true |
| 10 | 7200 | 60 | 86400 | s | true |
| 11 | 32 | 5 | 40 | A | true |
| 12 | 293 | 273 | 323 | K | true |

## Rate, worst-case execution time and deadline

*Scheduled task*

| name | period | wcet | deadline | utilisation | activeModes |
| --- | --- | --- | --- | --- | --- |
| sepControlTask | 0.125 \[s\] | 0.005 \[s\] | 0.125 \[s\] | 0.04 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |

## Commands, telemetry, events and packets owned

*Commands*

| mnemonic | opcodeNumber | criticality | hazardous | documentation |
| --- | --- | --- | --- | --- |
| SEP\_START\_THRUST\_ARC | 769 | critical | true | Begin a thrust arc of the given duration at the given throttle. |
| SEP\_STOP\_THRUST | 770 | critical | false | Stop thrusting immediately and close the flow. |
| SEP\_SET\_THROTTLE | 771 | critical | false | Change the throttle of a running arc. |
| SEP\_SELECT\_THRUSTER | 772 | critical | false | Select the thruster the next arc fires. |
| SEP\_PRIME\_FEED | 773 | critical | true | Open the feed system and bring the regulator to pressure. |
| SEP\_VENT\_FEED | 774 | critical | true | Vent the feed lines downstream of the latch valves. |
| SEP\_SET\_FLOW\_RATE | 775 | critical | false | Set the anode flow set point. |
| SEP\_THRUSTER\_RESTART | 776 | critical | true | Attempt a restart after a flameout, after the restart delay. |
| SEP\_OPEN\_LATCH\_VALVE | 777 | critical | true | Open a latch valve. |
| SEP\_CLOSE\_LATCH\_VALVE | 778 | critical | false | Close a latch valve. |
| SEP\_GIMBAL\_SET | 779 | critical | false | Point a thruster gimbal. |
| SEP\_GIMBAL\_HOME | 780 | routine | false | Drive a thruster gimbal to its mechanical home. |
| SEP\_SET\_DISCHARGE\_LIMIT | 781 | critical | false | Set the discharge current trip limit for the power processing units. |
| SEP\_TANK\_HEATER\_SETPOINT | 782 | routine | false | Set the xenon tank heater set point. |
| SEP\_PPU\_ON\_1 | 783 | critical | true | Power on power processing unit 1. |
| SEP\_PPU\_OFF\_1 | 784 | critical | false | Power off power processing unit 1. |
| SEP\_PPU\_ON\_2 | 785 | critical | true | Power on power processing unit 2. |
| SEP\_PPU\_OFF\_2 | 786 | critical | false | Power off power processing unit 2. |
| SEP\_PPU\_ON\_3 | 787 | critical | true | Power on power processing unit 3. |
| SEP\_PPU\_OFF\_3 | 788 | critical | false | Power off power processing unit 3. |
| SEP\_CATHODE\_HEATER\_ON\_1 | 789 | routine | false | Enable the cathode heater of thruster 1. |
| SEP\_CATHODE\_HEATER\_OFF\_1 | 790 | routine | false | Disable the cathode heater of thruster 1. |
| SEP\_CATHODE\_HEATER\_ON\_2 | 791 | routine | false | Enable the cathode heater of thruster 2. |
| SEP\_CATHODE\_HEATER\_OFF\_2 | 792 | routine | false | Disable the cathode heater of thruster 2. |
| SEP\_CATHODE\_HEATER\_ON\_3 | 793 | routine | false | Enable the cathode heater of thruster 3. |
| SEP\_CATHODE\_HEATER\_OFF\_3 | 794 | routine | false | Disable the cathode heater of thruster 3. |

*Telemetry points*

| mnemonic | pointId | kind | rate | unitSymbol |
| --- | --- | --- | --- | --- |
| SEP\_DISCHARGE\_I\_01 | 3001 | housekeeping | 1 \[Hz\] | A |
| SEP\_DISCHARGE\_I\_02 | 3002 | housekeeping | 1 \[Hz\] | A |
| SEP\_DISCHARGE\_I\_03 | 3003 | housekeeping | 1 \[Hz\] | A |
| SEP\_DISCHARGE\_V\_01 | 3004 | housekeeping | 1 \[Hz\] | V |
| SEP\_DISCHARGE\_V\_02 | 3005 | housekeeping | 1 \[Hz\] | V |
| SEP\_DISCHARGE\_V\_03 | 3006 | housekeeping | 1 \[Hz\] | V |
| SEP\_ANODE\_FLOW\_01 | 3007 | engineering | 1 \[Hz\] | 1 |
| SEP\_ANODE\_FLOW\_02 | 3008 | engineering | 1 \[Hz\] | 1 |
| SEP\_ANODE\_FLOW\_03 | 3009 | engineering | 1 \[Hz\] | 1 |
| SEP\_CATHODE\_FLOW\_01 | 3010 | engineering | 1 \[Hz\] | 1 |
| SEP\_CATHODE\_FLOW\_02 | 3011 | engineering | 1 \[Hz\] | 1 |
| SEP\_CATHODE\_FLOW\_03 | 3012 | engineering | 1 \[Hz\] | 1 |
| SEP\_KEEPER\_I\_01 | 3013 | engineering | 1 \[Hz\] | A |
| SEP\_KEEPER\_I\_02 | 3014 | engineering | 1 \[Hz\] | A |
| SEP\_KEEPER\_I\_03 | 3015 | engineering | 1 \[Hz\] | A |
| SEP\_MAGNET\_I\_01 | 3016 | engineering | 1 \[Hz\] | A |
| SEP\_MAGNET\_I\_02 | 3017 | engineering | 1 \[Hz\] | A |
| SEP\_MAGNET\_I\_03 | 3018 | engineering | 1 \[Hz\] | A |
| SEP\_CATHODE\_HTR\_I\_01 | 3019 | engineering | 1 \[Hz\] | A |
| SEP\_CATHODE\_HTR\_I\_02 | 3020 | engineering | 1 \[Hz\] | A |
| SEP\_CATHODE\_HTR\_I\_03 | 3021 | engineering | 1 \[Hz\] | A |
| SEP\_THRUSTER\_T\_01 | 3022 | engineering | 0.1 \[Hz\] | K |
| SEP\_THRUSTER\_T\_02 | 3023 | engineering | 0.1 \[Hz\] | K |
| SEP\_THRUSTER\_T\_03 | 3024 | engineering | 0.1 \[Hz\] | K |
| SEP\_PPU\_IN\_POWER\_01 | 3025 | housekeeping | 1 \[Hz\] | W |
| SEP\_PPU\_IN\_POWER\_02 | 3026 | housekeeping | 1 \[Hz\] | W |
| SEP\_PPU\_IN\_POWER\_03 | 3027 | housekeeping | 1 \[Hz\] | W |
| SEP\_PPU\_T\_01 | 3028 | engineering | 0.1 \[Hz\] | K |
| SEP\_PPU\_T\_02 | 3029 | engineering | 0.1 \[Hz\] | K |
| SEP\_PPU\_T\_03 | 3030 | engineering | 0.1 \[Hz\] | K |
| SEP\_PPU\_STATUS\_01 | 3031 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_PPU\_STATUS\_02 | 3032 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_PPU\_STATUS\_03 | 3033 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_PPU\_EFFICIENCY\_01 | 3034 | engineering | 0.1 \[Hz\] | 1 |
| SEP\_PPU\_EFFICIENCY\_02 | 3035 | engineering | 0.1 \[Hz\] | 1 |
| SEP\_PPU\_EFFICIENCY\_03 | 3036 | engineering | 0.1 \[Hz\] | 1 |
| SEP\_TANK\_P\_01 | 3037 | housekeeping | 0.1 \[Hz\] | Pa |
| SEP\_TANK\_P\_02 | 3038 | housekeeping | 0.1 \[Hz\] | Pa |
| SEP\_TANK\_T\_01 | 3039 | housekeeping | 0.1 \[Hz\] | K |
| SEP\_TANK\_T\_02 | 3040 | housekeeping | 0.1 \[Hz\] | K |
| SEP\_XENON\_REMAINING | 3041 | housekeeping | 0.01 \[Hz\] | kg |
| SEP\_FLOW\_TOTAL | 3042 | engineering | 0.01 \[Hz\] | kg |
| SEP\_REG\_P\_01 | 3043 | housekeeping | 1 \[Hz\] | Pa |
| SEP\_REG\_P\_02 | 3044 | housekeeping | 1 \[Hz\] | Pa |
| SEP\_LATCH\_VALVE\_01 | 3045 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_LATCH\_VALVE\_02 | 3046 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_LATCH\_VALVE\_03 | 3047 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_LATCH\_VALVE\_04 | 3048 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_LATCH\_VALVE\_05 | 3049 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_LATCH\_VALVE\_06 | 3050 | housekeeping | 1 \[Hz\] | 1 |
| SEP\_GIMBAL\_ANGLE\_01 | 3051 | engineering | 1 \[Hz\] | rad |
| SEP\_GIMBAL\_ANGLE\_02 | 3052 | engineering | 1 \[Hz\] | rad |
| SEP\_GIMBAL\_ANGLE\_03 | 3053 | engineering | 1 \[Hz\] | rad |
| SEP\_GIMBAL\_ANGLE\_04 | 3054 | engineering | 1 \[Hz\] | rad |
| SEP\_GIMBAL\_ANGLE\_05 | 3055 | engineering | 1 \[Hz\] | rad |
| SEP\_GIMBAL\_ANGLE\_06 | 3056 | engineering | 1 \[Hz\] | rad |
| SEP\_THRUST\_EST | 3057 | housekeeping | 1 \[Hz\] | N |
| SEP\_ISP\_EST | 3058 | engineering | 0.1 \[Hz\] | s |
| SEP\_ARC\_ELAPSED | 3059 | housekeeping | 1 \[Hz\] | s |
| SEP\_ARC\_REMAINING | 3060 | housekeeping | 1 \[Hz\] | s |

*Events (the fault-relevant ones are the fault-protection interface)*

| mnemonic | eventId | severity | fdirRelevant | text |
| --- | --- | --- | --- | --- |
| SEP\_EVT\_STARTED | 301 | info | false | application started |
| SEP\_EVT\_STOPPED | 302 | warning | false | application stopped |
| SEP\_EVT\_CMD\_ACCEPTED | 303 | info | false | command accepted |
| SEP\_EVT\_CMD\_REJECTED | 304 | warning | false | command rejected |
| SEP\_EVT\_TABLE\_LOADED | 305 | info | false | parameter table loaded |
| SEP\_EVT\_TABLE\_INVALID | 306 | fault | true | parameter table failed validation |
| SEP\_EVT\_WATCHDOG\_MISSED | 307 | fault | true | application missed its watchdog window |
| SEP\_EVT\_MODE\_CHANGE\_SEEN | 308 | info | false | application applied a mode change |
| SEP\_EVT\_ARC\_STARTED | 309 | info | false | thrust arc started |
| SEP\_EVT\_ARC\_COMPLETE | 310 | info | false | thrust arc complete |
| SEP\_EVT\_FLAMEOUT | 311 | fault | true | thruster flameout |
| SEP\_EVT\_RESTART\_OK | 312 | info | false | thruster restarted |
| SEP\_EVT\_RESTART\_FAILED | 313 | critical | true | thruster restart failed; switchover requested |
| SEP\_EVT\_TANK\_LOW | 314 | warning | false | xenon below reserve |
| SEP\_EVT\_PPU\_OVERCURRENT | 315 | fault | true | power processing unit over-current trip |
| SEP\_EVT\_GIMBAL\_STALL | 316 | fault | true | gimbal stalled |

*Packets*

| mnemonic | apid | apidClass | rate | lengthOctets | layoutConsistent |
| --- | --- | --- | --- | --- | --- |
| SEP\_HK\_01 | 128 | propulsion | 1 \[Hz\] | 54 | true |
| SEP\_HK\_02 | 129 | propulsion | 1 \[Hz\] | 23 | true |
| SEP\_ENG\_01 | 130 | propulsion | 1 \[Hz\] | 60 | true |
| SEP\_ENG\_02 | 131 | propulsion | 1 \[Hz\] | 44 | true |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| sepControl | sepControlApplication | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| sepControl | levelA | Solar-electric propulsion control: thrust arcs, PPU high voltage. |

One volume per application of the Argent flight software, in the order of TethysFlightSoftware::ArgentFlightSoftware. Every table is a query over TethysFlightSoftware, TethysFlightBehaviour, TethysFlightTiming, TethysFlightDictionary, TethysSoftwareRequirements and TethysSoftwareAssurance.
