;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testpieces
	do ^echoline
	do init
	do matchpiece2delim
	do testztupdate
	do nonullmatch

	; $ZTLEvel is one less on the secondary which results in a
	; extract mismatch between the two servers, kill ^fired to
	; eliminate that annoyance
	kill ^fired
	do ^echoline
	quit

	; test matching of piece and delimiter with preloaded data
	; ZTUPdate will only show the relevant pieces
matchpiece2delim
	do ^echoline
	zwr ^pdmatch
	write "Show non-firing of triggers because pieces are not matched",!
	set $piece(^pdmatch(2),"|",2)=101
	set $piece(^pdmatch(6),"|",1)=101
	set $piece(^pdmatch(7),"|",2)=101
	zwr ^pdmatch
	write "Show firing of triggers because pieces are matcheed",!
	set ^pdmatch(1)="a|e|c"
	zkill ^pdmatch(1)
	zkill ^pdmatch(1)
	set ^pdmatch(1)="a|b|c"
	set ^pdmatch(2)="a|1|2|d"
	set ^pdmatch(3)="a|1|2|d"
	set ^pdmatch(4)="a|||e||"
	set ^pdmatch(5)="|b|"
	set ^pdmatch(6)="1|2|3|4"
	set ^pdmatch(7)="a|b|c|d||"
	zwr ^pdmatch
	do ^echoline
	quit

	; piece and delim matching with ztvalue & ztupdate testing
testztupdate
	write "Testing piece and delim via ZTUPdate",!
	kill ^fired,^ztupdate
	set piece="1.2.3.4.5.6.7.8.9.10.11"
	merge ^ztupdate=piece
	set $piece(^ztupdate,".",5)=50
	set $piece(^ztupdate,".",1)=1024
	set $piece(^ztupdate,".",4)="unexpected.this.is"
	zwr ^ztupdate,^fired
	if $data(^fail) write "FAIL",!
	else  write "PASS",!
	kill ^fired,^ztupdate,^fail
	quit

	; there was a bug that would fire the 1000th piece because it was a
	; new piece that was set to null
nonullmatch
	do ^echoline
	write "Any trigger named 'nofire*' should not fire",!
	set ^a=56
	set ^a="5|6"
	set ^a="5"
	set ^a=99
	set ^a="5|6"
	if $select($data(^fired("nofire#")):1,$data(^fired("nofire2#")):1,1:0) do
	.	write "FAIL",!
	.	zwrite ^fired
	else  write "PASS",!
	;
	write "Reset - kill ^a and test again",!
	kill ^a
	set ^a="5|6"
	if $select($data(^fired("nofire#")):1,$data(^fired("nofire2#")):1,1:0) do
	.	write "FAIL",!
	.	zwrite ^fired
	else  write "PASS",!
	;
	do ^echoline
	zwrite ^fired
	do ^echoline
	quit

init
	; load triggers
	do text^dollarztrigger("tfile^testpieces","testpeices.trg")
	do file^dollarztrigger("testpeices.trg",1)
	; pre-load some data
	set ^pdmatch(1)="a|b|c"
	set ^pdmatch(2)="a|b|c"
	set ^pdmatch(3)="a|b|c"
	set ^pdmatch(4)="a|b|c|||"
	set ^pdmatch(5)="a||"
	set ^pdmatch(6)="a|b|c|d"
	set ^pdmatch(7)="a|b|c|d"
	quit

rtn
	set ref=$reference
	set x=$increment(^fired($ZTNAme))
	set $piece(destinfo,".",$increment(destp))=$ZTNAme
	set $piece(destinfo,".",$increment(destp))="executions="_x
	set $piece(destinfo,".",$increment(destp))="$reference="_ref
	set $piece(destinfo,".",$increment(destp))="$ZLEVEL="_$zlevel
	set $piece(destinfo,".",$increment(destp))="$TLEVEL="_$tlevel
	set $piece(destinfo,".",$increment(destp))="$ZTLEVEL="_$ZTLEvel
	if $ztvalue'=""  set $piece(destinfo,".",$increment(destp))="$ZTVALUE="_$ztvalue
	if $ztdelim'=""  set $piece(destinfo,".",$increment(destp))="$ZTDElim="_$ztdelim
	if $ztupdate'="" set $piece(destinfo,".",$increment(destp))="$ZTVALUE="_$ztupdate
	if $trestart>0   set $piece(destinfo,".",$increment(destp))="$TRESTART="_$trestart
	set ^fired($ZTNAme,x)=destinfo
	if $select($data(^fired("nofire#")):1,$data(^fired("nofire2#")):1,1:0) do
	.	write "FAIL:",destinfo,!
	.	set ^fail=1
	.	zwr ^fired
	quit

tfile
	;; there was a bug that would fire the 1000th piece because it was a
	;; new piece that was set to null
	;+^a -command=S -xecute="do rtn^testpieces" -delim=$char(124)             -name=willfire
	;+^a -command=S -xecute="do rtn^testpieces" -delim=$char(58)              -name=willfire2
	;+^a -command=S -xecute="do rtn^testpieces" -delim=$char(58)  -piece=1000 -name=nofire
	;+^a -command=S -xecute="do rtn^testpieces" -delim=$char(124) -piece=1000 -name=nofire2
	;
	;; test matching of piece and delimiter with preloaded data
	;+^pdmatch(1;3:5) -command=S  -xecute="do ^twork" -delim="|"
	;+^pdmatch(2)     -command=S  -xecute="do ^twork" -delim="|" -piece=1;3:6
	;+^pdmatch(6;7)   -command=S  -xecute="do ^twork" -delim="|" -piece=3:100
	;+^pdmatch(:)     -command=ZK -xecute="do ^twork"
	;+^pdmatch        -command=K  -xecute="do ^twork"
	;
	;; updates to $ZTVAlue affect $ZTUPdate
	;+^ztupdate -command=S -xecute="do ^piecedelimtrig" -delim="." -piece=2:3;7:9  -name=limitedrange
	;+^ztupdate -command=S -xecute="do ^piecedelimtrig" -delim="." -piece=10:20    -name=highrange
	;+^ztupdate -command=S -xecute="do ^piecedelimtrig" -delim="."                 -name=allrange
