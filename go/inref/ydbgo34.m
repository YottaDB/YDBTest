;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Awk replacement routine to commonize the output from ydbgo34.go for each signal allowing us to copy the
; info from the output file into the log to compare with the reference file. Remove those lines from the output
; that don't always occur. Portions of the routine below are commented out until YDB#790 allows a deeper checking
; of signal handling with Go. Right now there are periodic failures seen if the full ydbgo34a test runs.
ydbgo34a
	; Open the file that ydbgo34.go created that says what signal is expected this time
	set savio=$IO
	set f="ydbgo34.signum"
	open f:readonly
	use f
	read signum
	close f
	use savio
	set pat="1""%YDB-F-KILLBYSIG, YottaDB process "".N1"" has been killed by a signal ""1"""_signum_""".E"
	; Now run the input lines removing or modifying the input lines as needed
	for  read line quit:$zeof  do
	. if line?1"main: Exiting".E	; Uncomment commented out lines below when YDB#790 is complete [TODO]
	. ;else  if line?@pat ; Check for KILLBYSIG error and suppress it if we were expecting it ; Comment until YDB#790
	. ;else  if line?1"%YDB-"1(1"F-FORCEDHALT",1"I-CTRLC").E		; Comment until YDB#790
	. ;else  if line?1"main: Exiting to avoid fatal panic".E		; Comment until YDB#790
	. else  if line?1"main: Returning back to interrupt point".E
	. ;else  if line?1"main: Allowing potentially fatal handler to run".E	; Comment until YDB#790
	. ;else  if line?1"workerBee: Caught panic for error".E	       		; Comment until YDB#790
	. else  do
	. . for i=2:1:$zlength($text(sigs),";") do
	. . . set tmp=$zpiece($text(sigs),";",i),newline=$zpiece(line,tmp,1)
	. . . for j=2:1:$zlength(line,tmp) set newline=newline_"SIGXXXX"_$zpiece(line,tmp,j)
	. . . set line=newline
	. . write $zpiece(line," :: ",1),!
	quit

sigs;SIGABRT;SIGBUS;SIGCONT;SIGFPE;SIGHUP;SIGILL;SIGINT;SIGQUIT;SIGSEGV;SIGTERM;SIGTRAP;SIGUSR1
