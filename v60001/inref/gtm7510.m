;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7510
	set jdetach=1
	set jmaxwait=0
	set unix=$zversion'["VMS"
	if unix set cmdstr="$gtm_dist/lke show -wait >& jwait_queue.list"
	else  set cmdstr="pipe DEFINE/USER_MODE SYS$ERROR NL: ; lke show/wait > jwait_queue.list ; purge jwait_queue.list"
	set found=0
	lock ^a
	do ^job("locker^gtm7510",4,"""""")
	for i=1:1:300 quit:found  do
	.   hang 1
	.   zsystem cmdstr
	.   do findblockedpid
	if 'found do
	.  write "Error: None of the processes locked ^a after 300 retries. See jwait_queue.list. Halting.",!
	.  halt
	lock
	do wait^job
	quit

locker
	view "RESETGVSTATS"     ; start afresh
	for i=1:1:100 lock ^a lock
	zshow "G":val
	do out^zshowgfilter(.val,"LKF,CAT")
	zwrite val
	quit

findblockedpid
	; This sets "found" local to 1 if at least 1 process is blocked on ^a.
	set file="jwait_queue.list"
	open file:(exception="if $zeof=1 quit")
	use file
	for  quit:$zeof=1  do
	.       read line
	.	if $tr(line," ")["aRequestPID" set found=1
	close file
	use $p
	quit
