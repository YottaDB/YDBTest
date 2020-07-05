;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This M program is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

trigLoadOldVer
	;
	; Load triggers using older version. Deletion of non-existent triggers might error out in older versions.
	; So ignore only that error. Also load remaining triggers by loading one trigger line at a time.
	; Loading all triggers at the same time will cause one error to not load any good trigger either.
	;
	set curline=+$zcmdline
	set file=curline_".tmp.trg"
	open file:(readonly)
	use file
	for  read line($incr(i))  quit:$zeof
	close file
	kill line(i)  if $incr(i,-1)
	use $p
	set version=$$^verno()
	; randomly choose a number between 1 and i
	set i=$random(i)+1
	for j=1:1:i do
	. if (version<62002)&'(j#100) view "STP_GCOL"	; Avoid GTM-8214 in prior versions
	. set @("trigstr="_line(j))	; need this to remove extraneous double-quotes & do $c() evaluations
	. ; ---------------------------------------------
	. ; make an exception for "-abc*" which is used in validtriggers.trg to test GTM-7947.
	. ; this is used by parse_valid and dztriggerintp subtests and when run with pre-V62001 causes
	. ; assert failure in trigger_delete.c (GTM-7947)
	. if trigstr="-abc*" set trigstr=";"
	. ; ---------------------------------------------
	. ; make an exception for "+^zt(""ZTR fail"")" which is used in "triggers/inref/ztriggercmd.m"
	. ; This is valid usage since r1.30 but is invalid in prior versions and so we do not want to
	. ; load this in the pre-r1.30 version (YDB#596).
	. if trigstr["+^zt(""ZTR fail"")" set trigstr=";"
	. ; ---------------------------------------------
	. ; if trigger is multiline then use $ztrigger("FILE") as the older version might not support
	. ; multi-line trigger execution in $ztrigger("ITEM").
	. if trigstr["-xecute=<<" do
	. . set outfile=curline_".file.trg"
	. . open outfile:(newversion)
	. . use outfile
	. . write trigstr,">>",!
	. . close outfile
	. . set x=$ztrigger("file",outfile)
	. else  do
	. . set x=$ztrigger("item",trigstr)
	. if (x'=1)&($zextract(trigstr,1)'="-") do
	. . write "TRIGUPGRD_TEST-E-FAIL : Fail at trigger load operation. See "_$zdir_"/"_curline_".trig_load",! zhalt 1
	quit
