#
#------------------------------------------------------------ .data section macros
#
# Debug the use of the .data macros as follows:
# as -al -am msrtest.s | grep '\.int'
#
.macro set_mem iop ecx=0 eax=0 edx=0
	.int	\iop, \ecx, \eax, \edx
.endm

.macro mem_nop
	set_mem 0
.endm

.macro mem_rd ecx=0 eax=0 edx=0
	set_mem 1 \ecx \eax \edx
.endm

.macro mem_wr ecx=0 eax=0 edx=0
	set_mem 2 \ecx \eax \edx
.endm

.macro mem_stop
	set_mem 3
.endm

.macro mem_rd_tsc
	set_mem 4
.endm

# IA32_FIXED_CTR_CTRL table: 3C:35-17/251 image: 3B:18-5/127
.macro mem_wr_gffc ctrl_dw=0
	mem_wr 0x38d \ctrl_dw
.endm

# IA32_PERF_GLOBAL_CTRL table: 3C:35-19/253 image: 3B:18-36/158
.macro mem_wr_gpmc pmc=0 ffc=0
	mem_wr 0x38f \pmc \ffc
.endm

.macro _do_mem_ffcx iop ctridx eax edx
	.ifc \ctridx, 0
		set_mem \iop 0x309 \eax \edx	# INSTR_RETIRED.ANY
	.else
	 .ifc \ctridx, 1
		set_mem \iop 0x30a \eax \edx	# CPU_CLK_UNHALTED.CORE
	 .else
	  .ifc \ctridx, 2
		set_mem \iop 0x30b \eax \edx	# CPU_CLK_UNHALTED.REF
	  .else
		.warning "Unknown IA32_FIXED_CTRx"
	  .endif
	 .endif
	.endif
.endm

.macro mem_wr_ffcx idx eax=0 edx=0
	_do_mem_ffcx 2 \idx \eax \edx	
.endm
.macro mem_rd_ffcx idx 
	_do_mem_ffcx 1 \idx 0 0
.endm

.macro _do_mem_pesx iop evtidx eax edx
	.ifc \evtidx, 0
		set_mem \iop 0x186 \eax \edx
	.else
	 .ifc \evtidx, 1
		set_mem \iop 0x187 \eax \edx
	 .else
	  .ifc \evtidx, 2
		set_mem \iop 0x188 \eax \edx
	  .else
	   .ifc \evtidx, 3
		set_mem \iop 0x189 \eax \edx
	   .else
	    .warning "Unknown IA32_PERFEVTSELx counter"
	   .endif
	  .endif
	 .endif
	.endif
.endm

.macro mem_wr_pesx evtidx eax=0 edx=0
	_do_mem_pesx 2 \evtidx \eax \edx
.endm

.macro mem_rd_pesx evtidx
	_do_mem_pesx 1 \evtidx 0 0
.endm

.macro _do_mem_pmcx iop pmcidx eax edx
	.ifc \pmcidx, 0
		set_mem \iop 0xc1 \eax \edx
	.else
	 .ifc \pmcidx, 1
		set_mem \iop 0xc2 \eax \edx
	 .else
	  .ifc \pmcidx, 2
		set_mem \iop 0xc3 \eax \edx
	  .else
	   .ifc \pmcidx, 3
		set_mem \iop 0xc4 \eax \edx
	   .else
	    .warning "Unknown IA32_PMCx counter"
	   .endif
	  .endif
	 .endif
	.endif
.endm

.macro mem_wr_pmcx pmcidx eax=0 edx=0
	_do_mem_pmcx 2 \pmcidx \eax \edx
.endm

.macro mem_rd_pmcx pmcidx
	_do_mem_pmcx 1 \pmcidx 0 0
.endm



#-------------------------------------------------------- runtime macros
.macro set_msr_io iop r_base idx ecx=$0 eax=$0 edx=$0
	movl	\iop, 0x10 * \idx + 0x00(\r_base)	# .op = MSR_WRITE
	movl	\ecx, 0x10 * \idx + 0x04(\r_base)	# .ecx = \r_ecx
	movl	\eax, 0x10 * \idx + 0x08(\r_base)	# .eax = \r_eax
	movl	\edx, 0x10 * \idx + 0x0c(\r_base)	# .edx = \r_edx
