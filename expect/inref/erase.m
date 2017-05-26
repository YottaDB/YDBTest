;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drive;
	set NULL=0,ESC=1,EMPT=2,NOEMPT=3,ESCEMPT=4,TOTAL=5
	;
	; Create the log file for test
	;
	set logfile="ttreadbuf.log"
	open logfile
	for ch=0:1:4  do
	.	write "-----------------ITERATION "_ch_"-------------------",!,!
	.	use logfile write "-----------------ITERATION "_ch_"-------------------",!,! use $principal
	.	do erase(ch)
	close logfile
	quit
	;
erase(choice);
	; NULL 		- neither ESP nor EMPT
	; ESC 		- Only escape
	; EMPT 		- Only empterm
	; NOEMPT	- only noempterm
	; ESCEMPT 	- Both escape and empterm
	;
	; Input parameter choice is such that: 0 <= choice <=4. Verify this assertion.
	;
	if (choice<0)!(choice>TOTAL) Write "input paramter out of range",!
	;
	; determine the device parameters to be used.
	;
	if choice=NULL set dp="(noescape)"
	if choice=ESC set dp="(escape)"
	if choice=EMPT set dp="(noescape:empterm)" set:$random(2) dp="(noescape:empt)"
	if choice=NOEMPT set dp="(noescape:noempterm)" set:$random(2) dp="(noescape:noempt)"
	if choice=ESCEMPT set dp="(escape:empterm)"
	use logfile set opstr="choice="_choice_":"_"deviceparam="_dp zwrite opstr  use $principal
	;
	; decide the characters to be entered.
	; if escape device parameter is specified, enable escape sequence processing.
	; kbs - backspace key
	; kdch1 - delete key
	; erase - A erase character in stty -a output
	; Following are the values for xterm and vt320 terminal type.
	set erase=$char(127),kbs=$char(127)
	set kdch1=$char(27)
	set:(choice=ESC)!(choice=ESCEMPT) kdch1=kdch1_"[3~"
	use logfile zwr erase,kbs,kdch1
	use $principal:@dp

	write "TEST 0: erase character on terminal(Look for erase character in stty -a output)",!
	write "Press erase key",!
	do readip^erase(erase)
	;
	write "TEST 1: kbs TERMIINFO capability.",!
	write "Press BACKSPACE key",!
	do readip^erase(kbs)
	;
	write "TEST 2: kdch1 TERMIINFO capability.",!
	write "Press DELETE key",!
	do readip^erase(kdch1)
	quit
	;
readip(expstr);
	;
	;  Test reading on terminal with various combination of following cases.
	;	i)   Buffer is empty
	;	ii)  Buffer is not empty
	;	iii) EMPTERM is set
	;	iv)  NOEMPTERM is set
	;
	set needread=0
	read localvar
	if (choice=EMPT)!(choice=ESCEMPT)  do
	.	if ($key=expstr)&($zb=expstr)&(localvar="") do 	; Success
	.	.	write "SUCCESS: $key, $zb, localvar have expected values",!
	.	.	set ^c1=$increment(^c1)
	.	.	set needread=1
	.	else  do					; Failure
	.	.	write "FAIL: $key, $zb, localvar do not have expected values",!
	.	.	zwr $zb,$key,localvar
	.	.	if choice=ESC!choice=ESCEMPT write "escape sequence processed",!
	.	.	else  write "escape sequence not processed",!
	read:(needread) localvar
	if (localvar="GTM")!((expstr=kdch1)&(localvar="GTMM"))  do
	.	write !
	.	write "SUCCESS: Normal erase while reading.",!
	.	set ^c2=$increment(^c2)
	else  write "FAIL: localvar do not have expected value.",! zwr localvar,expstr
	set envnotset=$ztrnlnm("gtm_principal_editing")["NOEMPTERM"
	if envnotset&(expstr'[$char(27))&(choice'=EMPT)&(choice'=ESCEMPT) do
	.	write "read from empty buffer",!
	.	read localvar
	.	if localvar="" write "SUCCESS: Read on empty buffer is not terminated",! set ^c3=$increment(^c3)
	.	else  write "FAIL: Read on empty buffer ended in unexpected way"  zwr $zb,$key,localvar
	quit
	;
