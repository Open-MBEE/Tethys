# WP-SW-4 — flight software timing, scheduling and resource budgets

Package `TethysFlightTiming` (`model/66-flight-timing.sysml`, mission tier): the rate groups and
minor-frame schedule of `KestrelExecutive`, one scheduled task per software component with
period, WCET, deadline and jitter as `DurationValue`s, the end-to-end latency chains, the AABP-1
bus schedule, and the processor, memory and bus budgets rolled up per partition and per `TugMode`
against the software row of the margin policy. Pinned run `runs/sw-timing-budgets.txt`; findings
in `docs/findings/WP-SW-4.md`.

## Rows

| Row | Construct | Run / check | Status |
| --- | --- | --- | --- |
| SW-010 scheduler: rate groups, major/minor frame, deadlines, jitter | `RateGroup` (`rg16`/`rg8`/`rg2`/`rg1` with `periodMatchesRate`), `FrameSlice`, `PartitionSchedule` (`slicesMatchWindow` against `Partition.windowDuration`, `utilisationWithinShare`, `everyFrameFits` over the eight minor frames with `TasksDemandInFrame`), `FlightTiming::slicesTileMinorFrame`; 22 tasks over the five partitions | `sw-timing-budgets`: `taskCount = 22`, `minorFrameSliceTime = 0.125 [s]`, schedule utilisation `[0.229, 0.232, 0.052, 0.08, 0.102]` within shares `[0.25, 0.25, 0.25, 0.125, 0.125]`, every frame fits, every task `responseWithinDeadline` | sat — overrun handling is the executive's behaviour (WP-SW-3), not a budget |
| SW-011 memory and CPU budgets per application and partition, reserve policy | `ScheduledTask.utilisation = wcet / period`; `PartitionBudget` (footprint from `codeSize + dataSize` of the partition's tasks against `Partition.memoryBudget`, peak load); `SoftwareBudgets` (`peakLoadMips` = Σ `processorLoadMips` of all components + executive, `allocatedLoadMips` with the new-design contingency of `activePolicy`, `footprint`, `allocatedMemory = executive.partitionMemory`); `SoftwareProcessorBudget :> ProcessorBudget` with `activeSoftwarePolicy` reserves | `sw-timing-budgets`: peak 442 MIPS, allocated 530.4 MIPS, `processorUtilisation = 0.442`, `processorCloses = true` (≤ 0.50); footprint 96.7 MB, allocated 1.024 GB, `memoryUtilisation = 0.256`, `memoryCloses = true`; partition footprints `[48.9, 19.5, 10.0, 5.5, 10.0] MB`, all within their partition memory | sat — growth tracking is the two rows of the policy (`softwarePdrPolicy`, `softwareCdrPolicy`) |
| SW-037 bus allocation: slots per node per frame, bus utilisation budget | `BusSlotAssignment` (node, `slotsPerFrame`, `messageLength`, `activeModes`), `BusSchedule` (`argentBus`: 13 streams in the 64-slot AABP-1 frame — figures typed in and checked against `TethysSoftwareIcds` by the run, F-T08; `streamsFitFrame`, `messagesFitSlots`, `utilisation`, `byteUtilisation`), `BusSlotsInMode`; `BusBudget` in 32 | `sw-timing-budgets`: 36 slots of 64 with every stream (`utilisation = 0.5625`, `byteUtilisation = 0.267`), 32 in modes without the capture mechanisms; `softwareBusBudget.busCloses = false` (0.5625 > 0.50), `softwareBusBudgetCoast.busCloses = true` (0.50 ≤ 0.50) | sat as a model; the bus budget does not close in `proximityOperations`, `capture` and `despin` at the 50 % reserve — kept visible, not resized |
| SW-038 per-application rate, WCET, deadline, jitter; end-to-end latency chains | `ScheduledTask`/`ApplicationTask` (`hostedAtRequiredRate` against `Application.rate`, `deadlineWithinPeriod`, `responseWithinDeadline`); `TaskResponse` (period + WCET + jitter); `LatencyChain` (`legs`, `latency = sum(legs)`, `bound`, `margin`, `withinBound`); `argentLatency` chains `faultDetection` (bus frame → FDIR task) against 0.5 s (TA-010), `safeConfiguration` (detection → mode manager → thermal control → bus → actuator settle) against 2 s (TS-015), `commandDispatch` (bus → command ingest → C&DH → telecom) against the housekeeping period, `telemetrySample` (sample → telemetry output → telecom → safe-rate frame of TI-021) against the safe-mode housekeeping period; `fdirPeriodWithinRequirement` (TC-005); `LatencyBudget` in 32 at the policy's 20 % latency margin | `sw-timing-budgets`: latencies `[0.191, 1.0015, 0.512, 5.7185] [s]` against bounds `[0.5, 2.0, 1.0, 60.0] [s]`, margins `[0.618, 0.499, 0.488, 0.905]`, `allWithinBound = true`, FDIR period 0.0625 s ≤ 0.1 s, all four `latencyCloses = true` | sat |
| SW-245 (WP-SW-4 part) load figures bound from 66 totals | `TimedFlightComputer :> LoadedFlightComputer` binds `processorLoadMips`/`memoryAllocated` to `argentSoftwareBudgets.allocatedLoadMips`/`allocatedMemory`; `TimedCdh`, `TimedTug`, `argentTimed` | `sw-timing-budgets`: `argentTimed.cdh.prime.processorLoadMips = 530.4`, `memoryAllocated = 1.024e9 [B]` | sat |
| SW-246 `ProcessorBudget` consumes per-app sums; `BusBudget`, `LatencyBudget` | see Backbone changes | `sw-timing-budgets`; `TethysBudgets::processorBudget` unchanged in the pinned `budgets` run | sat |

## Verdicts

| Budget | Demand | Capacity × (1 − reserve) | Verdict |
| --- | --- | --- | --- |
| processor (`softwareProcessorBudget`) | 530.4 MIPS (442 peak × 1.20) | 600 MIPS | closes (0.442) |
| memory (`softwareProcessorBudget`) | 1.024 GB partition memory (96.7 MB footprint) | 2.0 GB | closes (0.256) |
| bus, every stream (`softwareBusBudget`) | 36 slots | 32 slots | **does not close** (0.5625) |
| bus, coast (`softwareBusBudgetCoast`) | 32 slots | 32 slots | closes (0.50) |
| fault detection | 0.191 s | 0.4 s (0.5 s × 0.8) | closes |
| safe configuration | 1.0015 s | 1.6 s | closes |
| command dispatch | 0.512 s | 0.8 s | closes |
| telemetry sample to frame | 5.72 s | 48 s | closes |

The demand table (`loadByMode`, `busSlotsByMode`) reads 0 in `launch`: `allFlightModes` of
`TethysTugStructure` starts at `earlyOperations`, so no service or application is active there —
a statement of the mode table, not of the schedule.

## Backbone changes

- `model/30-margin-policy.sysml`: `SoftwareMarginPolicyRow` (processor, memory, bus reserve and
  latency margin per review gate), `softwarePdrPolicy` (0.50/0.50/0.50/0.20), `softwareCdrPolicy`
  (0.35/0.35/0.35/0.10), `activeSoftwarePolicy = softwarePdrPolicy`, `HoldsReserve`.
  `activePolicy` is untouched.
- `model/31-tug-structure.sysml`: `FlightComputer.processorLoadMips` and `memoryAllocated` become
  `default` values, so `TethysFlightTiming::TimedFlightComputer` binds them from the software
  budgets; the figures themselves are unchanged.
- `model/32-budgets.sysml`: `ProcessorBudget` reads `reserve`/`memoryReserve` from
  `activeSoftwarePolicy` (still 0.50), its `loadMips`/`memoryAllocated` are `default`s that
  `SoftwareProcessorBudget` redefines with the per-application sums, and it exposes
  `processorUtilisation`/`memoryUtilisation`; new `BusBudget` (`busCloses`) and `LatencyBudget`
  (`latencyCloses`); new requirements `TS-143` `busBudgetCloses` and `TS-144` `latencyBudgetCloses`,
  satisfied in 66.