.endm

.macro rd_msr_io r_base idx ecx 
	set_msr_io $1 \r_base \idx \ecx
.endm

.macro wr_msr_io r_base idx ecx:req eax=$0 edx=$0
	set_msr_io $2 \r_base \idx \ecx \eax \edx
.endm

.macro wr_msr_stop r_base idx
	set_msr_io $3 \r_base \idx
.endm

.macro wr_msr_noop r_base idx
	set_msr_io $0 \r_base \idx
.endm

.macro rd_tsc r_base idx
	set_msr_io $4 \r_base \idx
.endm

# IA32_FIXED_CTR_CTRL table: 3C:35-17/251 image: 3B:18-5/127
.macro wr_msr_gffc r_base idx ctrl_dw=$0
	wr_msr_io \r_base \idx $0x38d \ctrl_dw
.endm

# IA32_PERF_GLOBAL_CTRL table: 3C:35-19/253 image: 3B:18-36/158
.macro wr_msr_gpmc r_base idx pmc=$0 ffc=$0
	wr_msr_io \r_base \idx $0x38f \pmc \ffc
.endm

.macro _do_msr_ia32_fixed_ctr iop r_base idx ctr_idx eax edx
.ifc \ctr_idx, 0
	set_msr_io \iop \r_base \idx $0x309 \eax \edx	# INSTR_RETIRED.ANY
.else
 .ifc \ctr_idx, 1
	set_msr_io \iop \r_base \idx $0x30a \eax \edx	# CPU_CLK_UNHALTED.CORE
 .else
  .ifc \ctr_idx, 2
	set_msr_io \iop \r_base \idx $0x30b \eax \edx	# CPU_CLK_UNHALTED.REF
  .else
	.warning "Unknown IA32_FIXED_CTRx"
  .endif
 .endif
.endif
.endm

.macro wr_msr_ffcx r_base idx ctr_idx eax=$0 edx=$0
	_do_msr_ia32_fixed_ctr $2 \r_base \idx \ctr_idx \eax \edx
.endm

.macro rd_msr_ffcx r_base idx ctr_idx
	_do_msr_ia32_fixed_ctr $1 \r_base \idx \ctr_idx $0 $0
.endm

.macro _do_msr_perfevtsel iop r_base idx evtidx eax edx
.ifc \evtidx, 0
	set_msr_io \iop \r_base \idx $0x186 \eax \edx
.else
 .ifc \evtidx, 1
	set_msr_io \iop \r_base \idx $0x187 \eax \edx
 .else
  .ifc \evtidx, 2
	set_msr_io \iop \r_base \idx $0x188 \eax \edx
  .else
   .ifc \evtidx, 3
	set_msr_io \iop \r_base \idx $0x189 \eax \edx
   .else
    .warning "Unknown IA32_PERFEVTSELx counter"
   .endif
  .endif
 .endif
.endif
.endm

.macro wr_msr_pesx r_base idx evtidx eax=$0
	_do_msr_perfevtsel $2 \r_base \idx \evtidx \eax $0
.endm

.macro rd_msr_pesx r_base idx evtidx
	_do_msr_perfevtsel $1 \r_base \idx \evtidx $0 $0
.endm

.macro _do_msr_pmcx iop r_base idx evtidx eax edx
.ifc \evtidx, 0
	set_msr_io \iop \r_base \idx $0xc1 \eax \edx
.else
 .ifc \evtidx, 1
	set_msr_io \iop \r_base \idx $0xc2 \eax \edx
 .else
  .ifc \evtidx, 2
	set_msr_io \iop \r_base \idx $0xc3 \eax \edx
  .else
   .ifc \evtidx, 3
	set_msr_io \iop \r_base \idx $0xc4 \eax \edx
   .else
    .warning "Unknown IA32_PMCx counter"
   .endif
  .endif
 .endif
.endif
.endm

.macro wr_msr_pmcx r_base idx evtidx eax=$0 edx=$0
	_do_msr_pmcx $2 \r_base \idx \evtidx \eax \edx
.endm
.macro rd_msr_pmcx r_base idx evtidx
	_do_msr_pmcx $1 \r_base \idx \evtidx $0 $0
.endm
