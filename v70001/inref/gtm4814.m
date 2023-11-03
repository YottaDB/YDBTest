;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-4814 - Verify M-profiling (VIEW "TRACE") restored after ZSTEP
;
; The test very simply sets up a trace, executes a few lines to generate some trace data,
; then does a BREAK command to allow 3 ZSTEP commands to come in after which a ZCONTINUE
; command is seen to resume the module. Once we dump the trace, we expect to see the trace
; stop for the 3 ZSTEP commands and then resume at gtm4814+14 and continue to the end
; which is gtm4814+18.
;
gtm4814
	write !,"# Turning on trace to ^trace global",!
	view "trace":1:"^trace"		; Start tracing
	write !,"# Executing a few statements so the trace does something",!
	;
	; Execute a few other statements to give it something to trace
	;
	set x=1
	set y=2
	write !,"# Breaking to invoke ZSTEP commands",!
	break				; Stop here to accept direct mode commands (3 ZSTEPs and a ZCONTINUE)
	set z=3
	set a=26
	set b=25
	write !,"# Resumed execution, should see more lines traced in the trace dump below (starting with line 14):",!
	set c=24
	set d=23
	set e=22
	write !,"# Turn off tracing",!
	view "trace":0
	write !,"# Dump the trace records to verify the trace was restored after the zstep commands. Expecting",!
	write "# to see statements executed to pick back up at line 14 and continue through line 19:",!
	zwrite ^trace
	write !
	quit

;
; This next test turns things around. It starts with a break and some direct mode ZSTEP commands, then
; enables tracing while continuing to ZSTEP and see if it interfers with the ZSTEPs. So this part of the
; test just gives a bunch of statements we can ZSTEP through.
;
gtm4814B
	break
	set a=1
	set b=2
	write !,"# Turning on trace by ZSTEPing the VIEW command to enable it. Note, no ZSTEPs after this line",!,"# are recognized. The test proceeds as if a ZCONTINUE command was entered.",!
	view "trace":1:"^trace2"
	set c=3
	set d=4
	set e=5
	write !,"# Turn off tracing by ZSTEPing the VIEW command to disable it",!
	view "trace":0
	set f=6
	set g=7
	write !,"# Dump the trace records expecting to see the trace pick up at gtm4814B+6 and end at gtm4814B+10 but we",!
	write "# note that there were no more ZSTEPs done once tracing was enabled and that ZSTEPs did not resume after",!
	write "# tracing was turned off at gtm4814B+10.",!
	zwrite ^trace2
	quit
