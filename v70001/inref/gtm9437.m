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

; v70001/gtm9437 - Utility program for this test.

gtm9437	;
	;
	set ^stop=0
	write "# Job child which will have a connecting LOCAL socket, parent will have a listening LOCAL socket",!
	set jmaxwait=0	; do not wait for child process to finish in "do ^job" invocation below
	do ^job("child^gtm9437",1,"""""")
	set s="socket"
	open s:::"SOCKET"
	open s:(LISTEN="socket1:LOCAL":ATTACH="handle1")::"SOCKET"	; open a listening socket
	use $principal
	set $ztrap="goto incrtrap"
	write "# Test all device parameters that can be specified in a USE command for a SOCKET device.",!
	write "# This list was obtained by looking at all [switch/case] code paths in [YDB/sr_port/iosocket_use.c]",!
	write "# Although the release note indicates an error is issued for ANY additional device parameter, it was",!
	write "# observed that a few device parameters do not issue an error. Those are also tested below even though they",!
	write "# don't show any error. Note that [exception] device parameter is tested last as testing it in the beginning",!
	write "# causes issues with test flow due to error handling going to the exception device parameter instead of $ztrap.",!
	for devparam2="filter=""chars""","nofilter","delimiter=$c(13)","nodelimiter","zdelay","znodelay","zbfsize=4096","zibfsize=1024","ioerror=""TRAP""","zlisten=""a""","socket=""hand""","ichset=""M""","ochset=""M""","chset=""M""","zff=$c(13)","znoff","length=40","width=132","wrap","nowrap","morereadtime=10","flush","exception=""write 1""" do
	. for devparam1="detach","attach"  do
	. . set xstr="use s:("_devparam1_"=""handle1"":"_devparam2_")"
	. . use $principal write "--> Testing [",xstr,"]",!
	. . xecute xstr
	. . set dummyline="" ; so incrtrap can return control here
	write /wait	; when this command returns, a connection has been accepted
	; When the child quits after writing one line, the READ will return "" and will set $DEVICE
	; to "1,Connection reset by peer" (i.e. equivalent of $zeof reached for file reads).
	use s
	set ^stop=1
	for  read cmdop  use $principal use s quit:$device
	;
	do wait^job	; wait for child process to die before returning to caller
	quit

child	;
	set s="socket"
	open s:::"SOCKET"
	open s:(CONNECT="socket1:LOCAL")::"SOCKET"
	use s
	write "Child process pid = ",$j,!
	for  quit:^stop=1  hang 0.001
	quit

incrtrap; ------------------------------------------------------------------------------------------
	;   Error handler. Prints current error and continues processing from the next M-line
	; ------------------------------------------------------------------------------------------
	new savestat,mystat,prog,line,newprog
	set savestat=$zstatus
	set mystat=$piece(savestat,",",2,100)
	set prog=$piece($zstatus,",",2,2)
	set line=$piece($piece(prog,"+",2,2),"^",1,1)
	set line=line+1
	set newprog=$piece(prog,"+",1)_"+"_line_"^"_$piece(prog,"^",2,3)
	use $principal
	write "ZSTATUS=",mystat,!
	set newprog=($zlevel-1)_":"_newprog
	zgoto @newprog

