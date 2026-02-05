;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1155 ; Call local^ydb1155 or global^ydb1155
	quit
	;
local ; Test ZYENCODE and ZYDECODE on local variable that encodes to a JSON string of over 4 GiBs
	; Needed to transfer control to next M line after error (instead of stopping execution) in the error case below
	set $etrap="set $ecode="""" do incrtrap^incrtrap"
	write "## Test ZYENCODE and ZYDECODE on a very large M local array [>4 GiBs]",!
	write "### Run [set subslen=2**20]",!
	set subslen=2**20
	write "### Run [set vallen=2**20]",!
	set vallen=2**20
	write "### Run [set subs=$$^%RANDSTR(subslen)]",!
	set subs=$$^%RANDSTR(subslen)
	write "### Run [set val=$$^%RANDSTR(vallen)]",!
	set val=$$^%RANDSTR(vallen)
	write "### Run [for i=0:1:140 set array(i,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs)=val",!
	for i=0:1:140 set array(i,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs)=val
	write "### Run [zyencode json=array]",!
	zyencode json=array
	write "### Expect no errors from ZYENCODE",!!
	do logJsonToFile^ydb1155("local","json")
	write !
	write "### Run [kill array]",!
	kill array
	write "### Run [zydecode array=json]",!
	zydecode array=json
	write "### Expect no errors from ZYDECODE",!
	quit
	;
global ; Test ZYENCODE and ZYDECODE on global variable that encodes to a JSON string of over 4 GiBs
	; Needed to transfer control to next M line after error (instead of stopping execution) in the error case below
	set $etrap="set $ecode="""" do incrtrap^incrtrap"
	write "## Test ZYENCODE and ZYDECODE on a very large M global array [>4 GiBs]",!
	write "### Run [set subslen=512\35]",!
	set subslen=512\35
	write "### Run [set vallen=2**20]",!
	set vallen=2**20
	write "### Run [set subs=$$^%RANDSTR(subslen)]",!
	set subs=$$^%RANDSTR(subslen)
	write "### Run [set val=$$^%RANDSTR(vallen)]",!
	set val=$$^%RANDSTR(vallen)
	write "### Run [for i=0:1:4200 set ^array(i,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs)=val",!
	for i=0:1:4200 set ^array(i,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs,subs)=val
	write "### Run [zyencode ^json=^array]",!
	zyencode ^json=^array
	write "### Expect no errors from ZYENCODE",!!
	do logJsonToFile^ydb1155("global","^json")
	write !
	write "### Run [kill ^array]",!
	kill ^array
	write "### Run [zydecode ^array=^json]",!
	zydecode ^array=^json
	write "### Expect no errors from ZYDECODE",!
	quit
	;
logJsonToFile(filename,var) ; Log encoded JSON string to file for validation
	set file=filename_".json"
	write "## Log encoded JSON to file ["_file_"]",!
	open file:(newversion:stream:nowrap:chset="UTF-8")
	use file
	for i=1:1:@var do
	. set $x=0 ; Prevent newline
	. write @var@(i)
	close file
	use $principal
	quit

