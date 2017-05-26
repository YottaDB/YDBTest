;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
except	; Test EXCEPTION deviceparameter
	set $ztrap="zprint @$zposition break"
	set mainlvl=$ZLEVEL
	set notfirst=$length($zsearch("exception_1.txt"))
	do init
	do close
	do use
	do open
	do badexc
	quit
close	; will try to rename into a readonly directory
	write line,!
	write "Testing EXCEPTION parameter for close (try to rename the file to a directory that is read-only)",!
	set file="exception_1.txt"
	new err
	set filern="baddir/exception_2.txt"
	do try
	write "TEST-E-TSSERT, execution should never come here",!
	quit
use	; will now try to write into the file, although not positioned to EOF
	write line,!
	write "Testing EXCEPTION parameter for use (try to write into the file, although not positioned to EOF)",!
	set file="exception_1.txt"
	write file,!
	new err
	open file:(READONLY:EXCEPTION="s err=""open"" do error")
	use file:(REWIND:EXCEPTION="s err=""use"" do error")
	write "12345",!
	close file:(EXCEPTION="s err=""close"" do error")
	quit
open	; will try to open a file in a read-only directory
	write line,!
	write "Testing EXCEPTION parameter for open (try to write into a file that is read-only)",!
	set file="tmp/exception_2.txt"
	new err
	do try
	quit
badexc	;
	write line,!
	write "Now let's try a bad exception parameter...",!
	set file="tmp/exception_2.txt"
	new err
	open file:(EXCEPTION="s err=""open"" do error or is this correct at all")
try     ;
	write file,!
	if notfirst do
	. open file:(READONLY:EXCEPTION="s err=""open"" do error")
	. set notfirst=0
	else  open file:(EXCEPTION="s err=""open"" do error")
	use file:(EXCEPTION="s err=""use"" do error")
	write "12345",!
	close file:(RENAME=filern:EXCEPTION="s err=""close"" do error")
	quit
error
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write "Source of error was ",err,!
	write $ZSTATUS,!
	write "continue...",!
	close file
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit
init
	set line="---------------------------------------------------------------"
	quit
