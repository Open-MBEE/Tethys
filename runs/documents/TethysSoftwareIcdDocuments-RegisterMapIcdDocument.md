# SCD-023 Remote interface unit register maps

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| a | TethysInterfaces::DataBusPort |
| b | TethysInterfaces::DataBusPort |

<a id="parameters"></a>

## Register access parameters

*Address and data widths, access frame and burst*

| name | type | valuation |
| --- | --- | --- |
| registerAddressWidth | ScalarValues::Natural | 8 |
| registerDataWidth | ScalarValues::Natural | 16 |
| registerCount | ScalarValues::Natural | 256 |
| accessFrameLength | ISQInformation::StorageCapacityValue | 14 \[B\] |
| burstLength | ScalarValues::Natural | 64 |

## Thermal and propulsion unit

*Registers of the thermal and propulsion remote interface unit*

| name | address | width | meaning | access |
| --- | --- | --- | --- | --- |
| status | 0 | 16 | unit status and fault flags | readOnly |
| control | 1 | 16 | unit control: reset, self-test, watchdog enable | readWrite |
| thermistorBank | 16 | 16 | first of 64 thermistor readings, one register each | readOnly |
| heaterEnable | 96 | 16 | heater enable bits, one per heater circuit | readWrite |
| heaterDuty | 97 | 16 | first of 16 heater duty-cycle settings | readWrite |
| valveCommand | 128 | 16 | latch-valve open and close pulses | writeOnly |
| valvePosition | 129 | 16 | latch-valve position indicators | readOnly |
| tankPressure | 130 | 16 | xenon tank pressure transducer reading | readOnly |

## Mechanism unit

*Registers of the mechanism remote interface unit*

| name | address | width | meaning | access |
| --- | --- | --- | --- | --- |
| status | 0 | 16 | unit status and fault flags | readOnly |
| control | 1 | 16 | unit control: reset, self-test, watchdog enable | readWrite |
| armMotorCommand | 32 | 16 | first of 4 capture-arm motor rate commands | readWrite |
| armPosition | 36 | 16 | first of 4 capture-arm resolver positions | readOnly |
| contactForce | 40 | 16 | first of 4 contact-pad force readings | readOnly |
| dispenserCommand | 64 | 16 | dispenser release and retention pulses | writeOnly |
| dockingRingCommand | 80 | 16 | docking ring extend, retract and latch | readWrite |
| dockingRingStatus | 81 | 16 | docking ring position and latch indicators | readOnly |
