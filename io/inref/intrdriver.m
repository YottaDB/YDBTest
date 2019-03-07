;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
intrdriver
	; Interrupt read process until we are requested to shutdown or we reach a system defined limit of interrupts
        ; which probably means we were orphaned and are just chewing up cpu time.
	; we reduce the number of iterations on some processors to keep runtimes similar across platforms
	; To add a new platform, create a <new platform> profile similar to the "x86" label shown under the platform section.
	; Add the $ZVersion search in the test below and do initplaform(<new platform>) if found.
	; After setting up the interrupt parameters and doing some initialization we use the commandline parameter to job off
	; the specified version(like fixednonutf) of fifosenddata, fiforeadintr, and sendintr.  Quit when told to via ^quit.
	; Signal for SIGUSR1 derived via initplatform which calls com/signals.m
	if $ZVersion["x86" do
	. if $ZVersion["CYGWIN" do initplatform("x86cygwin")
	. else  if $ZVersion["64" do initplatform("x8664")
	. else  do initplatform("x86")
	else  if $ZVersion["AIX" do initplatform("aix")
	else  if $ZVersion["OSF1" do initplatform("osf")
	else  if $ZVersion["Solaris" do initplatform("solaris")
	else  if $ZVersion["HP-PA" do initplatform("hppa")
	else  if $ZVersion["IA64" do
	. if $ZVersion["HP-UX" do initplatform("hpuxia64")
	. else  do initplatform("linuxia64")
	else  If $ZVersion["S390" do
	. if $ZVersion["Linux" do initplatform("linuxs390")
	. else  do initplatform("s390")
	else  if $ZVersion["armv7l" do initplatform("armv7l")
	else  if $ZVersion["aarch64" do initplatform("aarch64")
	else  do initplatform("default")
	set ^Zreadcnt($zcmdline)=0
	set ^NumIntrSent($zcmdline)=0

	kill ^quit,^start,^doreadpid($zcmdline)
	set ^numint=0
	set ^readcnt=5000/^reduce
	if $data(^morereads) set ^readcnt=^readcnt+^morereads
	job @($zcmdline_"^readintr("""_$zcmdline_"""):(output="""_$zcmdline_"read.mjo"":error="""_$zcmdline_"read.mje"""_")")
	job @("^sendintr("""_$zcmdline_"""):(output="""_$zcmdline_"doint.mjo"":error="""_$zcmdline_"doint.mje"""_")")
	for  do  quit:$data(^quit)
	. hang 1
	if 0=^Zreadcnt($zcmdline) write "No interrupts seen by read job."
	quit

	; for each platform enter minsnooze, maxsnooze, and reduce

x86	;x86 which is not CYGWIN
	;minsnooze #50
	;maxsnooze #200
	;reduce #1

x8664	;x86_64
	;minsnooze #50
	;maxsnooze #200
	;reduce #1

x86cygwin	;x86 which is CYGWIN
	;minsnooze #50
	;maxsnooze #200
	;reduce #1

aix	;an AIX
	;minsnooze #200
	;maxsnooze #800
	;reduce #1

osf	;OSF1
	;minsnooze #1000
	;maxsnooze #2000
	;reduce #1

solaris	;Solaris
	;minsnooze #500
	;maxsnooze #1000
	;reduce #5

hppa	;HP-PA
	;minsnooze #200
	;maxsnooze #800
	;reduce #1

hpuxia64	;IA64 and UP-UX
	;minsnooze #200
	;maxsnooze #800
	;reduce #1

linuxia64	;IA64 and Linux
	;minsnooze #50
	;maxsnooze #200
	;reduce #1

s390	;S390 and not Linux
	;minsnooze #200
	;maxsnooze #800
	;reduce #1

linuxs390	;S390 and Linux
	;minsnooze #200
	;maxsnooze #800
	;reduce #1

armv7l	;32-bit ARM
	;minsnooze #200
	;maxsnooze #800
	;reduce #1

aarch64	;64-bit ARM
	;minsnooze #200
	;maxsnooze #800
	;reduce #1

default	;default platform
	;minsnooze #5000
	;maxsnooze #9000
	;reduce #1

initplatform(platform)
	; init the platform from the profiles above
	set ^platform=$ZVersion
	set ^minsnooze=$PIECE($TEXT(@platform+1),"#",2)
	set ^maxsnooze=$PIECE($TEXT(@platform+2),"#",2)
	set ^reduce=$PIECE($TEXT(@platform+3),"#",2)
	set ^signum=$$^signals
	quit
