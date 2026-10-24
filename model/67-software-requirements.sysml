// Software requirements tier: the flight-software rows (TF-) and the ground-software rows (TM-)
// derived from the L2/L3/L4 system rows, the flight rules and the dictionary requirement, each
// with a measurable constraint over the backbone and a satisfying software element. The ground
// rows are satisfied, and the GS- rows of TethysGroundSoftware absorbed, in the tool-tier
// sibling 67-software-requirements-tooling.sysml, because the pilot resolves a file only
// against earlier-numbered files and 69 is later than this one.
package TethysSoftwareRequirements {
    doc /* The software requirements of Tethys. `FlightSoftwareRequirement` rows (TF-) bind to
         * the Argent Flight Executive of TethysFlightSoftware, its behaviour, dictionary and
         * timing; `GroundSoftwareRequirement` rows (TM-) bind to the Meridian Operations Suite
         * through the backbone it reads: the flight dictionary, the flight rules, the ground
         * requirements and the Meridian staffing. Every row derives from at least one system
         * row and states its constraint over model values, so -satisfy evaluates it; the rows a
         * software element cannot yet meet (the AABP-1 reserve in the full modes) fail visibly
         * rather than being tuned. Figures that belong to the MLS-2 link profile of
         * TethysSoftwareIcds are typed in here and asserted equal in the pinned run, because
         * that file is later-numbered. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import ModelingMetadata::*;
    private import RequirementDerivation::*;
    private import VerificationCases::VerificationMethodKind;
    private import TethysRequirements::RequirementTier;
    private import TethysRequirements::Verification;
    private import TethysRequirements::VerificationLevel;
    private import TethysRequirements::VerificationStage;
    private import TethysRequirementsL2::*;
    private import TethysRequirementsL3L4::*;
    private import TethysStakeholders::missionMeasures;
    private import TethysVerification::testBeds;
    private import TethysMarginPolicy::activeSoftwarePolicy;
    private import TethysTugStructure::TugMode;
    private import TethysTugStructure::allFlightModes;
    private import TethysBudgets::ProcessorBudget;
    private import TethysBudgets::BusBudget;
    private import TethysBudgets::LatencyBudget;
    private import TethysBudgets::dataBudget;
    private import TethysBudgets::processorBudgetCloses;
    private import TethysBudgets::busBudgetCloses;
    private import TethysBudgets::latencyBudgetCloses;
    private import TethysMeridian::GroundSoftwareComponent;
    private import TethysMeridian::meridian;
    private import TethysOperations::noThrustDuringRelay;
    private import TethysOperations::approachKeepOut;
    private import TethysOperations::sunExclusion;
    private import TethysOperations::batteryDepthOfDischarge;
    private import TethysOperations::dictionaryConsistent;
    private import TethysOperations::operationsReadiness;
    private import TethysModes::argentModeTable;
    private import TethysFdir::cruiseLimits;
    private import TethysFdir::FdirLevel;
    private import TethysFlightSoftware::*;
    private import TethysFlightDictionary::flightDictionary;
    private import TethysFlightBehaviour::ParameterBootUpdateSoftware;
    private import TethysFlightBehaviour::BehaviouralCdh;
    private import TethysFlightBehaviour::softwareNominalFlight;
    private import TethysFlightTiming::*;

    // ---- the two software tiers --------------------------------------------------------------
    requirement def FlightSoftwareRequirement :> SoftwareRequirement {
        doc /* A requirement on the Argent flight software: an application, a core service, the
             * Kestrel executive or a software budget of TethysFlightSoftware and its companions. */
        attribute :>> tier = RequirementTier::software;
    }
    requirement def GroundSoftwareRequirement :> SoftwareRequirement {
        doc /* A requirement on the Meridian Operations Suite, stated over the backbone the suite
             * reads (dictionary, flight rules, ground requirements, staffing) so it validates on
             * the pilot without the later-numbered ground-software file. */
        attribute :>> tier = RequirementTier::software;
    }

    // ---- TF: core services and executive -----------------------------------------------------
    requirement <'TF-001'> commandIngest : FlightSoftwareRequirement {
        doc /* The command ingest service shall accept a CCSDS Space Packet of up to the maximum
             * packet length, reject any opcode that is not in the flight dictionary and reject a
             * command whose current tug mode is not among its allowed modes. Rationale: every
             * refusal the ground can make (TM-001) is repeated on board, so a corrupted or
             * mis-sequenced load cannot act; the dictionary properties the check relies on
             * (unique opcodes, a mode precondition on every command) are the dictionary
             * requirement's. */
        subject ingest : CommandIngestService;
        attribute ccsdsMaximumPacketLength : StorageCapacityValue = 65542.0 [B];
        require constraint {
            ingest.maximumPacketLength >= ccsdsMaximumPacketLength
                and flightDictionary.opcodesUnique and flightDictionary.commandsHaveModePrecondition
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-002'> hazardousTwoStep : FlightSoftwareRequirement {
        doc /* A hazardous command (a thrust-arc start, a processor reset, the capture abort)
             * shall execute only when its confirmation key matches the key the dictionary
             * assigns, after the ground's second approval. Rationale: the two-step protects the
             * irreversible actions behind FR-001 and the capture sequence; the dictionary must
             * mark at least one command hazardous, mark the abort hazardous, and not mark every
             * command hazardous, or the two-step is either absent or meaningless. */
        subject ingest : CommandIngestService;
        require constraint {
            flightDictionary.hazardousCommandCount >= 1 and flightDictionary.abortIsHazardous
                and flightDictionary.hazardousCommandCount < flightDictionary.commandCount
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-003'> telemetryRatesByMode : FlightSoftwareRequirement {
        doc /* The telecom application shall select the MLS-2 rate set of the current tug mode:
             * the proximity and capture rate set with a 1 s housekeeping period, the coast and
             * thrust rate set with a 10 s period, and the safe rate set, whose downlink rate is
             * the deep-space-link minimum, in every mode as the fallback. Rationale: the ground
             * decommutates by mode (TM-004) and the link closes at the safe rate from any range;
             * the figures are the MLS-2 profile's and the pinned run asserts them equal. */
        subject telecom : TelecomApplication;
        attribute proximityDownlinkRate : BinaryDigitRateValue = 4.0e6 ['bit/s'];
        attribute coastDownlinkRate : BinaryDigitRateValue = 3.2e4 ['bit/s'];
        attribute safeDownlinkRate : BinaryDigitRateValue = argentLatency.safeDownlinkRate;
        attribute proximityHousekeepingPeriod : DurationValue = 1.0 [s];
        attribute coastHousekeepingPeriod : DurationValue = 10.0 [s];
        require constraint {
            safeDownlinkRate >= deepSpaceLink.minimumRate ['bit/s']
                and coastDownlinkRate > safeDownlinkRate and proximityDownlinkRate > coastDownlinkRate
                and proximityHousekeepingPeriod < coastHousekeepingPeriod
                and argentSoftware.cdh.software.housekeeping.samplingPeriod <= proximityHousekeepingPeriod
                and telecom.activeModes->includes(TugMode::safe)
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-004'> eventLogging : FlightSoftwareRequirement {
        doc /* The event service shall keep a log deep enough for four occurrences of every
             * dictionary event, with unique event ids and at least one fault-relevant event.
             * Rationale: after a seven-day autonomous period the ground reconstructs what the
             * fault protection did from the log alone (TS-013, TA-010). */
        subject events : EventService;
        require constraint {
            events.logDepth >= 4 * flightDictionary.eventCount
                and flightDictionary.eventIdsUnique and flightDictionary.faultEventCount >= 1
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-005'> parameterTables : FlightSoftwareRequirement {
        doc /* The table service shall hold the parameter table and the FDIR limit table as
             * separately loadable tables, every parameter within its dictionary range and every
             * FDIR threshold read from the limit table rather than compiled in. Rationale: a
             * limit change is an uplinked table, never a flight-software build (TC-005, TG-010). */
        subject tables : TableService;
        require constraint {
            tables.tableCount >= 2 and flightDictionary.parametersInRange
                and flightDictionary.fdirThresholdsReadLimitTable
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-006'> timeCorrelation : FlightSoftwareRequirement {
        doc /* The time service shall keep mission elapsed time at microsecond resolution and
             * emit a time-correlation packet no less often than the MLS-2 correlation period,
             * which is itself no shorter than a major frame. Rationale: the ranging accuracy
             * TG-003 asks of flight dynamics needs the packet time tags correlated to the
             * station clock; the period is the MLS-2 profile's and the pinned run asserts it. */
        subject time : TimeService;
        attribute correlationPeriod : DurationValue = 60.0 [s];
        require constraint {
            time.resolution <= 1.0e-6 [s]
                and correlationPeriod >= argentSoftware.cdh.software.executive.majorFramePeriod
                and correlationPeriod <= argentSoftware.cdh.software.boardSupport.scrubPeriod
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-007'> imageIntegrity : FlightSoftwareRequirement {
        doc /* The boot/update service shall keep two image slots, verify the checksum of an
             * uploaded image with the same algorithm the safe image uses before activating it,
             * and keep the safe image no larger than the flight image. Rationale: an update that
             * fails verification falls back to the safe image without ground contact (TS-013). */
        subject boot : BootUpdateService;
        require constraint {
            boot.imageSlots >= 2
                and argentSoftware.cdh.software.flightImage.checksumAlgorithm == argentSoftware.cdh.software.safeImage.checksumAlgorithm
                and argentSoftware.cdh.software.safeImage.imageSize <= argentSoftware.cdh.software.flightImage.imageSize
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-008'> bootFallback : FlightSoftwareRequirement {
        doc /* The boot manager shall fall back to the safe image when the flight image has not
             * reported running within the boot timeout; the timeout is longer than the watchdog
             * period, so a watchdog reset is not mistaken for a failed boot, and no longer than
             * two memory-scrub periods. Rationale: a boot loop must resolve to a safe image on
             * its own during the autonomy period (TS-013). */
        subject bootApp : ParameterBootUpdateSoftware;
        attribute bootTimeout : DurationValue = bootApp.manager.bootTimeout;
        require constraint {
            bootTimeout > argentSoftware.cdh.software.boardSupport.watchdogPeriod
                and bootTimeout <= 2.0 * argentSoftware.cdh.software.boardSupport.scrubPeriod
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-009'> partitionIsolation : FlightSoftwareRequirement {
        doc /* The Kestrel executive shall schedule its partitions in fixed windows that fit one
             * major frame, with the minor frames tiling the major frame exactly and no heap
             * allocation after initialisation. Rationale: a fault in one partition cannot steal
             * time or memory from the fault-protection partition (TS-015, TS-142). */
        subject executive : KestrelExecutive;
        require constraint {
            not executive.heapAfterInitialisation
                and executive.scheduledWindows <= executive.majorFramePeriod
                and executive.minorFramePeriod * executive.minorFramesPerMajorFrame == executive.majorFramePeriod
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-010'> processorMemoryReserve : FlightSoftwareRequirement {
        doc /* The flight software's processor load and memory footprint shall close against the
             * flight computer with the reserve the active software margin policy row
             * (TethysMarginPolicy::activeSoftwarePolicy) prescribes. Rationale: the reserve is
             * the policy's, not this row's, so a policy change re-evaluates every budget at
             * once (TS-142). */
        subject budget : ProcessorBudget;
        require budget.processorCloses;
        require budget.memoryCloses;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-011'> busReserve : FlightSoftwareRequirement {
        doc /* The AABP-1 bus schedule of the full modes (proximity operations, capture, despin)
             * shall close against the frame with the reserve the active software margin policy
             * row prescribes. Rationale: the bus is the one shared resource every application
             * uses; the schedule currently uses more slots than the reserve allows, so this row
             * is open and its satisfaction fails until the maintainer resizes the schedule or
             * the policy (TS-143). */
        subject budget : BusBudget;
        require budget.busCloses;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-012'> busReserveCoast : FlightSoftwareRequirement {
        doc /* The AABP-1 bus schedule of the coast mode shall close against the frame with the
             * reserve the active software margin policy row prescribes. Rationale: coast is the
             * mode the tug spends most of the mission in, so its reserve is the one the growth
             * of the mission actually consumes (TS-143). */
        subject budget : BusBudget;
        require budget.busCloses;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }

    // ---- TF: FDIR latencies, safe mode, modes, sequencing, redundancy ------------------------
    requirement <'TF-013'> faultDetectionChain : FlightSoftwareRequirement {
        doc /* The fault-detection chain (bus frame plus the FDIR task response) shall complete
             * within the detection latency TA-010 allocates to command and data handling and
             * within its own bound. Rationale: the chain is the software share of the
             * subsystem's 0.5 s; the latency is computed from the task schedule, not asserted. */
        subject chain : LatencyChain;
        require constraint { chain.latency <= faultDetectionLatency.detectionLatency and chain.withinBound }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-014'> safeConfigurationLatency : FlightSoftwareRequirement {
        doc /* The safe-configuration chain (detection, response dispatch, bus frame, actuator
             * settle) shall complete within the TS-015 response time and within its own bound.
             * Rationale: the chain is the end-to-end software path from fault signature to safe
             * configuration that TS-015 bounds against the time to criticality. */
        subject chain : LatencyChain;
        require constraint { chain.bound <= faultResponse.responseTime and chain.withinBound }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-015'> fdirTaskRate : FlightSoftwareRequirement {
        doc /* The FDIR application task shall be scheduled with a period no longer than the
             * TC-005 task period, in a rate group at least as fast as the application's required
             * rate. Rationale: TC-005 is the fault-protection period; the schedule, not the
             * application, decides whether it is met. */
        subject task : ApplicationTask;
        require constraint { task.period <= fdirTaskPeriod.taskPeriod and task.hostedAtRequiredRate }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-016'> commandDispatchLatency : FlightSoftwareRequirement {
        doc /* The command-dispatch chain (bus frame, ingest, dispatch to the application) shall
             * complete within the AABP-1 acknowledgement timeout and within its own bound.
             * Rationale: a command acknowledged late is retried by the ground, and a retry of a
             * hazardous command is what the two-step exists to prevent (TS-021); the timeout is
             * the AABP-1 protocol's and the pinned run asserts it. */
        subject chain : LatencyChain;
        attribute acknowledgementTimeout : DurationValue = 2.0 [s];
        require constraint { chain.latency <= acknowledgementTimeout and chain.withinBound }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-017'> telemetrySampleLatency : FlightSoftwareRequirement {
        doc /* The telemetry-sample chain (housekeeping sample, packetisation, frame) shall
             * complete within its bound, and the bound shall be no shorter than the housekeeping
             * sampling period. Rationale: a sample older than one period is indistinguishable
             * from a missed one at the station (TS-007). */
        subject chain : LatencyChain;
        require constraint { chain.bound >= argentSoftware.cdh.software.housekeeping.samplingPeriod and chain.withinBound }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-018'> safeModeEntry : FlightSoftwareRequirement {
        doc /* The mode manager shall enter the safe mode on a system-level fault response and on
             * command-loss timeout, and shall be active in the safe mode itself; the command-loss
             * timeout shall be shorter than the autonomy duration. Rationale: safe mode is the
             * configuration TS-013 keeps the tug alive in; a timeout longer than the autonomy
             * period would never fire (TS-013, TS-015). */
        subject modeApp : ModeManagementApplication;
        require constraint {
            modeApp.safeMode == TugMode::safe and modeApp.activeModes->includes(TugMode::safe)
                and cruiseLimits.commandLossTimeout <= autonomousSurvival.autonomyDuration
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-019'> modeTransitions : FlightSoftwareRequirement {
        doc /* The mode manager shall start in the launch mode, be active in every flight mode
             * and command the mode table's configuration on each transition, with the thrusters
             * off in the safe mode. Rationale: the mode machine of TethysModes is the one mode
             * vocabulary; the software must never be absent from a mode it has to leave
             * (TS-013). */
        subject modeApp : ModeManagementApplication;
        require constraint {
            modeApp.initialMode == TugMode::launch
                and size(modeApp.activeModes) == size(allFlightModes)
                and not argentModeTable.safe.sepThrusting
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-020'> sequencingEngine : FlightSoftwareRequirement {
        doc /* The autonomy application shall run its stored sequences concurrently, dispatch
             * time-tagged commands through the scheduler with at least 64 schedule slots per
             * concurrent sequence, check the FR-001 and FR-004 constraints before each dispatch,
             * and be active in the thrust mode. Rationale: the sequence engine is how a cleared
             * sequence (TM-003) executes without ground contact within the TS-021 latency. */
        subject autonomy : AutonomyApplication;
        require constraint {
            autonomy.concurrentSequences >= 1
                and argentSoftware.cdh.software.scheduler.scheduleSlots >= 64 * autonomy.concurrentSequences
                and autonomy.activeModes->includes(TugMode::thrust)
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-021'> redundancyManagement : FlightSoftwareRequirement {
        doc /* The command and data handling subsystem shall host the same flight image on two
             * flight computers and the board support package shall service a watchdog whose
             * period is shorter than the command-loss timeout. Rationale: a processor fault is
             * survived by the redundant computer during the autonomy period (TS-013). */
        subject cdh : CdhWithSoftware;
        require constraint {
            size(cdh.flightComputers) == 2
                and cdh.prime.image.version == cdh.redundant.image.version
                and cdh.software.boardSupport.watchdogPeriod < cruiseLimits.commandLossTimeout
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-022'> heartbeatFailover : FlightSoftwareRequirement {
        doc /* The redundancy manager shall switch to the redundant computer when the prime's
             * heartbeat has been missing for the heartbeat timeout, completing the switchover
             * so that timeout plus switchover is shorter than the command-loss timeout.
             * Rationale: a failover must finish before command loss is declared, or the two
             * responses race (TS-013, TS-015). */
        subject cdh : BehaviouralCdh;
        attribute heartbeatTimeout : DurationValue = cdh.redundancy.heartbeatTimeout;
        attribute switchoverDuration : DurationValue = cdh.redundancy.switchoverDuration;
        require constraint { heartbeatTimeout + switchoverDuration < cruiseLimits.commandLossTimeout }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }


    // ---- TF: the remaining core services, the bus and the board support --------------------
    requirement <'TF-023'> busMessaging : FlightSoftwareRequirement {
        doc /* The AABP-1 software bus shall provide a topic for every software component, a
             * receive queue of at least one message per topic and a maximum message no longer
             * than the largest command packet. Rationale: a component without a topic cannot
             * publish, and a message longer than a packet cannot be relayed to the ground
             * (TS-143). */
        subject bus : SoftwareBus;
        require constraint {
            bus.topicCount >= size(argentSoftware.cdh.software.components) and bus.queueDepth >= 1
                and bus.maximumMessageLength <= argentSoftware.cdh.software.commandIngest.maximumPacketLength
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-024'> dataStoreRetention : FlightSoftwareRequirement {
        doc /* The data store service shall retain products for at least the autonomy duration,
             * hold the store demand of the days without contact and serve at least one downlink
             * queue. Rationale: what the tug records during the autonomy period must still be
             * there when the link returns (TS-013, TS-007). */
        subject store : DataStoreService;
        require constraint {
            store.defaultRetention >= autonomousSurvival.autonomyDuration and store.downlinkQueues >= 1
                and store.capacity >= dataBudget.storageDemand
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-025'> telemetryOutput : FlightSoftwareRequirement {
        doc /* The telemetry output service shall emit every dictionary packet under its unique,
             * in-range application id. Rationale: the ground decommutates by application id
             * (TM-004); a duplicate or out-of-range id is lost at the frame (TG-010, TS-007). */
        subject output : TelemetryOutputService;
        require constraint {
            flightDictionary.packetCount >= 1 and flightDictionary.apidsUnique and flightDictionary.apidsWithinRange
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-026'> housekeepingSampling : FlightSoftwareRequirement {
        doc /* The housekeeping service shall sample no slower than the fastest MLS-2
             * housekeeping period and no faster than one major frame, under an application id
             * within the dictionary range. Rationale: the sample period is the floor of every
             * telemetry latency chain (TS-007). */
        subject housekeeping : HousekeepingService;
        require constraint {
            housekeeping.samplingPeriod <= telemetryRatesByMode.proximityHousekeepingPeriod
                and housekeeping.samplingPeriod >= argentSoftware.cdh.software.executive.majorFramePeriod
                and housekeeping.housekeepingApid <= flightDictionary.apidMaximum
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-027'> schedulerCapacity : FlightSoftwareRequirement {
        doc /* The scheduler service shall hold at least 64 time-tagged entries per concurrent
             * sequence the autonomy application may run. Rationale: a sequence that cannot be
             * fully scheduled on load would be refused on board after the ground cleared it
             * (TS-021). */
        subject scheduler : SchedulerService;
        require constraint {
            scheduler.scheduleSlots >= 64 * argentSoftware.cdh.software.autonomy.concurrentSequences
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-028'> boardSupportWatchdog : FlightSoftwareRequirement {
        doc /* The board support package shall service a hardware watchdog with a period longer
             * than a major frame and shorter than the memory scrub period, from a boot ROM no
             * larger than the safe image. Rationale: the watchdog is the reset of last resort
             * behind every software fault response (TS-013, TS-015). */
        subject boardSupport : BoardSupportPackage;
        require constraint {
            boardSupport.watchdogPeriod > argentSoftware.cdh.software.executive.majorFramePeriod
                and boardSupport.watchdogPeriod < boardSupport.scrubPeriod
                and boardSupport.bootRomSize <= argentSoftware.cdh.software.safeImage.imageSize
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }

    // ---- TF: one row per application: hosted rate and mode activity against the mode table ---
    requirement <'TF-030'> cdhApplication : FlightSoftwareRequirement {
        doc /* The C&DH application shall run in every flight mode at no less than 1 Hz.
             * Rationale: it owns the housekeeping and command routing every other application
             * depends on (TS-013). */
        subject app : CdhApplication;
        require constraint { size(app.activeModes) == size(allFlightModes) and app.rate >= 1.0 [Hz] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-031'> gncApplication : FlightSoftwareRequirement {
        doc /* The GNC application shall be active in every mode whose table row has wheel
             * control on, at a rate no lower than the FDIR task rate. Rationale: attitude
             * control is the first thing a fault response needs (TS-015). */
        subject app : GncApplication;
        require constraint {
            (argentModeTable.capture.gncWheelControlActive implies app.activeModes->includes(TugMode::capture))
                and (argentModeTable.thrust.gncWheelControlActive implies app.activeModes->includes(TugMode::thrust))
                and app.rate >= argentSoftware.cdh.software.fdir.rate
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-032'> sepControlApplication : FlightSoftwareRequirement {
        doc /* The SEP control application shall be active in every mode whose table row has SEP
             * control active and shall manage four thruster strings. Rationale: FR-001 is kept by
             * construction only if the application that throttles the thrusters is awake in
             * every mode that thrusts. */
        subject app : SepControlApplication;
        require constraint {
            (argentModeTable.thrust.sepControlActive implies app.activeModes->includes(TugMode::thrust))
                and (argentModeTable.stackThrust.sepControlActive implies app.activeModes->includes(TugMode::stackThrust))
                and app.thrusterStrings == 4
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-033'> powerManagementApplication : FlightSoftwareRequirement {
        doc /* The power management application shall run in every flight mode and shed load
             * before the battery reaches the FR-004 state-of-charge floor. Rationale: the floor
             * is a flight rule the ground clears sequences against; the on-board shed is its
             * last line (FR-004). */
        subject app : PowerManagementApplication;
        require constraint {
            size(app.activeModes) == size(allFlightModes)
                and cruiseLimits.batteryLowFraction <= batteryDepthOfDischarge.stateOfChargeFloor
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-034'> thermalControlApplication : FlightSoftwareRequirement {
        doc /* The thermal control application shall run in every flight mode and control every
             * heater zone. Rationale: the heater zones are the survival heaters of the autonomy
             * period (TS-013). */
        subject app : ThermalControlApplication;
        require constraint { size(app.activeModes) == size(allFlightModes) and app.heaterZones >= 1 }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-035'> telecomApplication : FlightSoftwareRequirement {
        doc /* The telecom application shall be active in every mode whose table row has the
             * high-gain antenna on and in the safe mode. Rationale: the safe rate set is the
             * link of last resort (TS-007). */
        subject app : TelecomApplication;
        require constraint {
            (argentModeTable.coast.telecomHighGainActive implies app.activeModes->includes(TugMode::coast))
                and app.activeModes->includes(TugMode::safe)
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-036'> inspectorHandlingApplication : FlightSoftwareRequirement {
        doc /* The inspector handling application shall be active in every mode whose table row
             * has the proximity link on. Rationale: Wren's relay data arrive only through this
             * application (TS-014). */
        subject app : InspectorHandlingApplication;
        require constraint {
            argentModeTable.proximityOperations.inspectorHandlingActive implies app.activeModes->includes(TugMode::proximityOperations)
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-037'> captureControlApplication : FlightSoftwareRequirement {
        doc /* The capture control application shall be active in every mode whose table row has
             * the capture system armed, and in no mode that keeps the thrusters on. Rationale:
             * the bag fires only in the capture mode behind the inhibit chain (TS-014, TS-015). */
        subject app : CaptureControlApplication;
        require constraint {
            (argentModeTable.capture.captureControlActive implies app.activeModes->includes(TugMode::capture))
                and not app.activeModes->includes(TugMode::thrust)
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-038'> autonomyApplication : FlightSoftwareRequirement {
        doc /* The autonomy application shall be active in the thrust and coast modes and shall
             * never run more concurrent sequences than the scheduler can hold slots for.
             * Rationale: the sequence engine is the TS-021 path (TS-021). */
        subject app : AutonomyApplication;
        require constraint {
            app.activeModes->includes(TugMode::thrust) and app.activeModes->includes(TugMode::coast)
                and app.concurrentSequences <= argentSoftware.cdh.software.scheduler.scheduleSlots
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-039'> fdirApplication : FlightSoftwareRequirement {
        doc /* The FDIR application shall run in every flight mode at the system level, at a rate
             * no lower than the TC-005 task period allows. Rationale: fault protection has no
             * mode it may sleep in (TC-005, TA-010). */
        subject app : FdirApplication;
        require constraint {
            size(app.activeModes) == size(allFlightModes) and app.level == FdirLevel::system
                and app.rate >= 1.0 / fdirTaskPeriod.taskPeriod
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-040'> modeManagementApplication : FlightSoftwareRequirement {
        doc /* The mode management application shall run in every flight mode at a priority no
             * lower than the C&DH application's. Rationale: a mode command must pre-empt routine
             * housekeeping to be timely (TS-015). */
        subject app : ModeManagementApplication;
        require constraint {
            size(app.activeModes) == size(allFlightModes)
                and app.priority <= argentSoftware.cdh.software.cdh.priority
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }
    requirement <'TF-041'> parameterBootUpdateApplication : FlightSoftwareRequirement {
        doc /* The parameter/boot/update application shall run in every flight mode, so a table
             * load or an image upload is possible from any mode including safe. Rationale: the
             * recovery from a safe-mode entry is a parameter change or an update (TS-013). */
        subject app : ParameterBootUpdateApplication;
        require constraint { size(app.activeModes) == size(allFlightModes) and app.activeModes->includes(TugMode::safe) }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::open; }
    }

    // ---- TM: Meridian Operations Suite -------------------------------------------------------
    requirement <'TM-001'> commandValidation : GroundSoftwareRequirement {
        doc /* The command builder shall accept only a mnemonic that is in the flight dictionary,
             * with every argument inside its dictionary range and the planned mode among the
             * command's allowed modes. Rationale: the ground refusal is the first of the two
             * refusals (TF-001 is the second); it is only as good as the dictionary properties
             * TG-010 guarantees. */
        subject builder : GroundSoftwareComponent;
        require constraint {
            flightDictionary.opcodesUnique and flightDictionary.mnemonicsUnique
                and flightDictionary.commandsHaveModePrecondition and flightDictionary.parametersInRange
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-002'> hazardousApproval : GroundSoftwareRequirement {
        doc /* The command builder shall hold every dictionary-hazardous command for a second
             * approval by a role other than the requester, and the operations centre shall
             * staff at least two approving positions per shift. Rationale: the two-step on the
             * ground is what FR-001 and the TS-022 workload limit assume (FR-001, TS-022). */
        subject builder : GroundSoftwareComponent;
        require constraint {
            flightDictionary.hazardousCommandCount >= 1
                and meridian.moc.flightDirector.positionsPerShift + meridian.moc.spacecraftEngineer.positionsPerShift >= 2
                and meridian.moc.flightDirector.positionsPerShift + meridian.moc.spacecraftEngineer.positionsPerShift <= operatorWorkload.operatorsPerShift
        }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-003'> sequenceClearance : GroundSoftwareRequirement {
        doc /* The flight rule checker shall clear every on-board sequence against FR-001 to
             * FR-004 before release, within the TG-005 turnaround and therefore within the
             * TS-021 latency, using a state-of-charge floor no lower than the on-board battery
             * trip. Rationale: a sequence the ground clears to a looser floor than the flight
             * software trips at would be aborted on board (TG-005, TS-021, FR-001, FR-004). */
        subject checker : GroundSoftwareComponent;
        attribute turnaround : DurationValue = sequenceTurnaround.turnaround;
        require constraint {
            turnaround <= commandLatency.sequenceLatency
                and batteryDepthOfDischarge.stateOfChargeFloor >= cruiseLimits.batteryLowFraction
        }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-004'> telemetryDecommutation : GroundSoftwareRequirement {
        doc /* The telemetry server shall decommutate every dictionary packet by its layout, with
             * unique in-range application ids and a source application on every point.
             * Rationale: decommutation is dictionary-driven, so the same TG-010 properties
             * decide whether it can be (TG-010). */
        subject server : GroundSoftwareComponent;
        require constraint {
            flightDictionary.packetsSumToLength and flightDictionary.apidsUnique
                and flightDictionary.apidsWithinRange and flightDictionary.pointsHaveSource
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-005'> limitAlarming : GroundSoftwareRequirement {
        doc /* The telemetry server shall alarm from the dictionary limits and the FDIR limit
             * table, and shall raise a violation at a battery fraction above the on-board trip
             * so that the ground sees the approach to the FR-004 floor before the flight
             * software acts. Rationale: the ground alarm leads the on-board response (FR-004,
             * TG-006). */
        subject server : GroundSoftwareComponent;
        require constraint {
            flightDictionary.fdirThresholdsReadLimitTable
                and flightDictionary.limitTable.batteryLowFraction < batteryDepthOfDischarge.stateOfChargeFloor
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-006'> trendingAutomation : GroundSoftwareRequirement {
        doc /* The telemetry server shall trend every housekeeping point automatically, so that
             * the automated share of monitoring meets TG-006 and the resource trends of the
             * operations readiness review are produced without an operator. Rationale: the
             * TS-022 operator count is only possible if trending is automated (TG-006, TS-022). */
        subject server : GroundSoftwareComponent;
        require constraint {
            monitoringAutomation.automatedFraction >= 0.95
                and flightDictionary.housekeepingPointCount >= 1
                and meridian.moc.shiftsPerDay * meridian.moc.spacecraftEngineer.positionsPerShift <= 2 * operatorWorkload.operatorsPerShift
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-007'> flightDynamicsProducts : GroundSoftwareRequirement {
        doc /* The flight dynamics tool shall produce an orbit determination to the TG-003
             * ranging accuracy, screen every disposal trajectory for Earth impact (TG-004) and
             * fit an arc within the facility's arc length. Rationale: the products are the
             * inputs to every thrust arc the sequence checker clears (TG-003, TG-004). */
        subject tool : GroundSoftwareComponent;
        require constraint {
            rangingAccuracy.rangeAccuracy <= missionMeasures.rangingAccuracy
                and impactScreening.screenedFraction == 1.0
                and meridian.fdf.odArcLength <= autonomousSurvival.autonomyDuration
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-008'> passPlanningVolume : GroundSoftwareRequirement {
        doc /* The pass planner shall plan daily contact so the volume generated each day
             * downlinks within it at the rate of the planned mode, and the on-board store
             * covers the days without contact. Rationale: a pass plan that does not close the
             * data budget silently loses imagery (TS-007, TS-020). */
        subject planner : GroundSoftwareComponent;
        require constraint {
            dataBudget.dailyGenerated <= dataBudget.dailyDownlink
                and dataBudget.storageDemand <= dataBudget.storage
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-009'> archiveRetention : GroundSoftwareRequirement {
        doc /* The data archive shall catalogue each product level within the TG-007 archive
             * latency and retain it for ten years, longer than the nominal mission, with a
             * checksum per product. Rationale: the archive outlives the mission so the delivered
             * body's characterisation can be re-derived (TG-007); the retention is the Vault's
             * rule and the pinned run asserts it. */
        subject archive : GroundSoftwareComponent;
        attribute retention : DurationValue = 3650.0 [d];
        require constraint {
            scienceArchive.archiveLatency <= 30 [d]
                and retention >= TethysMission::tethys.nominalDuration
        }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-010'> anomalyDisposition : GroundSoftwareRequirement {
        doc /* The anomaly tracker shall record the disposition authority of every anomaly and
             * shall never let a safe-mode recovery be dispositioned below the flight director,
             * who is staffed around the clock. Rationale: disposition is a decision, not a
             * software action; the tracker enforces who takes it (TS-022, TG-020). */
        subject tracker : GroundSoftwareComponent;
        require constraint {
            meridian.moc.flightDirector.positionsPerShift >= 1
                and meridian.moc.flightDirector.shiftLength * meridian.moc.shiftsPerDay >= 24.0 [h]
        }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-011'> proximityGoNoGo : GroundSoftwareRequirement {
        doc /* The proximity planner shall issue a go for approach only when the relative
             * navigation range uncertainty is small against the FR-002 keep-out radius and the
             * sun exclusion half-angle of FR-003 is respected by the planned attitude.
             * Rationale: the go/no-go is the ground half of the commit decision (FR-002,
             * FR-003, TS-014). */
        subject planner : GroundSoftwareComponent;
        require constraint {
            approachKeepOut.keepOutRadius >= 100.0 * missionMeasures.rangingAccuracy
                and sunExclusion.exclusionHalfAngle > 0.0 ['°']
        }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::software; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }
    requirement <'TM-012'> simulatorFidelity : GroundSoftwareRequirement {
        doc /* The flight-software-in-the-loop simulator shall run the complete flight image
             * (every component of the flight software) on the flatsat test bed before the
             * capture qualification campaign. Rationale: TS-017 qualifies the capture sequence
             * on the test beds; a partial image would qualify a different software (TS-017). */
        subject simulator : GroundSoftwareComponent;
        require constraint {
            size(argentSoftware.cdh.software.flightImage.contents) == size(argentSoftware.cdh.software.components)
                and size(testBeds.flatsat.fidelity) == 1
        }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::software; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "ground software lead"; status = StatusKind::open; }
    }

    // ---- derivation: every TF-/TM- row from the system rows it refines -----------------------
    #derivation connection { end #original ::> dictionaryConsistent; end #derive ::> telemetryOutput; end #derive ::> commandIngest; end #derive ::> hazardousTwoStep; end #derive ::> parameterTables; end #derive ::> commandValidation; end #derive ::> telemetryDecommutation; }
    #derivation connection { end #original ::> commandLatency; end #derive ::> schedulerCapacity; end #derive ::> commandIngest; end #derive ::> commandDispatchLatency; end #derive ::> sequencingEngine; end #derive ::> autonomyApplication; end #derive ::> commandValidation; end #derive ::> sequenceClearance; }
    #derivation connection { end #original ::> noThrustDuringRelay; end #derive ::> hazardousTwoStep; end #derive ::> sequencingEngine; end #derive ::> sepControlApplication; end #derive ::> hazardousApproval; end #derive ::> sequenceClearance; }
    #derivation connection { end #original ::> batteryDepthOfDischarge; end #derive ::> sequencingEngine; end #derive ::> powerManagementApplication; end #derive ::> sequenceClearance; end #derive ::> limitAlarming; }
    #derivation connection { end #original ::> approachKeepOut; end #derive ::> proximityGoNoGo; }
    #derivation connection { end #original ::> sunExclusion; end #derive ::> proximityGoNoGo; }
    #derivation connection { end #original ::> deepSpaceLink; end #derive ::> telemetryRatesByMode; end #derive ::> timeCorrelation; end #derive ::> telemetrySampleLatency; end #derive ::> telecomApplication; end #derive ::> passPlanningVolume; end #derive ::> dataStoreRetention; end #derive ::> telemetryOutput; end #derive ::> housekeepingSampling; }
    #derivation connection { end #original ::> groundCoverage; end #derive ::> telemetryRatesByMode; end #derive ::> passPlanningVolume; }
    #derivation connection { end #original ::> autonomousSurvival; end #derive ::> eventLogging; end #derive ::> imageIntegrity; end #derive ::> bootFallback; end #derive ::> safeModeEntry; end #derive ::> modeTransitions; end #derive ::> redundancyManagement; end #derive ::> heartbeatFailover; }
    #derivation connection { end #original ::> autonomousSurvival; end #derive ::> dataStoreRetention; end #derive ::> boardSupportWatchdog; end #derive ::> cdhApplication; end #derive ::> thermalControlApplication; end #derive ::> parameterBootUpdateApplication; end #derive ::> flightDynamicsProducts; }
    #derivation connection { end #original ::> faultResponse; end #derive ::> boardSupportWatchdog; end #derive ::> partitionIsolation; end #derive ::> safeConfigurationLatency; end #derive ::> safeModeEntry; end #derive ::> heartbeatFailover; end #derive ::> gncApplication; end #derive ::> captureControlApplication; end #derive ::> modeManagementApplication; }
    #derivation connection { end #original ::> faultDetectionLatency; end #derive ::> eventLogging; end #derive ::> faultDetectionChain; end #derive ::> fdirApplication; }
    #derivation connection { end #original ::> fdirTaskPeriod; end #derive ::> parameterTables; end #derive ::> fdirTaskRate; end #derive ::> fdirApplication; }
    #derivation connection { end #original ::> proximityContactEnvironment; end #derive ::> inspectorHandlingApplication; end #derive ::> captureControlApplication; end #derive ::> proximityGoNoGo; }
    #derivation connection { end #original ::> processorBudgetCloses; end #derive ::> partitionIsolation; end #derive ::> processorMemoryReserve; }
    #derivation connection { end #original ::> busBudgetCloses; end #derive ::> busReserve; end #derive ::> busReserveCoast; end #derive ::> busMessaging; }
    #derivation connection { end #original ::> latencyBudgetCloses; end #derive ::> faultDetectionChain; end #derive ::> safeConfigurationLatency; end #derive ::> commandDispatchLatency; end #derive ::> telemetrySampleLatency; }
    #derivation connection { end #original ::> rangingAccuracy; end #derive ::> timeCorrelation; end #derive ::> flightDynamicsProducts; }
    #derivation connection { end #original ::> impactScreening; end #derive ::> flightDynamicsProducts; }
    #derivation connection { end #original ::> sequenceTurnaround; end #derive ::> sequenceClearance; }
    #derivation connection { end #original ::> monitoringAutomation; end #derive ::> limitAlarming; end #derive ::> trendingAutomation; }
    #derivation connection { end #original ::> scienceArchive; end #derive ::> archiveRetention; }
    #derivation connection { end #original ::> operatorWorkload; end #derive ::> hazardousApproval; end #derive ::> trendingAutomation; end #derive ::> anomalyDisposition; }
    #derivation connection { end #original ::> operationsReadiness; end #derive ::> anomalyDisposition; }
    #derivation connection { end #original ::> captureQualification; end #derive ::> simulatorFidelity; }

    // ---- satisfaction: the flight software elements that meet the TF rows --------------------
    // The TM rows are satisfied in TethysSoftwareRequirementsTooling, which can resolve
    // TethysGroundSoftware.
    satisfy commandIngest by argentSoftware.cdh.software.commandIngest { doc /* The command ingest service. */ }
    satisfy hazardousTwoStep by argentSoftware.cdh.software.commandIngest { doc /* The command ingest service holds the confirmation key. */ }
    satisfy telemetryRatesByMode by argentSoftware.cdh.software.telecom { doc /* The telecom application. */ }
    satisfy eventLogging by argentSoftware.cdh.software.events { doc /* The event service. */ }
    satisfy parameterTables by argentSoftware.cdh.software.tables { doc /* The table service. */ }
    satisfy timeCorrelation by argentSoftware.cdh.software.time { doc /* The time service. */ }
    satisfy imageIntegrity by argentSoftware.cdh.software.bootUpdate { doc /* The boot/update service. */ }
    satisfy bootFallback by softwareNominalFlight.tug.cdh.software.parameterBootUpdate { doc /* The boot/update application exhibiting the boot manager. */ }
    satisfy partitionIsolation by argentSoftware.cdh.software.executive { doc /* The Kestrel executive. */ }
    satisfy processorMemoryReserve by softwareProcessorBudget { doc /* The software processor and memory budget. */ }
    satisfy busReserve by softwareBusBudget { doc /* The AABP-1 budget of the full modes; open until the schedule or the policy changes. */ }
    satisfy busReserveCoast by softwareBusBudgetCoast { doc /* The AABP-1 budget of the coast mode. */ }
    satisfy faultDetectionChain by argentLatency.faultDetection { doc /* The fault-detection chain. */ }
    satisfy safeConfigurationLatency by argentLatency.safeConfiguration { doc /* The safe-configuration chain. */ }
    satisfy fdirTaskRate by argentTiming.platformSchedule.fdirTask { doc /* The FDIR task of the platform partition. */ }
    satisfy commandDispatchLatency by argentLatency.commandDispatch { doc /* The command-dispatch chain. */ }
    satisfy telemetrySampleLatency by argentLatency.telemetrySample { doc /* The telemetry-sample chain. */ }
    satisfy safeModeEntry by argentSoftware.cdh.software.modeManagement { doc /* The mode management application. */ }
    satisfy modeTransitions by argentSoftware.cdh.software.modeManagement { doc /* The mode management application. */ }
    satisfy sequencingEngine by argentSoftware.cdh.software.autonomy { doc /* The autonomy application. */ }
    satisfy redundancyManagement by argentSoftware.cdh { doc /* The C&DH subsystem with its two loaded computers. */ }
    satisfy heartbeatFailover by softwareNominalFlight.tug.cdh { doc /* The behavioural C&DH exhibiting the redundancy manager. */ }
    satisfy busMessaging by argentSoftware.cdh.software.softwareBus { doc /* The AABP-1 software bus. */ }
    satisfy dataStoreRetention by argentSoftware.cdh.software.dataStore { doc /* The data store service. */ }
    satisfy telemetryOutput by argentSoftware.cdh.software.telemetryOutput { doc /* The telemetry output service. */ }
    satisfy housekeepingSampling by argentSoftware.cdh.software.housekeeping { doc /* The housekeeping service. */ }
    satisfy schedulerCapacity by argentSoftware.cdh.software.scheduler { doc /* The scheduler service. */ }
    satisfy boardSupportWatchdog by argentSoftware.cdh.software.boardSupport { doc /* The board support package. */ }
    satisfy cdhApplication by argentSoftware.cdh.software.cdh { doc /* The C&DH application. */ }
    satisfy gncApplication by argentSoftware.cdh.software.gnc { doc /* The GNC application. */ }
    satisfy sepControlApplication by argentSoftware.cdh.software.sepControl { doc /* The SEP control application. */ }
    satisfy powerManagementApplication by argentSoftware.cdh.software.powerManagement { doc /* The power management application. */ }
    satisfy thermalControlApplication by argentSoftware.cdh.software.thermalControl { doc /* The thermal control application. */ }
    satisfy telecomApplication by argentSoftware.cdh.software.telecom { doc /* The telecom application. */ }
    satisfy inspectorHandlingApplication by argentSoftware.cdh.software.inspectorHandling { doc /* The inspector handling application. */ }
    satisfy captureControlApplication by argentSoftware.cdh.software.captureControl { doc /* The capture control application. */ }
    satisfy autonomyApplication by argentSoftware.cdh.software.autonomy { doc /* The autonomy application. */ }
    satisfy fdirApplication by argentSoftware.cdh.software.fdir { doc /* The FDIR application. */ }
    satisfy modeManagementApplication by argentSoftware.cdh.software.modeManagement { doc /* The mode management application. */ }
    satisfy parameterBootUpdateApplication by argentSoftware.cdh.software.parameterBootUpdate { doc /* The parameter/boot/update application. */ }
}
