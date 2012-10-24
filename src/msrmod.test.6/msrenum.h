#ifndef _MG_MSR_ENUM_H
#define _MG_MSR_ENUM_H
enum MsrPmcFlags {
	FLAG_INV = 0x00800000, // Inverts the result of the counter-mask comparison when set, so that both greater than and less than comparisons can be made.
	FLAG_EN  = 0x00400000, // The event logic unit for a UMASK must be disabled by setting IA32_PERFEVTSELx[bit 22] = 0, before writing to IA32_PMCx.
	FLAG_INT = 0x00100000, // When set, the logical processor generates an exception through its local APIC on counter overflow.
	FLAG_PC  = 0x00080000, // When set, the logical processor toggles the PMi pins and increments the counter when events occur; when clear, the processor toggles the PMi pins when the counter overflows.
	FLAG_E   = 0x00040000, // Enables, when set, edge detection of the selected condition. 
	FLAG_OS  = 0x00020000, // Condition is counted only when the logical processor is operating at privilege level 0
	FLAG_USR = 0x00010000, // Condition is counted only when the logical processor is operating at privilege levels 1, 2 or 3
	CMASK_1  = 0x01000000
};

enum MsrPerfEvt {
	LD_BLOCKS_DATA_UNKNOWN                        = 0x0103, // blocked loads due to store buffer blocks with unknown data.
	LD_BLOCKS_STORE_FORWARD                       = 0x0203, // loads blocked by overlapping with store buffer that cannot be forwarded .
	LD_BLOCKS_NO_SR                               = 0x0803, // # of Split loads blocked due to resource not available.
	LD_BLOCKS_ALL_BLOCK                           = 0x1003, // Number of cases where any load is blocked but has no DCU miss.
	MISALIGN_MEM_REF_LOADS                        = 0x0105, // Speculative cache-line split load uops dispatched to L1D.
	MISALIGN_MEM_REF_STORES                       = 0x0205, // Speculative cache-line split Store-address uops dispatched to L1D.
	LD_BLOCKS_PARTIAL_ADDRESS_ALIAS               = 0x0107, // False dependencies in MOB due to partial compare on address.
	LD_BLOCKS_PARTIAL_ALL_STA_BLOCK               = 0x0807, // The number of times that load operations are temporarily blocked because of older stores, with addresses that are not yet known. A load operation may incur more than one block of this type.
	DTLB_LOAD_MISSES_MISS_CAUSES_A_WALK           = 0x0108, // Misses in all TLB levels that cause a page walk of any page size.
	DTLB_LOAD_MISSES_WALK_COMPLETED               = 0x0208, // Misses in all TLB levels that caused page walk completed of any size.
	DTLB_LOAD_MISSES_WALK_DURATION                = 0x0408, // Cycle PMH is busy with a walk.
	DTLB_LOAD_MISSES_STLB_HIT                     = 0x1008, // Number of cache load STLB hits. No page walk.
	INT_MISC_RECOVERY_CYCLES                      = 0x030D, // Cycles waiting to recover after Machine Clears or JEClear. Set Cmask=1. Set Edge to count occurrences.
	INT_MISC_RAT_STALL_CYCLES                     = 0x400D, // Cycles RAT external stall is sent to IDQ for this thread.
	UOPS_ISSUED_ANY                               = 0x010E, // Increments each cycle the # of Uops issued by the RAT to RS. Set Cmask=1, Inv=1, Any=1 to count stalled cycles of this core. Set Cmask=1, Inv=1 to count stalled cycles.
	FP_COMP_OPS_EXE_X87                           = 0x0110, // Counts number of X87 uops executed.
	FP_COMP_OPS_EXE_SSE_FP_PACKED_DOUBLE          = 0x1010, // Counts number of SSE double precision FP packed uops executed.
	FP_COMP_OPS_EXE_SSE_FP_SCALAR_SINGLE          = 0x2010, // Counts number of SSE single precision FP scalar uops executed.
	FP_COMP_OPS_EXE_SSE_PACKED_SINGLE             = 0x4010, // Counts number of SSE single precision FP packed uops executed.
	FP_COMP_OPS_EXE_SSE_SCALAR_DOUBLE             = 0x8010, // Counts number of SSE double precision FP scalar uops executed.
	SIMD_FP_256_PACKED_SINGLE                     = 0x0111, // Counts 256-bit packed single-precision floating-point instructions.
	SIMD_FP_256_PACKED_DOUBLE                     = 0x0211, // Counts 256-bit packed double-precision floating-point instructions.
	ARITH_FPU_DIV_ACTIVE                          = 0x0114, // Cycles that the divider is active, includes INT and FP. Set Edge=1, Cmask=1 to count the number of divides.
	INSTS_WRITTEN_TO_IQ_INSTS                     = 0x0117, // Counts the number of instructions written into the IQ every cycle.
	UNC_CBO_XSNP_RESPONSE_MISS                    = 0x0122, // A snoop misses in some processor core. Must combine with one of the umask values of 20H, 40H, 80H
	UNC_CBO_XSNP_RESPONSE_INVAL                   = 0x0222, // A snoop invalidates a non-modified line in some processor core.
	UNC_CBO_XSNP_RESPONSE_HIT                     = 0x0422, // A snoop hits a non-modified line in some processor core.
	UNC_CBO_XSNP_RESPONSE_HITM                    = 0x0822, // A snoop hits a modified line in some processor core.
	UNC_CBO_XSNP_RESPONSE_INVAL_M                 = 0x1022, // A snoop invalidates a modified line in some processor core.
	UNC_CBO_XSNP_RESPONSE_EXTERNAL_FILTER         = 0x2022, // Filter on cross-core snoops initiated by this Cbox due to external snoop request. Must combine with at least one of 01H, 02H, 04H, 08H, 10H
	UNC_CBO_XSNP_RESPONSE_XCORE_FILTER            = 0x4022, // Filter on cross-core snoops initiated by this Cbox due to processor core memory request.
	UNC_CBO_XSNP_RESPONSE_EVICTION_FILTER         = 0x8022, // Filter on cross-core snoops initiated by this Cbox due to LLC eviction.
	L2_RQSTS_DEMAND_DATA_RD_HIT                   = 0x0124, // Demand Data Read requests that hit L2 cache.
	L2_RQSTS_ALL_DEMAND_DATA_RD                   = 0x0324, // Counts any demand and L1 HW prefetch data load requests to L2.
	L2_RQSTS_RFO_HITS                             = 0x0424, // Counts the number of store RFO requests that hit the L2 cache.
	L2_RQSTS_RFO_MISS                             = 0x0824, // Counts the number of store RFO requests that miss the L2 cache.
	L2_RQSTS_ALL_RFO                              = 0x0C24, // Counts all L2 store RFO requests.
	L2_RQSTS_CODE_RD_HIT                          = 0x1024, // Number of instruction fetches that hit the L2 cache.
	L2_RQSTS_CODE_RD_MISS                         = 0x2024, // Number of instruction fetches that missed the L2 cache.
	L2_RQSTS_ALL_CODE_RD                          = 0x3024, // Counts all L2 code requests.
	L2_RQSTS_PF_HIT                               = 0x4024, // Requests from L2 Hardware prefetcher that hit L2.
	L2_RQSTS_PF_MISS                              = 0x8024, // Requests from L2 Hardware prefetcher that missed L2.
	L2_RQSTS_ALL_PF                               = 0xC024, // Any requests from L2 Hardware prefetchers.
	L2_STORE_LOCK_RQSTS_MISS                      = 0x0127, // RFOs that miss cache lines.
	L2_STORE_LOCK_RQSTS_HIT_E                     = 0x0427, // RFOs that hit cache lines in E state.
	L2_STORE_LOCK_RQSTS_HIT_M                     = 0x0827, // RFOs that hit cache lines in M state.
	L2_STORE_LOCK_RQSTS_ALL                       = 0x0F27, // RFOs that access cache lines in any state.
	L2_L1D_WB_RQSTS_MISS                          = 0x0128, // Not rejected writebacks from L1D to L2 cache lines that missed L2.
	L2_L1D_WB_RQSTS_HIT_S                         = 0x0228, // Not rejected writebacks from L1D to L2 cache lines in S state.
	L2_L1D_WB_RQSTS_HIT_E                         = 0x0428, // Not rejected writebacks from L1D to L2 cache lines in E state.
	L2_L1D_WB_RQSTS_HIT_M                         = 0x0828, // Not rejected writebacks from L1D to L2 cache lines in M state.
	L2_L1D_WB_RQSTS_ALL                           = 0x0F28, // Not rejected writebacks from L1D to L2 cache.
	LONGEST_LAT_CACHE_MISS                        = 0x412E, // This event counts each cache miss condition for references to the last level cache. See Table 19-1
	LONGEST_LAT_CACHE_REFERENCE                   = 0x4F2E, // This event counts requests originating from the core that reference a cache line in the last level cache. See Table 19-1
	UNC_CBO_CACHE_LOOKUP_M                        = 0x0134, // LLC lookup request that access cache and found line in M-state. Must combine with one of the umask values of 10H, 20H, 40H, 80H
	UNC_CBO_CACHE_LOOKUP_E                        = 0x0234, // LLC lookup request that access cache and found line in E-state.
	UNC_CBO_CACHE_LOOKUP_S                        = 0x0434, // LLC lookup request that access cache and found line in S-state.
	UNC_CBO_CACHE_LOOKUP_I                        = 0x0834, // LLC lookup request that access cache and found line in I-state.
	UNC_CBO_CACHE_LOOKUP_READ_FILTER              = 0x1034, // Filter on processor core initiated cacheable read requests. Must combine with at least one of 01H, 02H, 04H, 08H.
	UNC_CBO_CACHE_LOOKUP_WRITE_FILTER             = 0x2034, // Filter on processor core initiated cacheable write requests. Must combine with at least one of 01H, 02H, 04H, 08H.
	UNC_CBO_CACHE_LOOKUP_EXTSNP_FILTER            = 0x4034, // Filter on external snoop requests. Must combine with at least one of 01H, 02H, 04H, 08H.
	UNC_CBO_CACHE_LOOKUP_ANY_REQUEST_FILTER       = 0x8034, // Filter on any IRQ or IPQ initiated requests including uncacheable, non-coherent requests. Must combine with at least one of 01H, 02H, 04H, 08H.
	CPU_CLK_UNHALTED_THREAD_P                     = 0x003C, // Counts the number of thread cycles while the thread is not in a halt state. The thread enters the halt state when it is running the HLT instruction. The core frequency may change from time to time due to power or thermal throttling. See Table 19-1
	CPU_CLK_THREAD_UNHALTED_REF_XCLK              = 0x013C, // Increments at the frequency of XCLK (100 MHz) when not halted. See Table 19-1
	L1D_PEND_MISS_PENDING                         = 0x0148, // Increments the number of outstanding L1D misses every cycle. Set Cmask=1 and Edge=1 to count occurrences. PMC2 only: Set Cmask=1 to count cycles.
	DTLB_STORE_MISSES_MISS_CAUSES_A_WALK          = 0x0149, // Miss in all TLB levels causes an page walk of any page size (4K/2M/4M/1G).
	DTLB_STORE_MISSES_WALK_COMPLETED              = 0x0249, // Miss in all TLB levels causes a page walk that completes of any page size (4K/2M/4M/1G).
	DTLB_STORE_MISSES_WALK_DURATION               = 0x0449, // Cycles PMH is busy with this walk.
	DTLB_STORE_MISSES_STLB_HIT                    = 0x1049, // Store operations that miss the first TLB level but hit the second and do not cause page walks.
	LOAD_HIT_PRE_SW_PF                            = 0x014C, // Not SW-prefetch load dispatches that hit fill buffer allocated for S/W prefetch.
	LOAD_HIT_PRE_HW_PF                            = 0x024C, // Not SW-prefetch load dispatches that hit fill buffer allocated for H/W prefetch.
	HW_PRE_REQ_DL1_MISS                           = 0x024E, // Hardware Prefetch requests that miss the L1D cache. A request is being counted each time it access the cache & miss it, including if a block is applicable or if hit the Fill Buffer for example. This accounts for both L1 streamer and IP-based (IPP) HW prefetchers.
	L1D_REPLACEMENT                               = 0x0151, // Counts the number of lines brought into the L1 data cache.
	L1D_ALLOCATED_IN_M                            = 0x0251, // Counts the number of allocations of modified L1D cache lines.
	L1D_EVICTION                                  = 0x0451, // Counts the number of modified lines evicted from the L1 data cache due to replacement.
	L1D_ALL_M_REPLACEMENT                         = 0x0851, // Cache lines in M state evicted out of L1D due to Snoop HitM or dirty line replacement.
	PARTIAL_RAT_STALLS_FLAGS_MERGE_UOP            = 0x2059, // Increments the number of flags-merge uops in flight each cycle. Set Cmask=1 to count cycles.
	PARTIAL_RAT_STALLS_SLOW_LEA_WINDOW            = 0x4059, // Cycles with at least one slow LEA uop allocated.
	PARTIAL_RAT_STALLS_MUL_SINGLE_UOP             = 0x8059, // Number of Multiply packed/scalar single precision uops allocated.
	RESOURCE_STALLS2_ALL_FL_EMPTY                 = 0x0C5B, // Cycles stalled due to free list empty. PMC0-3 only regardless HTT
	RESOURCE_STALLS2_ALL_PRF_CONTROL              = 0x0F5B, // Cycles stalled due to control structures full for physical registers.
	RESOURCE_STALLS2_BOB_FULL                     = 0x405B, // Cycles Allocator is stalled due Branch Order Buffer.
	RESOURCE_STALLS2_OOO_RSRC                     = 0x4F5B, // Cycles stalled due to out of order resources full.
	CPL_CYCLES_RING0                              = 0x015C, // Unhalted core cycles when the thread is in ring 0. Use Edge to count transition
	CPL_CYCLES_RING123                            = 0x025C, // Unhalted core cycles when the thread is not in ring 0.
	RS_EVENTS_EMPTY_CYCLES                        = 0x015E, // Cycles the RS is empty for the thread.
	OFFCORE_REQUESTS_OUTSTANDING_DEMAND_DATA_RD   = 0x0160, // Offcore outstanding Demand Data Read transactions in SQ to uncore. Set Cmask=1 to count cycles.
	OFFCORE_REQUESTS_OUTSTANDING_DEMAND_RFO       = 0x0460, // Offcore outstanding RFO store transactions in SQ to uncore. Set Cmask=1 to count cycles.
	OFFCORE_REQUESTS_OUTSTANDING_ALL_DATA_RD      = 0x0860, // Offcore outstanding cacheable data read transactions in SQ to uncore. Set Cmask=1 to count cycles.
	LOCK_CYCLES_SPLIT_LOCK_UC_LOCK_DURATION       = 0x0163, // Cycles in which the L1D and L2 are locked, due to a UC lock or split lock.
	LOCK_CYCLES_CACHE_LOCK_DURATION               = 0x0263, // Cycles in which the L1D is locked.
	IDQ_EMPTY                                     = 0x0279, // Counts cycles the IDQ is empty.
	IDQ_MITE_UOPS                                 = 0x0479, // Increment each cycle # of uops delivered to IDQ from MITE path. Set Cmask=1 to count cycles. Can combine Umask 04H and 20H
	IDQ_DSB_UOPS                                  = 0x0879, // Increment each cycle. # of uops delivered to IDQ from DSB path. Set Cmask=1 to count cycles. Can combine Umask 08H and 10H
	IDQ_MS_DSB_UOPS                               = 0x1079, // Increment each cycle # of uops delivered to IDQ when MS busy by DSB. Set Cmask=1 to count cycles MS is busy. Set Cmask=1 and Edge=1 to count MS activations. Can combine Umask 08H and 10H
	IDQ_MS_MITE_UOPS                              = 0x2079, // Increment each cycle # of uops delivered to IDQ when MS is busy by MITE. Set Cmask=1 to count cycles. Can combine Umask 04H and 20H
	IDQ_MS_UOPS                                   = 0x3079, // Increment each cycle # of uops delivered to IDQ from MS by either DSB or MITE. Set Cmask=1 to count cycles. Can combine Umask 04H, 08H and 30H
	UNC_ARB_TRK_OCCUPANCY_ALL                     = 0x0180, // Counts cycles weighted by the number of requests waiting for data returning from the memory controller. Accounts for coherent and non-coherent requests initiated by IA cores, processor graphic units, or LLC. Counter 0 only
	ICACHE_MISSES                                 = 0x0280, // Number of Instruction Cache, Streaming Buffer and Victim Cache Misses. Includes UC accesses.
	UNC_ARB_TRK_REQUEST_ALL                       = 0x0181, // Counts the number of coherent and in-coherent requests initiated by IA cores, processor graphic units, or LLC.
	UNC_ARB_TRK_REQUEST_WRITES                    = 0x2081, // Counts the number of allocated write entries, include full, partial, and LLC evictions.
	UNC_ARB_TRK_REQUEST_EVICTIONS                 = 0x8081, // Counts the number of LLC evictions allocated.
	UNC_ARB_COH_TRK_OCCUPANCY_ALL                 = 0x0183, // Cycles weighted by number of requests pending in Coherency Tracker. Counter 0 only
	UNC_ARB_COH_TRK_REQUEST_ALL                   = 0x0184, // Number of requests allocated in Coherency Tracker.
	ITLB_MISSES_MISS_CAUSES_A_WALK                = 0x0185, // Misses in all ITLB levels that cause page walks.
	ITLB_MISSES_WALK_COMPLETED                    = 0x0285, // Misses in all ITLB levels that cause completed page walks.
	ITLB_MISSES_WALK_DURATION                     = 0x0485, // Cycle PMH is busy with a walk.
	ITLB_MISSES_STLB_HIT                          = 0x1085, // Number of cache load STLB hits. No page walk.
	ILD_STALL_LCP                                 = 0x0187, // Stalls caused by changing prefix length of the instruction.
	ILD_STALL_IQ_FULL                             = 0x0487, // Stall cycles due to IQ is full.
	BR_INST_EXEC_COND                             = 0x0188, // Qualify conditional near branch instructions executed, but not necessarily retired. Must combine with umask 40H, 80H
	BR_INST_EXEC_DIRECT_JMP                       = 0x0288, // Qualify all unconditional near branch instructions excluding calls and indirect branches. Must combine with umask 80H
	BR_INST_EXEC_INDIRECT_JMP_NON_CALL_RET        = 0x0488, // Qualify executed indirect near branch instructions that are not calls nor returns. Must combine with umask 80H
	BR_INST_EXEC_RETURN_NEAR                      = 0x0888, // Qualify indirect near branches that have a return mnemonic. Must combine with umask 80H
	BR_INST_EXEC_DIRECT_NEAR_CALL                 = 0x1088, // Qualify unconditional near call branch instructions, excluding non call branch, executed. Must combine with umask 80H
	BR_INST_EXEC_INDIRECT_NEAR_CALL               = 0x2088, // Qualify indirect near calls, including both register and memory indirect, executed. Must combine with umask 80H
	BR_INST_EXEC_NONTAKEN                         = 0x4088, // Qualify non-taken near branches executed. Applicable to umask 01H only
	BR_INST_EXEC_TAKEN                            = 0x8088, // Qualify taken near branches executed. Must combine with 01H,02H, 04H, 08H, 10H, 20H.
	BR_INST_EXEC_ALL_BRANCHES                     = 0xFF88, // Counts all near executed branches (not necessarily retired).
	BR_MISP_EXEC_COND                             = 0x0189, // Qualify conditional near branch instructions mispredicted. Must combine with umask 40H, 80H
	BR_MISP_EXEC_INDIRECT_JMP_NON_CALL_RET        = 0x0489, // Qualify mispredicted indirect near branch instructions that are not calls nor returns. Must combine with umask 80H
	BR_MISP_EXEC_RETURN_NEAR                      = 0x0889, // Qualify mispredicted indirect near branches that have a return mnemonic. Must combine with umask 80H
	BR_MISP_EXEC_DIRECT_NEAR_CALL                 = 0x1089, // Qualify mispredicted unconditional near call branch instructions, excluding non call branch, executed. Must combine with umask 80H
	BR_MISP_EXEC_INDIRECT_NEAR_CALL               = 0x2089, // Qualify mispredicted indirect near calls, including both register and memory indirect, executed. Must combine with umask 80H
	BR_MISP_EXEC_NONTAKEN                         = 0x4089, // Qualify mispredicted non-taken near branches executed,. Applicable to umask 01H only
	BR_MISP_EXEC_TAKEN                            = 0x8089, // Qualify mispredicted taken near branches executed. Must combine with 01H,02H, 04H, 08H, 10H, 20H
	BR_MISP_EXEC_ALL_BRANCHES                     = 0xFF89, // Counts all near executed branches (not necessarily retired).
	IDQ_UOPS_NOT_DELIVERED_CORE                   = 0x019C, // Count number of non-delivered uops to RAT per thread. Use Cmask to qualify uop b/w
	UOPS_DISPATCHED_PORT_PORT_0                   = 0x01A1, // Cycles which a Uop is dispatched on port 0.
	UOPS_DISPATCHED_PORT_PORT_1                   = 0x02A1, // Cycles which a Uop is dispatched on port 1.
	UOPS_DISPATCHED_PORT_PORT_2_LD                = 0x04A1, // Cycles which a load uop is dispatched on port 2.
	UOPS_DISPATCHED_PORT_PORT_2_STA               = 0x08A1, // Cycles which a store address uop is dispatched on port 2.
	UOPS_DISPATCHED_PORT_PORT_2                   = 0x0CA1, // Cycles which a Uop is dispatched on port 2.
	UOPS_DISPATCHED_PORT_PORT_3_LD                = 0x10A1, // Cycles which a load uop is dispatched on port 3.
	UOPS_DISPATCHED_PORT_PORT_3_STA               = 0x20A1, // Cycles which a store address uop is dispatched on port 3.
	UOPS_DISPATCHED_PORT_PORT_3                   = 0x30A1, // Cycles which a Uop is dispatched on port 3.
	UOPS_DISPATCHED_PORT_PORT_4                   = 0x40A1, // Cycles which a Uop is dispatched on port 4.
	UOPS_DISPATCHED_PORT_PORT_5                   = 0x80A1, // Cycles which a Uop is dispatched on port 5.
	RESOURCE_STALLS_ANY                           = 0x01A2, // Cycles Allocation is stalled due to Resource Related reason.
	RESOURCE_STALLS_LB                            = 0x02A2, // Counts the cycles of stall due to lack of load buffers.
	RESOURCE_STALLS_RS                            = 0x04A2, // Cycles stalled due to no eligible RS entry available.
	RESOURCE_STALLS_SB                            = 0x08A2, // Cycles stalled due to no store buffers available. (not including draining form sync).
	RESOURCE_STALLS_ROB                           = 0x10A2, // Cycles stalled due to re-order buffer full.
	RESOURCE_STALLS_FCSW                          = 0x20A2, // Cycles stalled due to writing the FPU control word.
	RESOURCE_STALLS_MXCSR                         = 0x40A2, // Cycles stalled due to the MXCSR register rename occurring to close to a previous MXCSR rename.
	RESOURCE_STALLS_OTHER                         = 0x80A2, // Cycles stalled while execution was stalled due to other resource issues.
	CYCLE_ACTIVITY_CYCLES_L2_PENDING              = 0x01A3, // Cycles with pending L2 miss loads. Set AnyThread to count per core.
	CYCLE_ACTIVITY_CYCLES_L1D_PENDING             = 0x02A3, // Cycles with pending L1 cache miss loads.Set AnyThread to count per core. PMC2 only
	CYCLE_ACTIVITY_CYCLES_NO_DISPATCH             = 0x04A3, // Cycles of dispatch stalls. Set AnyThread to count per core. PMC0-3 only
	DSB2MITE_SWITCHES_COUNT                       = 0x01AB, // Number of DSB to MITE switches.
	DSB2MITE_SWITCHES_PENALTY_CYCLES              = 0x02AB, // Cycles DSB to MITE switches caused delay.
	DSB_FILL_OTHER_CANCEL                         = 0x02AC, // Cases of cancelling valid DSB fill not because of exceeding way limit.
	DSB_FILL_EXCEED_DSB_LINES                     = 0x08AC, // DSB Fill encountered > 3 DSB lines.
	DSB_FILL_ALL_CANCEL                           = 0x0AAC, // Cases of cancelling valid Decode Stream Buffer (DSB) fill not because of exceeding way limit.
	ITLB_ITLB_FLUSH                               = 0x01AE, // Counts the number of ITLB flushes, includes 4k/2M/4M pages.
	OFFCORE_REQUESTS_DEMAND_DATA_RD               = 0x01B0, // Demand data read requests sent to uncore.
	OFFCORE_REQUESTS_DEMAND_RFO                   = 0x04B0, // Demand RFO read requests sent to uncore, including regular RFOs, locks, ItoM.
	OFFCORE_REQUESTS_ALL_DATA_RD                  = 0x08B0, // Data read requests sent to uncore (demand and prefetch).
	UOPS_DISPATCHED_THREAD                        = 0x01B1, // Counts total number of uops to be dispatched per-thread each cycle. Set Cmask = 1, INV =1 to count stall cycles. PMC0-3 only regardless HTT
	UOPS_DISPATCHED_CORE                          = 0x02B1, // Counts total number of uops to be dispatched per-core each cycle. Do not need to set ANY
	OFFCORE_REQUESTS_BUFFER_SQ_FULL               = 0x01B2, // Offcore requests buffer cannot take more entries for this thread core.
	AGU_BYPASS_CANCEL_COUNT                       = 0x01B6, // Counts executed load operations with all the following traits: 1. addressing of the format [base + offset], 2. the offset is between 1 and 2047, 3. the address specified in the base register is in one page and the address [base+offset] is in another page.
	OFF_CORE_RESPONSE_0                           = 0x01B7, // see Section 18_8.5, Off-core Response Performance Monitoring. Requires MSR 01A6H
	OFF_CORE_RESPONSE_1                           = 0x01BB, // See Section 18_8.5, Off-core Response Performance Monitoring. Requires MSR 01A7H
	TLB_FLUSH_DTLB_THREAD                         = 0x01BD, // DTLB flush attempts of the thread-specific entries.
	TLB_FLUSH_STLB_ANY                            = 0x20BD, // Count number of STLB flush attempts.
	L1D_BLOCKS_BANK_CONFLICT_CYCLES               = 0x05BF, // Cycles when dispatched loads are cancelled due to L1D bank conflicts with other load ports. cmask=1
	INST_RETIRED_ANY_P                            = 0x00C0, // Number of instructions at retirement. See Table 19-1
	INST_RETIRED_ALL                              = 0x01C0, // Precise instruction retired event with HW to reduce effect of PEBS shadow in IP distribution. PMC1 only; Must quiesce other PMCs.
	OTHER_ASSISTS_ITLB_MISS_RETIRED               = 0x02C1, // Instructions that experienced an ITLB miss.
	OTHER_ASSISTS_AVX_STORE                       = 0x08C1, // Number of assists associated with 256-bit AVX store operations.
	OTHER_ASSISTS_AVX_TO_SSE                      = 0x10C1, // Number of transitions from AVX-256 to legacy SSE when penalty applicable.
	OTHER_ASSISTS_SSE_TO_AVX                      = 0x20C1, // Number of transitions from SSE to AVX-256 when penalty applicable.
	UOPS_RETIRED_ALL                              = 0x01C2, // Counts the number of micro-ops retired, Use cmask=1 and invert to count active cycles or stalled cycles. Supports PEBS
	UOPS_RETIRED_RETIRE_SLOTS                     = 0x02C2, // Counts the number of retirement slots used each cycle.
	MACHINE_CLEARS_MEMORY_ORDERING                = 0x02C3, // Counts the number of machine clears due to memory order conflicts.
	MACHINE_CLEARS_SMC                            = 0x04C3, // Counts the number of times that a program writes to a code section.
	MACHINE_CLEARS_MASKMOV                        = 0x20C3, // Counts the number of executed AVX masked load operations that refer to an illegal address range with the mask bits set to 0.
//	BR_INST_RETIRED_ALL_BRANCHES                  = 0x00C4, // Branch instructions at retirement. See Table 19-1
	BR_INST_RETIRED_CONDITIONAL                   = 0x01C4, // Counts the number of conditional branch instructions retired. Supports PEBS
	BR_INST_RETIRED_NEAR_CALL                     = 0x02C4, // Direct and indirect near call instructions retired.
	BR_INST_RETIRED_ALL_BRANCHES                  = 0x04C4, // Counts the number of branch instructions retired.
	BR_INST_RETIRED_NEAR_RETURN                   = 0x08C4, // Counts the number of near return instructions retired.
	BR_INST_RETIRED_NOT_TAKEN                     = 0x10C4, // Counts the number of not taken branch instructions retired.
	BR_INST_RETIRED_NEAR_TAKEN                    = 0x20C4, // Number of near taken branches retired.
	BR_INST_RETIRED_FAR_BRANCH                    = 0x40C4, // Number of far branches retired.
//	BR_MISP_RETIRED_ALL_BRANCHES                  = 0x00C5, // Mispredicted branch instructions at retirement. See Table 19-1
	BR_MISP_RETIRED_CONDITIONAL                   = 0x01C5, // Mispredicted conditional branch instructions retired. Supports PEBS
	BR_MISP_RETIRED_NEAR_CALL                     = 0x02C5, // Direct and indirect mispredicted near call instructions retired.
	BR_MISP_RETIRED_ALL_BRANCHES                  = 0x04C5, // Mispredicted macro branch instructions retired.
	BR_MISP_RETIRED_NOT_TAKEN                     = 0x10C5, // Mispredicted not taken branch instructions retired.
	BR_MISP_RETIRED_TAKEN                         = 0x20C5, // Mispredicted taken branch instructions retired.
	FP_ASSIST_X87_OUTPUT                          = 0x02CA, // Number of X87 assists due to output value.
	FP_ASSIST_X87_INPUT                           = 0x04CA, // Number of X87 assists due to input value.
	FP_ASSIST_SIMD_OUTPUT                         = 0x08CA, // Number of SIMD FP assists due to output values.
	FP_ASSIST_SIMD_INPUT                          = 0x10CA, // Number of SIMD FP assists due to input values.
	FP_ASSIST_ANY                                 = 0x1ECA, // Cycles with any input/output SSE or FP assists.
	ROB_MISC_EVENTS_LBR_INSERTS                   = 0x20CC, // Count cases of saving new LBR records by hardware.
	MEM_TRANS_RETIRED_LOAD_LATENCY                = 0x01CD, // Sample loads with specified latency threshold. PMC3 only. Specify threshold in MSR 0x3F6
	MEM_TRANS_RETIRED_PRECISE_STORE               = 0x02CD, // Sample stores and collect precise store operation via PEBS record. PMC3 only. See Section 18.8.4.3
	MEM_UOP_RETIRED_LOADS                         = 0x01D0, // Qualify retired memory uops that are loads. Combine with umask 10H, 20H, 40H, 80H. Supports PEBS. PMC0-3 only regardless HTT.
	MEM_UOP_RETIRED_STORES                        = 0x02D0, // Qualify retired memory uops that are stores. Combine with umask 10H, 20H, 40H, 80H.
	MEM_UOP_RETIRED_STLB_MISS                     = 0x10D0, // Qualify retired memory uops with STLB miss. Must combine with umask 01H, 02H, to produce counts.
	MEM_UOP_RETIRED_LOCK                          = 0x20D0, // Qualify retired memory uops with lock. Must combine with umask 01H, 02H, to produce counts.
	MEM_UOP_RETIRED_SPLIT                         = 0x40D0, // Qualify retired memory uops with line split. Must combine with umask 01H, 02H, to produce counts.
	MEM_UOP_RETIRED_ALL                           = 0x80D0, // Qualify any retired memory uops. Must combine with umask 01H, 02H, to produce counts.
	MEM_LOAD_UOPS_RETIRED_L1_HIT                  = 0x01D1, // Retired load uops with L1 cache hits as data sources. Supports PEBS. PMC0-3 only regardless HTT
	MEM_LOAD_UOPS_RETIRED_L2_HIT                  = 0x02D1, // Retired load uops with L2 cache hits as data sources.
	MEM_LOAD_UOPS_RETIRED_LLC_HIT                 = 0x04D1, // Retired load uops which data sources were data hits in LLC without snoops required. Supports PEBS
	MEM_LOAD_UOPS_RETIRED_LLC_MISS                = 0x20D1, // Retired load uops which data sources were data missed LLC (excluding unknown data source). Supports PEBS
	MEM_LOAD_UOPS_RETIRED_HIT_LFB                 = 0x40D1, // Retired load uops which data sources were load uops missed L1 but hit FB due to preceding miss to the same cache line with data not ready.
	MEM_LOAD_UOPS_LLC_HIT_RETIRED_XSNP_MISS       = 0x01D2, // Retired load uops which data sources were LLC hit and cross-core snoop missed in on-pkg core cache. Supports PEBS. PMC0-3 only regardless HTT
	MEM_LOAD_UOPS_LLC_HIT_RETIRED_XSNP_HIT        = 0x02D2, // Retired load uops which data sources were LLC and cross-core snoop hits in on-pkg core cache.
	MEM_LOAD_UOPS_LLC_HIT_RETIRED_XSNP_HITM       = 0x04D2, // Retired load uops which data sources were HitM responses from shared LLC.
	MEM_LOAD_UOPS_LLC_HIT_RETIRED_XSNP_NONE       = 0x08D2, // Retired load uops which data sources were hits in LLC without snoops required.
	MEM_LOAD_UOPS_MISC_RETIRED_LLC_MISS           = 0x02D4, // Retired load uops with unknown information as data source in cache serviced the load. Supports PEBS. PMC0-3 only regardless HTT
	BACLEARS_ANY                                  = 0x01E6, // Counts the number of times the front end is re-steered, mainly when the BPU cannot provide a correct prediction and this is corrected by other branch handling mechanisms at the front end.
	L2_TRANS_DEMAND_DATA_RD                       = 0x01F0, // Demand Data Read requests that access L2 cache.
	L2_TRANS_RFO                                  = 0x02F0, // RFO requests that access L2 cache.
	L2_TRANS_CODE_RD                              = 0x04F0, // L2 cache accesses when fetching instructions.
	L2_TRANS_ALL_PF                               = 0x08F0, // L2 or LLC HW prefetches that access L2 cache. including rejects
	L2_TRANS_L1D_WB                               = 0x10F0, // L1D writebacks that access L2 cache.
	L2_TRANS_L2_FILL                              = 0x20F0, // L2 fill requests that access L2 cache.
	L2_TRANS_L2_WB                                = 0x40F0, // L2 writebacks that access L2 cache.
	L2_TRANS_ALL_REQUESTS                         = 0x80F0, // Transactions accessing L2 pipe.
	L2_LINES_IN_I                                 = 0x01F1, // L2 cache lines in I state filling L2. Counting does not cover rejects.
	L2_LINES_IN_S                                 = 0x02F1, // L2 cache lines in S state filling L2. Counting does not cover rejects.
	L2_LINES_IN_E                                 = 0x04F1, // L2 cache lines in E state filling L2. Counting does not cover rejects.
	L2_LINES_IN_ALL                               = 0x07F1, // L2 cache lines filling L2. Counting does not cover rejects.
	L2_LINES_OUT_DEMAND_CLEAN                     = 0x01F2, // Clean L2 cache lines evicted by demand.
	L2_LINES_OUT_DEMAND_DIRTY                     = 0x02F2, // Dirty L2 cache lines evicted by demand.
	L2_LINES_OUT_PF_CLEAN                         = 0x04F2, // Clean L2 cache lines evicted by L2 prefetch.
	L2_LINES_OUT_PF_DIRTY                         = 0x08F2, // Dirty L2 cache lines evicted by L2 prefetch.
	L2_LINES_OUT_DIRTY_ALL                        = 0x0AF2, // Dirty L2 cache lines filling the L2. Counting does not cover rejects.
	SQ_MISC_SPLIT_LOCK                            = 0x10F4, // Split locks in SQ.
	SOME_ENORMOUS_NUMBER                          = 0x12345678
};
#endif // _MG_MSR_ENUM_H
