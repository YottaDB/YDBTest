;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This routine alters $gtm_dist before executing $gtm_exe/gtmsecshr.
; The goal is to stuff garbage into $gtm_dist and try to use
; newlines/carriage returns/vertical tabs to cause a new line in the
; syslog file.
gtm7617
	set $ETRAP="use $p zshow ""*"" halt"
	set realdist=$ztrnlnm("gtm_dist")
	set msg=$JOB_$$^%RANDSTR(64)
	set ^start="START"_msg
	set ^stop="STOP"_msg
	set badpath="/"
	; Set a flag in syslog to start at
	if $$syslog^%ydbposix(^start,"LOG_USER","LOG_INFO")
	;
	; String of control characters, each preceded by the integer value
	for i=1:1:34 set badpath=badpath_i_$char(i)
	; Use a string of control characters, randomly drop a null in because the result is the same
	set path=$select($random(10)<2:badpath_$char(0)_badpath,1:badpath)
	do test(realdist,path)
	; Leading null, the string is NULL!
	do test(realdist,$char(0)_badpath)
	;
	; Try a normal string with random control chars
	set randpath="/"_$$^%RANDSTR(128,"1:1:126","E")
	do test(realdist,randpath)
	; Set a flag in syslog to stop at
	if $$syslog^%ydbposix(^stop,"LOG_USER","LOG_INFO")
	quit

test(dist,path)
	new retval,env,expected
	set retval=$&ydbposix.setenv("gtm_dist",path,1,.errno)
	new retval2
	; Now that we set "gtm_dist" env var to a random string, make sure "ydb_dist" also has the same value
	; as otherwise it would override "gtm_dist". Also check the case where "ydb_dist" is unset. Both cases
	; should behave the same so randomly choose one of the two cases.
	if $random(2) set retval2=$&ydbposix.setenv("ydb_dist",path,1,.errno)
	else          set retval2=$&ydbposix.unsetenv("ydb_dist",.errno)
	set env=$ztrnlnm("gtm_dist")
	set expected=""
	if $piece(path,$char(0),1)'=env write "TEST-W-WARN",! zwrite path,env
	zsystem dist_"/gtmsecshr"
	; Create the expected string and stuff it into the DB, stopping at the first NULL
	for i=1:1:$length(path) set char=$extract(path,i,i),ascii=$ascii(char) quit:ascii=0  do
	.	set expected=expected_$select(ascii>31:char,1:"*")
	set ^path($increment(^pathcount))=expected_"/gtmsecshrdir"
	quit

; Open the getoper results file, but don't start processing until we find ^start
; ending when we find ^stop. The hope here is that the start and stop will help us
; find the correct messages.
validate
	set $ETRAP="use $p zshow ""*"" halt"
	set foundstart=0
	set file=$zcmdline
	open file:readonly
	use file
	for i=1:1  read line(i)  quit:$zeof  quit:line(i)[^stop  do
	.	if 'foundstart set foundstart=(line(i)[^start)
	.	else  set:(line(i)["GTMSECSHRINIT")&(line(i)["SECSHRCHDIRFAILED1") message($increment(msgcount))=line(i)
	close file
	; Validate 1) same number of messages 2) contents match our expectations
	if '$data(msgcount) write "No GTMSECSHRINIT messages found! exiting",! halt
	if ^pathcount'=msgcount write "GTMSECSHRINIT count (",msgcount,") != expected count (",^pathcount,! halt
	for i=1:1:msgcount  do
	.	set text=$piece(message(i)," on ",2)
	.	set text=$piece(text,", errno 2.",1)
	.	if text'=^path(i)  if $increment(fail) zwrite ^path(i),text,message(i)
	if '$data(fail)  write "PASS",!
	else  write "TEST-F-FAIL",!
	quit
