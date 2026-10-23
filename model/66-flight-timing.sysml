// Tethys Retrieval — flight software timing, scheduling and resource budgets.
// Rate groups and the minor-frame schedule of the Kestrel executive, the worst-case execution
// time, period, deadline and jitter of every scheduled task, the end-to-end latency chains the
// fault-management requirements bound, the AABP-1 bus schedule and the processor, memory and bus
// budgets per partition and per flight mode. Figures are fictional engineering estimates.
package TethysFlightTiming {
    doc /* Timing and resource budgets of the Argent flight software: how the twelve
         * applications and the core services are placed on the executive's major and minor
         * frames, how long each activation may take, how long a fault or a command takes to
         * travel end to end, how the on-board data bus is scheduled, and whether the processor,
         * memory and bus close with the reserve the software margin policy demands. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::collect;
    private import ControlFunctions::forAll;
    private import QuantityCalculations::sum;
    private import TethysMarginPolicy::*;
    private import TethysTugStructure::TugMode;
    private import TethysTugStructure::allFlightModes;
    private import TethysBudgets::*;
    private import TethysFlightSoftware::*;

    // ---- 1. Vocabulary ---------------------------------------------------------------------
    part def RateGroup {
        doc /* A harmonic rate group of the executive: every task in it is released with the
             * same period, an integer divisor of the major frame. */
        attribute rate : FrequencyValue;
        attribute period : DurationValue;
        attribute activationsPerMajorFrame : Natural;
        assert constraint periodMatchesRate {
            doc /* Period and rate are the same figure. */
            period * (rate / (1 [Hz])) == 1.0 [s]
        }
    }

    part def FrameSlice {
        doc /* One slice of a minor frame handed to one partition: the executive runs the
             * partition's tasks in it and nothing else. */
        attribute duration : DurationValue;
    }

    part def ScheduledTask {
        doc /* A software component as the executive schedules it: in one partition, released
             * at the period of its rate group, with a worst-case execution time, a release
             * jitter and a deadline, and the minor frames of the major frame it fires in. */
        ref part component : SoftwareComponent;
        ref part rateGroup : RateGroup;
        attribute period : DurationValue = rateGroup.period;
        attribute wcet : DurationValue;
        attribute jitter : DurationValue default = 0.0 [s];
        attribute deadline : DurationValue default = rateGroup.period;
        attribute firingFrames : Natural[*] default = allMinorFrames;
        attribute activationsPerFiringFrame : Natural default = 1;
        attribute activeModes : TugMode[*] default = allFlightModes;
        attribute utilisation : Real = wcet / period;
        assert constraint deadlineWithinPeriod {
            doc /* A task must finish before it is released again. */
            deadline <= period
        }
        assert constraint responseWithinDeadline {
            doc /* Worst-case execution plus release jitter fits the deadline even without
                 * preemption by anything else in the slice. */
            wcet + jitter <= deadline
        }
    }

    part def ApplicationTask :> ScheduledTask {
        doc /* An application as scheduled: its rate group must run it at least at the rate the
             * application asks for. */
        ref part :>> component : Application;
        attribute :>> activeModes = component.activeModes;
        assert constraint hostedAtRequiredRate {
            doc /* The rate group is at least as fast as the application's required rate. */
            rateGroup.rate >= component.rate
        }
    }

    attribute allMinorFrames : Natural[*] = (0, 1, 2, 3, 4, 5, 6, 7) {
        doc /* The eight minor frames of the major frame, counted from zero. */
    }

    calc def TaskDemandInFrame {
        doc /* The execution time a task demands in one minor frame: its worst-case execution
             * time per activation times the activations it has in that frame. */
        in task : ScheduledTask;
        in frameIndex : Natural;
        return demand : DurationValue =
            if includes(task.firingFrames, frameIndex)
                ? task.wcet * task.activationsPerFiringFrame
                else 0.0 [s];
    }

    calc def TasksDemandInFrame {
        doc /* The execution time a set of tasks demands in one minor frame. */
        in tasks : ScheduledTask[*];
        in frameIndex : Natural;
        return demand : DurationValue =
            sum(tasks->collect { in t : ScheduledTask; TaskDemandInFrame(t, frameIndex) });
    }

    calc def Utilisation {
        doc /* The processor utilisation of a set of tasks: the sum of execution time over period. */
        in tasks : ScheduledTask[*];
        return utilisation : Real = RealFunctions::sum(tasks.utilisation);
    }

    // ---- 2. The minor-frame schedule of the executive ---------------------------------------
    part def PartitionSchedule {
        doc /* One partition on the schedule: the slices it owns in every minor frame, the tasks
             * it hosts, and the two checks a cyclic executive needs — the utilisation of its
             * tasks fits the share of the processor the partition owns, and the demand of every
             * minor frame fits the slices the partition has in that frame. */
        ref part partition : Partition;
        part slices : FrameSlice[*];
        part tasks : ScheduledTask[*];
        attribute minorFramePeriod : DurationValue;
        attribute majorFramePeriod : DurationValue;
        attribute sliceTime : DurationValue = sum(slices.duration);
        attribute processorShare : Real = partition.windowDuration / majorFramePeriod;
        attribute utilisation : Real = Utilisation(tasks);
        assert constraint slicesMatchWindow {
            doc /* The slices of the eight minor frames add up to the partition window of the
                 * major frame. */
            sliceTime * (majorFramePeriod / minorFramePeriod) == partition.windowDuration
        }
        assert constraint utilisationWithinShare {
            doc /* The tasks together need no more of the processor than the partition owns. */
            utilisation <= processorShare
        }
        assert constraint everyFrameFits {
            doc /* In every minor frame the activations due fit the partition's slices. */
            allMinorFrames->forAll { in f : Natural; TasksDemandInFrame(tasks, f) <= sliceTime }
        }
    }

    // ---- 3. The Argent schedule --------------------------------------------------------------
    part def FlightTiming {
        doc /* The timing of one flight software: the rate groups, the slices every partition
             * owns in a minor frame and the tasks it hosts. The minor frame is tiled exactly by
             * the slices and every partition's slices add up to its window of the major frame. */
        ref part software : ArgentFlightSoftware;
        attribute minorFramePeriod : DurationValue = software.executive.minorFramePeriod;
        attribute majorFramePeriod : DurationValue = software.executive.majorFramePeriod;
        part rg16 : RateGroup {
            doc /* Twice a minor frame: the control and monitoring loops. */
            attribute :>> rate = 16.0 [Hz];
            attribute :>> period = 0.0625 [s];
            attribute :>> activationsPerMajorFrame = 16;
        }
        part rg8 : RateGroup {
            doc /* Once a minor frame: command, telemetry and mode handling. */
            attribute :>> rate = 8.0 [Hz];
            attribute :>> period = 0.125 [s];
            attribute :>> activationsPerMajorFrame = 8;
        }
        part rg2 : RateGroup {
            doc /* Twice a major frame: slow subsystem control. */
            attribute :>> rate = 2.0 [Hz];
            attribute :>> period = 0.5 [s];
            attribute :>> activationsPerMajorFrame = 2;
        }
        part rg1 : RateGroup {
            doc /* Once a major frame: housekeeping and background services. */
            attribute :>> rate = 1.0 [Hz];
            attribute :>> period = 1.0 [s];
            attribute :>> activationsPerMajorFrame = 1;
        }
        part rateGroups : RateGroup[*] = (rg16, rg8, rg2, rg1);
        part schedules : PartitionSchedule[*];
        attribute minorFrameSliceTime : DurationValue = sum(schedules.sliceTime);
        attribute taskCount : Natural = size(schedules.tasks);
        assert constraint slicesTileMinorFrame {
            doc /* The slices of all partitions fill the minor frame exactly. */
            minorFrameSliceTime == minorFramePeriod
        }
    }

    part argentTiming : FlightTiming {
        doc /* The Argent flight software on the Kestrel executive: five partitions, four rate
             * groups, twenty scheduled tasks. Execution times are fictional estimates for the
             * flight processor. */
        ref part :>> software = argentSoftware.cdh.software;
        part platformSchedule : PartitionSchedule {
            doc /* Platform partition: two slices a minor frame so the FDIR monitor and the
                 * board support run at 16 Hz; command, telemetry, mode and telecom handling at
                 * 8 Hz; one background service a minor frame at 1 Hz. */
            ref part :>> partition = software.executive.platformPartition;
            attribute :>> minorFramePeriod = argentTiming.minorFramePeriod;
            attribute :>> majorFramePeriod = argentTiming.majorFramePeriod;
            part sliceA : FrameSlice { attribute :>> duration = 0.015625 [s]; }
            part sliceB : FrameSlice { attribute :>> duration = 0.015625 [s]; }
            part boardSupportTask : ScheduledTask {
                ref part :>> component = software.boardSupport;
                ref part :>> rateGroup = rg16;
                attribute :>> wcet = 0.001 [s];
                attribute :>> activationsPerFiringFrame = 2;
            }
            part schedulerTask : ScheduledTask {
                ref part :>> component = software.scheduler;
                ref part :>> rateGroup = rg16;
                attribute :>> wcet = 0.001 [s];
                attribute :>> activationsPerFiringFrame = 2;
            }
            part fdirTask : ApplicationTask {
                ref part :>> component = software.fdir;
                ref part :>> rateGroup = rg16;
                attribute :>> wcet = 0.003 [s];
                attribute :>> jitter = 0.0005 [s];
                attribute :>> activationsPerFiringFrame = 2;
            }
            part modeManagementTask : ApplicationTask {
                ref part :>> component = software.modeManagement;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.003 [s];
                attribute :>> jitter = 0.0005 [s];
            }
            part cdhTask : ApplicationTask {
                ref part :>> component = software.cdh;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.004 [s];
                attribute :>> jitter = 0.0005 [s];
            }
            part commandIngestTask : ScheduledTask {
                ref part :>> component = software.commandIngest;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.002 [s];
            }
            part telemetryOutputTask : ScheduledTask {
                ref part :>> component = software.telemetryOutput;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.003 [s];
            }
            part telecomTask : ApplicationTask {
                ref part :>> component = software.telecom;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.005 [s];
                attribute :>> jitter = 0.0005 [s];
            }
            part housekeepingTask : ScheduledTask {
                ref part :>> component = software.housekeeping;
                ref part :>> rateGroup = rg1;
                attribute :>> wcet = 0.003 [s];
                attribute :>> firingFrames = 0;
            }
            part timeTask : ScheduledTask {
                ref part :>> component = software.time;
                ref part :>> rateGroup = rg1;
                attribute :>> wcet = 0.001 [s];
                attribute :>> firingFrames = 1;
            }
            part eventTask : ScheduledTask {
                ref part :>> component = software.events;
                ref part :>> rateGroup = rg1;
                attribute :>> wcet = 0.001 [s];
                attribute :>> firingFrames = 2;
            }
            part tableTask : ScheduledTask {
                ref part :>> component = software.tables;
                ref part :>> rateGroup = rg1;
                attribute :>> wcet = 0.001 [s];
                attribute :>> firingFrames = 3;
            }
            part dataStoreTask : ScheduledTask {
                ref part :>> component = software.dataStore;
                ref part :>> rateGroup = rg1;
                attribute :>> wcet = 0.002 [s];
                attribute :>> firingFrames = 4;
            }
            part bootUpdateTask : ScheduledTask {
                ref part :>> component = software.bootUpdate;
                ref part :>> rateGroup = rg1;
                attribute :>> wcet = 0.001 [s];
                attribute :>> firingFrames = 5;
            }
            part parameterBootUpdateTask : ApplicationTask {
                ref part :>> component = software.parameterBootUpdate;
                ref part :>> rateGroup = rg1;
                attribute :>> wcet = 0.004 [s];
                attribute :>> firingFrames = 6;
            }
            part :>> slices = (sliceA, sliceB);
            part :>> tasks = (boardSupportTask, schedulerTask, fdirTask, modeManagementTask,
                cdhTask, commandIngestTask, telemetryOutputTask, telecomTask, housekeepingTask, timeTask,
                eventTask, tableTask, dataStoreTask, bootUpdateTask, parameterBootUpdateTask);
        }
        part gncSchedule : PartitionSchedule {
            doc /* GN&C partition: two slices a minor frame for the 16 Hz attitude and
                 * navigation loop, SEP control once a minor frame. */
            ref part :>> partition = software.executive.gncPartition;
            attribute :>> minorFramePeriod = argentTiming.minorFramePeriod;
            attribute :>> majorFramePeriod = argentTiming.majorFramePeriod;
            part sliceA : FrameSlice { attribute :>> duration = 0.015625 [s]; }
            part sliceB : FrameSlice { attribute :>> duration = 0.015625 [s]; }
            part gncTask : ApplicationTask {
                ref part :>> component = software.gnc;
                ref part :>> rateGroup = rg16;
                attribute :>> wcet = 0.012 [s];
                attribute :>> jitter = 0.001 [s];
                attribute :>> activationsPerFiringFrame = 2;
            }
            part sepControlTask : ApplicationTask {
                ref part :>> component = software.sepControl;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.005 [s];
                attribute :>> jitter = 0.0005 [s];
            }
            part :>> slices = (sliceA, sliceB);
            part :>> tasks = (gncTask, sepControlTask);
        }
        part subsystemSchedule : PartitionSchedule {
            doc /* Subsystem partition: one slice a minor frame; power management at 8 Hz,
                 * thermal control at 2 Hz in minor frames 1 and 5. */
            ref part :>> partition = software.executive.subsystemPartition;
            attribute :>> minorFramePeriod = argentTiming.minorFramePeriod;
            attribute :>> majorFramePeriod = argentTiming.majorFramePeriod;
            part slice : FrameSlice { attribute :>> duration = 0.03125 [s]; }
            part powerManagementTask : ApplicationTask {
                ref part :>> component = software.powerManagement;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.005 [s];
                attribute :>> jitter = 0.0005 [s];
            }
            part thermalControlTask : ApplicationTask {
                ref part :>> component = software.thermalControl;
                ref part :>> rateGroup = rg2;
                attribute :>> wcet = 0.006 [s];
                attribute :>> jitter = 0.001 [s];
                attribute :>> firingFrames = (1, 5);
            }
            part :>> slices = (slice);
            part :>> tasks = (powerManagementTask, thermalControlTask);
        }
        part autonomySchedule : PartitionSchedule {
            doc /* Autonomy partition: one half slice a minor frame for the 8 Hz autonomy
                 * executive. */
            ref part :>> partition = software.executive.autonomyPartition;
            attribute :>> minorFramePeriod = argentTiming.minorFramePeriod;
            attribute :>> majorFramePeriod = argentTiming.majorFramePeriod;
            part slice : FrameSlice { attribute :>> duration = 0.015625 [s]; }
            part autonomyTask : ApplicationTask {
                ref part :>> component = software.autonomy;
                ref part :>> rateGroup = rg8;
                attribute :>> wcet = 0.010 [s];
                attribute :>> jitter = 0.001 [s];
            }
            part :>> slices = (slice);
            part :>> tasks = (autonomyTask);
        }
        part payloadSchedule : PartitionSchedule {
            doc /* Payload partition: one half slice a minor frame; capture control at 16 Hz,
                 * inspector handling at 2 Hz in minor frames 2 and 6. */
            ref part :>> partition = software.executive.payloadPartition;
            attribute :>> minorFramePeriod = argentTiming.minorFramePeriod;
            attribute :>> majorFramePeriod = argentTiming.majorFramePeriod;
            part slice : FrameSlice { attribute :>> duration = 0.015625 [s]; }
            part captureControlTask : ApplicationTask {
                ref part :>> component = software.captureControl;
                ref part :>> rateGroup = rg16;
                attribute :>> wcet = 0.006 [s];
                attribute :>> jitter = 0.0005 [s];
                attribute :>> activationsPerFiringFrame = 2;
            }
            part inspectorHandlingTask : ApplicationTask {
                ref part :>> component = software.inspectorHandling;
                ref part :>> rateGroup = rg2;
                attribute :>> wcet = 0.003 [s];
                attribute :>> jitter = 0.0005 [s];
                attribute :>> firingFrames = (2, 6);
            }
            part :>> slices = (slice);
            part :>> tasks = (captureControlTask, inspectorHandlingTask);
        }
        part :>> schedules = (platformSchedule, gncSchedule, subsystemSchedule, autonomySchedule, payloadSchedule);
    }

    // ---- 4. End-to-end latency chains --------------------------------------------------------
    calc def TaskResponse {
        doc /* The worst-case response of a scheduled task to an input that arrives just after
             * its release: a full period of waiting, then the execution time and the jitter. */
        in task : ScheduledTask;
        return response : DurationValue = task.period + task.wcet + task.jitter;
    }

    part def LatencyChain {
        doc /* A chain of timing legs a signal crosses end to end; the sum of the legs is the
             * worst-case latency, asserted against the bound a requirement puts on it. */
        attribute legs : DurationValue[*];
        attribute latency : DurationValue = sum(legs);
        attribute bound : DurationValue;
        attribute margin : Real = 1.0 - latency / bound;
        assert constraint withinBound {
            doc /* The chain is no longer than its bound. */
            latency <= bound
        }
    }

    part def LatencyChains {
        doc /* The latency chains of one flight software and their common legs. */
        attribute busFrame : DurationValue;
        attribute actuatorSettle : DurationValue;
        part chains : LatencyChain[*];
        attribute allWithinBound : Boolean = chains->forAll { in c : LatencyChain; c.withinBound };
    }

    part argentLatency : LatencyChains {
        doc /* The Argent chains: fault detection, safe configuration, command dispatch and the
             * telemetry sample to its downlink frame. A sample or a command crosses the
             * on-board bus in one AABP-1 frame; an actuator settles within 50 ms. */
        attribute :>> busFrame = 0.125 [s] {
            doc /* The AABP-1 major frame of the on-board bus protocol ICD; the pinned run checks
                 * it against that ICD, which this file precedes. */
        }
        attribute :>> actuatorSettle = 0.05 [s];
        attribute fdirPeriod : DurationValue = argentTiming.platformSchedule.fdirTask.period;
        attribute housekeepingPeriod : DurationValue = argentTiming.software.housekeeping.samplingPeriod;
        attribute safeDownlinkRate : BinaryDigitRateValue = 2000 ['bit/s'] {
            doc /* The safe-mode downlink rate of the space link profile ICD (checked by the run). */
        }
        attribute safeHousekeepingPeriod : DurationValue = 60.0 [s] {
            doc /* The safe-mode housekeeping period of the space link profile ICD (checked by the run). */
        }
        attribute downlinkFrameLength : StorageCapacityValue = 1115.0 [B] {
            doc /* The transfer frame length of the space link profile ICD (checked by the run). */
        }
        attribute frameTransmission : DurationValue =
            ((downlinkFrameLength / (1 [B])) * 8.0 / (safeDownlinkRate / (1 ['bit/s']))) * (1 [s]) {
            doc /* One full-length downlink frame at the safe-mode downlink rate. */
        }
        part faultDetection : LatencyChain {
            doc /* Sensor sample on the bus, then the FDIR monitor's response; the fault
                 * detection latency requirement bounds it at 0.5 s. */
            attribute :>> legs = (busFrame, TaskResponse(argentTiming.platformSchedule.fdirTask));
            attribute :>> bound = 0.5 [s];
        }
        part safeConfiguration : LatencyChain {
            doc /* Detection, the mode manager's response, the slowest safe-mode responder
                 * (thermal control at 2 Hz), the actuator command on the bus and the actuator
                 * settling; the fault response requirement bounds it at 2 s. */
            attribute :>> legs = (faultDetection.latency,
                TaskResponse(argentTiming.platformSchedule.modeManagementTask),
                TaskResponse(argentTiming.subsystemSchedule.thermalControlTask),
                busFrame, actuatorSettle);
            attribute :>> bound = 2.0 [s];
        }
        part commandDispatch : LatencyChain {
            doc /* Command receipt from the transponder on the bus, command ingest, the C&DH
                 * router and the slowest 8 Hz application; bounded by the housekeeping period so
                 * acceptance shows in the next housekeeping packet. */
            attribute :>> legs = (busFrame,
                TaskResponse(argentTiming.platformSchedule.commandIngestTask),
                TaskResponse(argentTiming.platformSchedule.cdhTask),
                TaskResponse(argentTiming.platformSchedule.telecomTask));
            attribute :>> bound = housekeepingPeriod;
        }
        part telemetrySample : LatencyChain {
            doc /* A housekeeping sample, telemetry output, telecom framing and the frame on the
                 * safe-mode downlink; bounded by the safe-mode housekeeping period so no sample
                 * is overwritten before it leaves. */
            attribute :>> legs = (housekeepingPeriod,
                TaskResponse(argentTiming.platformSchedule.telemetryOutputTask),
                TaskResponse(argentTiming.platformSchedule.telecomTask),
                frameTransmission);
            attribute :>> bound = safeHousekeepingPeriod;
        }
        part :>> chains = (faultDetection, safeConfiguration, commandDispatch, telemetrySample);
        assert constraint fdirPeriodWithinRequirement {
            doc /* The FDIR monitor runs at least every 0.1 s, as its task period requirement asks. */
            fdirPeriod <= 0.1 [s]
        }
    }

    // ---- 5. The AABP-1 bus schedule ----------------------------------------------------------
    part def BusSlotAssignment {
        doc /* Slots of the AABP-1 frame given to one message stream between the controller
             * and a node: how many slots a frame, how long each message is and in which modes
             * the stream is scheduled. */
        attribute node : String;
        attribute slotsPerFrame : Natural;
        attribute messageLength : StorageCapacityValue;
        attribute activeModes : TugMode[*] default = allFlightModes;
        attribute bytesPerFrame : StorageCapacityValue = messageLength * slotsPerFrame;
    }

    calc def BusSlotsInMode {
        doc /* The slots a set of streams needs in a frame in one mode. */
        in streams : BusSlotAssignment[*];
        in mode : TugMode;
        return slots : Real = RealFunctions::sum(streams->collect { in a : BusSlotAssignment;
            if includes(a.activeModes, mode) ? a.slotsPerFrame else 0 });
    }

    part def BusSchedule {
        doc /* The schedule of one AABP-1 bus: the frame's slots, the streams assigned to them
             * and the slot and byte utilisation of the frame when every stream is scheduled. */
        attribute frameSlots : Natural;
        attribute framePeriod : DurationValue;
        attribute slotLength : StorageCapacityValue;
        part streams : BusSlotAssignment[*];
        attribute slotsUsed : Real = RealFunctions::sum(streams.slotsPerFrame);
        attribute utilisation : Real = slotsUsed / frameSlots;
        attribute bytesPerFrame : StorageCapacityValue = sum(streams.bytesPerFrame);
        attribute byteUtilisation : Real = bytesPerFrame / (slotLength * frameSlots);
        assert constraint streamsFitFrame {
            doc /* Every stream has a slot in the frame. */
            slotsUsed <= frameSlots
        }
        assert constraint messagesFitSlots {
            doc /* No message is longer than a slot carries. */
            streams->forAll { in a : BusSlotAssignment; a.messageLength <= slotLength }
        }
    }

    part argentBus : BusSchedule {
        doc /* The Argent on-board bus: the 64 slots of 1.953 ms in the 125 ms frame of the
             * on-board bus protocol ICD (the pinned run checks the figures against it). GN&C sensors
             * and the thermal and propulsion unit are polled twice a frame for the 16 Hz loops;
             * the capture mechanisms only in the modes that use them. */
        attribute :>> frameSlots = 64;
        attribute :>> framePeriod = 0.125 [s];
        attribute :>> slotLength = 1024.0 [B];
        part timeBroadcast : BusSlotAssignment { attribute :>> node = "broadcast"; attribute :>> slotsPerFrame = 1; attribute :>> messageLength = 16.0 [B]; }
        part thermalPropulsionPoll : BusSlotAssignment { attribute :>> node = "thermal and propulsion unit"; attribute :>> slotsPerFrame = 2; attribute :>> messageLength = 256.0 [B]; }
        part thermalPropulsionCommand : BusSlotAssignment { attribute :>> node = "thermal and propulsion unit"; attribute :>> slotsPerFrame = 1; attribute :>> messageLength = 64.0 [B]; }
        part thermalZoneSweep : BusSlotAssignment { attribute :>> node = "thermal and propulsion unit"; attribute :>> slotsPerFrame = 1; attribute :>> messageLength = 512.0 [B]; }
        part mechanismStatus : BusSlotAssignment { attribute :>> node = "mechanism unit"; attribute :>> slotsPerFrame = 1; attribute :>> messageLength = 128.0 [B]; }
        part mechanismPoll : BusSlotAssignment {
            attribute :>> node = "mechanism unit"; attribute :>> slotsPerFrame = 2; attribute :>> messageLength = 256.0 [B];
            attribute :>> activeModes = (TugMode::proximityOperations, TugMode::capture, TugMode::despin);
        }
        part mechanismCommand : BusSlotAssignment {
            attribute :>> node = "mechanism unit"; attribute :>> slotsPerFrame = 2; attribute :>> messageLength = 64.0 [B];
            attribute :>> activeModes = (TugMode::proximityOperations, TugMode::capture, TugMode::despin);
        }
        part gncSensorPoll : BusSlotAssignment { attribute :>> node = "star trackers and inertial units"; attribute :>> slotsPerFrame = 8; attribute :>> messageLength = 128.0 [B]; }
        part gncActuatorCommand : BusSlotAssignment { attribute :>> node = "reaction wheels"; attribute :>> slotsPerFrame = 4; attribute :>> messageLength = 64.0 [B]; }
        part massMemoryWrite : BusSlotAssignment { attribute :>> node = "mass memories"; attribute :>> slotsPerFrame = 8; attribute :>> messageLength = 1024.0 [B]; }
        part transponderUplink : BusSlotAssignment { attribute :>> node = "transponders"; attribute :>> slotsPerFrame = 1; attribute :>> messageLength = 1024.0 [B]; }
        part transponderDownlink : BusSlotAssignment { attribute :>> node = "transponders"; attribute :>> slotsPerFrame = 3; attribute :>> messageLength = 1024.0 [B]; }
        part retryReserve : BusSlotAssignment { attribute :>> node = "any"; attribute :>> slotsPerFrame = 2; attribute :>> messageLength = 1024.0 [B]; }
        part :>> streams = (timeBroadcast, thermalPropulsionPoll, thermalPropulsionCommand, thermalZoneSweep,
            mechanismStatus, mechanismPoll, mechanismCommand, gncSensorPoll, gncActuatorCommand,
            massMemoryWrite, transponderUplink, transponderDownlink, retryReserve);
    }

    // ---- 6. Processor, memory and bus budgets per partition and per mode ----------------------
    calc def LoadInMode {
        doc /* The processor load the tasks active in a mode add up to. */
        in tasks : ScheduledTask[*];
        in mode : TugMode;
        return load : Real = RealFunctions::sum(tasks->collect { in t : ScheduledTask;
            if includes(t.activeModes, mode) ? t.component.processorLoadMips else 0.0 });
    }

    calc def FootprintOf {
        doc /* Code and data of the components a set of tasks runs. */
        in tasks : ScheduledTask[*];
        return footprint : StorageCapacityValue =
            sum(tasks->collect { in t : ScheduledTask; t.component.codeSize + t.component.dataSize });
    }

    part def PartitionBudget {
        doc /* One partition's resources: the footprint of its components against the memory the
             * executive gives it, and the processor load of its tasks when all are active. */
        ref part schedule : PartitionSchedule;
        attribute footprint : StorageCapacityValue = FootprintOf(schedule.tasks);
        attribute memoryBudget : StorageCapacityValue = schedule.partition.memoryBudget;
        attribute memoryUtilisation : Real = footprint / memoryBudget;
        attribute peakLoadMips : Real = RealFunctions::sum(schedule.tasks.component.processorLoadMips);
        attribute processorUtilisation : Real = schedule.utilisation;
        assert constraint footprintWithinPartitionMemory {
            doc /* The partition's components fit the memory the executive gives it. */
            footprint <= memoryBudget
        }
    }

    attribute def ModeDemand {
        doc /* One row of the demand table: a flight mode, the processor load and the bus slots
             * the software needs in it. */
        attribute mode : TugMode;
        attribute loadMips : Real;
        attribute busSlots : Real;
    }

    part def SoftwareBudgets {
        doc /* The software demand tables rolled up from the schedule and the bus: processor
             * load and bus slots in every flight mode, memory footprint per partition, and the
             * allocations the flight computer carries — the peak load with the new-design
             * contingency of the active margin policy, and the memory the executive hands to
             * the partitions. */
        ref part timing : FlightTiming;
        ref part bus : BusSchedule;
        ref part tasks : ScheduledTask[*] = timing.schedules.tasks;
        attribute modes : TugMode[*] = (TugMode::launch, TugMode::earlyOperations, TugMode::coast,
            TugMode::thrust, TugMode::approach, TugMode::proximityOperations, TugMode::retreat,
            TugMode::capture, TugMode::despin, TugMode::stackCoast, TugMode::stackThrust,
            TugMode::droHold, TugMode::dockedPassive, TugMode::disposal, TugMode::safe, TugMode::abortHold);
        attribute loadByMode : Real[*] nonunique = modes->collect { in m : TugMode; LoadInMode(tasks, m) };
        attribute busSlotsByMode : Real[*] nonunique = modes->collect { in m : TugMode; BusSlotsInMode(bus.streams, m) };
        attribute demandCoast : ModeDemand {
            attribute :>> mode = TugMode::coast;
            attribute :>> loadMips = LoadInMode(tasks, mode);
            attribute :>> busSlots = BusSlotsInMode(bus.streams, mode);
        }
        attribute demandThrust : ModeDemand {
            attribute :>> mode = TugMode::thrust;
            attribute :>> loadMips = LoadInMode(tasks, mode);
            attribute :>> busSlots = BusSlotsInMode(bus.streams, mode);
        }
        attribute demandCapture : ModeDemand {
            attribute :>> mode = TugMode::capture;
            attribute :>> loadMips = LoadInMode(tasks, mode);
            attribute :>> busSlots = BusSlotsInMode(bus.streams, mode);
        }
        attribute demandSafe : ModeDemand {
            attribute :>> mode = TugMode::safe;
            attribute :>> loadMips = LoadInMode(tasks, mode);
            attribute :>> busSlots = BusSlotsInMode(bus.streams, mode);
        }
        attribute peakLoadMips : Real = RealFunctions::sum(tasks.component.processorLoadMips)
            + timing.software.executive.processorLoadMips;
        attribute scheduleUtilisation : Real = RealFunctions::sum(timing.schedules.utilisation);
        attribute allocatedLoadMips : Real = peakLoadMips * (1.0 + activePolicy.newDesignContingency);
        attribute footprint : StorageCapacityValue = FootprintOf(tasks)
            + timing.software.executive.codeSize + timing.software.executive.dataSize;
        attribute allocatedMemory : StorageCapacityValue = timing.software.executive.partitionMemory;
        part partitionBudgets : PartitionBudget[*];
        assert constraint footprintWithinAllocation {
            doc /* The components together fit the memory the executive hands out. */
            footprint <= allocatedMemory
        }
    }

    part argentSoftwareBudgets : SoftwareBudgets {
        doc /* The Argent demand tables over the schedule and the bus. */
        ref part :>> timing = argentTiming;
        ref part :>> bus = argentBus;
        part platformBudget : PartitionBudget { ref part :>> schedule = argentTiming.platformSchedule; }
        part gncBudget : PartitionBudget { ref part :>> schedule = argentTiming.gncSchedule; }
        part subsystemBudget : PartitionBudget { ref part :>> schedule = argentTiming.subsystemSchedule; }
        part autonomyBudget : PartitionBudget { ref part :>> schedule = argentTiming.autonomySchedule; }
        part payloadBudget : PartitionBudget { ref part :>> schedule = argentTiming.payloadSchedule; }
        part :>> partitionBudgets = (platformBudget, gncBudget, subsystemBudget, autonomyBudget, payloadBudget);
    }

    part def SoftwareProcessorBudget :> ProcessorBudget {
        doc /* The processor budget fed from the per-application sums instead of the flight
             * computer's typed-in figures. */
        attribute :>> loadMips = argentSoftwareBudgets.allocatedLoadMips;
        attribute :>> memoryAllocated = argentSoftwareBudgets.allocatedMemory;
    }
    part softwareProcessorBudget : SoftwareProcessorBudget {
        doc /* Processor and memory closure on the rolled-up software demand. */
    }
    part softwareBusBudget : BusBudget {
        doc /* Bus closure with every stream scheduled, the capture modes' demand. */
        attribute :>> frameSlots = argentBus.frameSlots;
        attribute :>> slotsUsed = argentBus.slotsUsed;
    }
    part softwareBusBudgetCoast : BusBudget {
        doc /* Bus closure in coast, without the capture mechanism streams. */
        attribute :>> frameSlots = argentBus.frameSlots;
        attribute :>> slotsUsed = argentSoftwareBudgets.demandCoast.busSlots;
    }
    part faultDetectionBudget : LatencyBudget {
        doc /* Fault detection against its 0.5 s bound. */
        attribute :>> latency = argentLatency.faultDetection.latency;
        attribute :>> bound = argentLatency.faultDetection.bound;
    }
    part safeConfigurationBudget : LatencyBudget {
        doc /* Safe configuration against its 2 s bound. */
        attribute :>> latency = argentLatency.safeConfiguration.latency;
        attribute :>> bound = argentLatency.safeConfiguration.bound;
    }
    part commandDispatchBudget : LatencyBudget {
        doc /* Command dispatch against the housekeeping period. */
        attribute :>> latency = argentLatency.commandDispatch.latency;
        attribute :>> bound = argentLatency.commandDispatch.bound;
    }
    part telemetrySampleBudget : LatencyBudget {
        doc /* Telemetry sample to downlink frame against the safe-mode housekeeping period. */
        attribute :>> latency = argentLatency.telemetrySample.latency;
        attribute :>> bound = argentLatency.telemetrySample.bound;
    }

    assert satisfy processorBudgetCloses by softwareProcessorBudget {
        doc /* The processor budget closes on the rolled-up software demand. */
    }
    assert satisfy busBudgetCloses by softwareBusBudget {
        doc /* The bus budget with every stream scheduled. */
    }
    assert satisfy busBudgetCloses by softwareBusBudgetCoast {
        doc /* The bus budget in coast. */
    }
    assert satisfy latencyBudgetCloses by faultDetectionBudget {
        doc /* Fault detection keeps its margin. */
    }
    assert satisfy latencyBudgetCloses by safeConfigurationBudget {
        doc /* Safe configuration keeps its margin. */
    }
    assert satisfy latencyBudgetCloses by commandDispatchBudget {
        doc /* Command dispatch keeps its margin. */
    }
    assert satisfy latencyBudgetCloses by telemetrySampleBudget {
        doc /* The telemetry sample keeps its margin. */
    }

    // ---- 7. The flight computer carries the software allocations ----------------------------
    part def TimedFlightComputer :> LoadedFlightComputer {
        doc /* A loaded flight computer whose processor load and allocated memory are the
             * software budgets' allocations rather than typed-in figures. */
        attribute :>> processorLoadMips = argentSoftwareBudgets.allocatedLoadMips;
        attribute :>> memoryAllocated = argentSoftwareBudgets.allocatedMemory;
    }
    part def TimedCdh :> CdhWithSoftware {
        doc /* The C&DH subsystem with timed flight computers. */
        part :>> flightComputers : TimedFlightComputer[2];
        part :>> prime : TimedFlightComputer[1];
        part :>> redundant : TimedFlightComputer[1];
    }
    part def TimedTug :> SoftwareTug {
        doc /* The software tug with the timed C&DH subsystem. */
        part :>> cdh : TimedCdh;
    }
    part argentTimed : TimedTug {
        doc /* The Argent tug whose flight computer carries the software allocations. */
    }
}
