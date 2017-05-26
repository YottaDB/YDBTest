;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See test/triggers/u_inref/trignameuniq.csh for test case definition. This
; test requires the whitebox test case for WBTEST_HELPOUT_TRIGNAMEUNIQ.
trignameuniq
	set incretrap("NODISP")=1
	set $ETRAP="do ^incretrap"
	set max=3908 ; 1+62+(62*62) plus one more
	set triggerstr=" -xecute=""do trigrtn^trignameuniq"" -command=ZTR -name=unique"

; Install 3908 triggers with the same name. This requires
; WBTEST_HELPOUT_TRIGNAMEUNIQ or it won't work
install
	set file="trignameuniq.trigout"
	open file:newversion
	use file
	for i=0:1:max  set gvn="+^somegvn"_i do
	.	if '$ztrigger("item",gvn_triggerstr) do
	.	.	write "TEST-W-WARN: trigger install failed",!
	.	.	zwrite
	.	.	zhalt +$zstatus
	close file
	use $p

; Execute the 3908 triggers exhausting the run-time unique name space
execute
	for i=0:1:max  set gvn="^somegvn"_i ztrigger @gvn

; Repeat the above using ZPRINT, ZBREAK and $TEXT. Note that you can test for a
; label with a run-time disambiguator only if it has been used
zbzptext
	if $length($etrap)=0 set $ETRAP="use $p write $piece($zstatus,$char(44),3),! zhalt +$zstatus"
	set file="trignameuniq.out"
	open file:newversion
	use file
	for i=1:1  set sub=$order(^fired($get(sub))) quit:sub=""  do
	.	set trigrtn="^"_sub
	.	write "Trying ",trigrtn
	.	write " zprint " zprint @trigrtn
	.	write " zbreak " zbreak @trigrtn
	.	write " $text ",$text(@trigrtn),!
	close file
	use $p

; Validate the test run
validate
	if ^fired'=3907 write "TEST-F-FAIL: ",^fired,!
	else  write "TEST-I-INFO PASS",!
	quit

; To see all the fired triggers execute:
;	$gtm_dist/mump -run show^trignameuniq
show
	new i,shortCount
	for i=1:1  set sub=$order(^fired($get(sub))) quit:sub=""  do
	.	write ^fired(sub),":",$justify(sub,9)," " if $X>80 write !
	.	if $length(sub)<9 set shortCount=$increment(shortCount)
	zwrite i,shortCount
	quit

; The trigger code sets a global using the name of the trigger and counts the
; number of triggers fired for use in validation
trigrtn
	set x=$increment(^fired($ztname))
	set ^fired=$increment(^fired)
	quit
