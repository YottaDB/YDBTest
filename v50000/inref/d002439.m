d002439(tstwhat)
	kill ^trace
	view "trace":1:"^trace"
	do @tstwhat
	view "trace":0
	quit

indlvadr
	set indindex="index"		; Force OC_LINEFETCH to force stack leak check initialization in mprof_funcs.c
	for @indindex=1:1:1 d noop	; Indirect index variable in FOR construct generates OC_INDLVADR - cause for stack leak
	set indindex="index"		; Force OC_LINEFETCH to force stack leak check in mprof_funcs.c
	quit

indlvnamadr
	new x,atx			; Force OC_LINEFETCH to force stack leak check initialization in mprof_funcs.c
	set x=1
	set atx="x"
	do zero(.@atx)			; Indirect argument by reference generates OC_INDLVNAMADR
	set atx="x"			; Force OC_LINEFETCH to force stack leak check in mprof_funcs.c
					; Although, for this sub-test, OC_LINEFETCH in zero() triggers the assert.
					; We are just being uniform with the indlvadr sub-test
	quit

zero(arg)
	set arg=0
	quit

noop
	quit
