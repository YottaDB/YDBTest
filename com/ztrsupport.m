;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ztrsupport
	set support=$$supported()
	write "ztrigger is ",$select(support=0:"not",1:"")," supported by ",$zversion,!
	XECUTE:$length($zcmdline) $zcmdline
	quit:$quit support
	quit

supported()
        set supported=1
	set $ETRAP="set $ecode="""" set:$zstatus[""INVCMD"" supported=0"
	set cmd="ztrigger ^a"
	xecute "xecute cmd"
	quit:$quit supported
	write supported,!
	quit
