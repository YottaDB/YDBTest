;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	write "This routine has no main entry point - recode to drive the correct entry point",!
	zhalt 1
;
; This routine is a filter for GTM-9278 - specifically we need to read in the output logs from the
; ydb927 part of the test. These log files (type .logx) are full of DBFILERR messages that have
; ENO21 secondary messages. Here is an example message from one of the .logx files this test creates
; (all on one line):
;
;   150372546,+2^ydb927,%YDB-E-DBFILERR, Error with database file .*/v63013_0/gtm9278/dirnotdat.dat, %SYSTEM-E-ENO21, Is a directory
;
; The purpose of this routine is to rewrite these log files to a .log flavor sans these messages.
; The intent is that with these expected messages removed from the .log files, we can let the test
; framework discover any unexpected messages there and warn about them (thus failing the test).
;
filter
	;
	; Initialize some variables used in reading/writing the log files, validate parms
	;
	set inputfn=$zcmdline
	set $etrap="write ""Error: "",$zstatus,! zhalt 1"
	set fname=$zpiece(inputfn,".",1)		; Get the filename without extension
	set ftype=$zpiece(inputfn,".",2)
	if ""=fname do
	. write "Missing filename argument",!
	. zhalt 1
	if "logx"'=ftype do
	. write "Unexpected file type (",ftype,") or file-name format: ",inputfn,!
	. zhalt 1
	;
	; Open input and output files
	;
	set outputfn=fname_".log"
	open inputfn:readonly
	open outputfn:new
	;
	; Copy input lines to the output file if they do not contain both DBFILERR and ENO21
	;
	for  use inputfn read line quit:$zeof  do
	. use outputfn
	. write:('((line["DBFILERR")&(line["ENO21"))) line,! ; Verify both msgs present as noted above
	close inputfn
	close outputfn
	quit

