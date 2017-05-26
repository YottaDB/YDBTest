;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8009
zsystemset ; Verify open database and journal fds does not get passed via zsystem
	set ^a=3
	zsystem "showopenfiles"
	quit
zsystemwrite ; Verify open read-only database and journal fds does not get passed via zsystem
	write ^a,!
	use $principal
	zsystem "showopenfiles"
	quit
mdevfile; Verify an open file's fd does not get passed via zsystem
	set file="file.txt"
	open file use file write "some text",! use $principal
	zsystem "showopenfiles"
	quit
fifo; Verify an open fifo's fd does not get passed via zsystem
	set fifo="myfifo"
	open fifo:fifo
	zsystem "showopenfiles"
	quit
