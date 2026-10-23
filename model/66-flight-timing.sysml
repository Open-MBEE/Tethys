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
}
