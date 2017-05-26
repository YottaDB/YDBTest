;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2004, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
smplfil	;
	if ("TP"=$ztrnlnm("gtm_test_tp")) tstart ()
	set $ZGBLDIR="threereg.gld"
	write "---------- $ZGBLDIR = ",$ZGBLDIR,"----------",!
	do fill("threereg.gld")
	write "-----Globals filled in here -----",!
	zwrite ^?.E
	write !
	set $ZGBLDIR="fourreg.gld"
	write "---------- $ZGBLDIR = ",$ZGBLDIR,"----------",!
	do fill("fourreg.gld")
	write "-----Globals filled in here -----",!
	zwrite ^?.E
	write !
	set globaldirectory3="threereg.gld"
	set globaldirectory4="fourreg.gld"
	set ^|globaldirectory3|xasalongvariable="x in globaldirectory3"
	write "# $zgbldir : ",$zgbldir," Extended reference ",globaldirectory3," should not change $view behavior",!
	; pre GTM-7810, due to extended ref usage above, $view would operate on globaldirectory3 though $zgbldir is globaldirectory4
	write $view("REGION","^cdefghijklmnopqrstuvw"),!
	set ^|globaldirectory4|xasalongvariable="x in globaldirectory4"
	set ^|globaldirectory4|xasalongvariable2="x2 in globaldirectory4"
	write "^|globaldirectory3|xasalongvariable",!,^|globaldirectory3|xasalongvariable,!
	write "^|globaldirectory3|xasalongvariable",!,^|globaldirectory4|xasalongvariable,!
	set $ZGBLDIR=globaldirectory3
	write "---------- $ZGBLDIR = ",$ZGBLDIR,"----------",!
	ZWRITE ^xasalongvariable
	write "# $order with extended reference should work irrespective of $zgbldir value",!
	write $order(@"^|globaldirectory3|xasalongvariable"),!
	write $order(@"^|globaldirectory4|xasalongvariable"),!
	set $ZGBLDIR=globaldirectory4
	write "---------- $ZGBLDIR = ",$ZGBLDIR,"----------",!
	ZWRITE ^xasalongvariable
	write "# $order with extended reference should work irrespective of $zgbldir value",!
	write $order(@"^|globaldirectory3|xasalongvariable"),!
	write $order(@"^|globaldirectory4|xasalongvariable"),!
	if ("TP"=$ztrnlnm("gtm_test_tp")) tcommit
	quit
fill(append)	;
	set t="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	set count=1,from=1
	for i=8:1:31 do
	. set var=$extract(t,from,i+from)
	. set vartoset="^"_var
	. set value=var_" in "_append
	. set @vartoset=value
	. set count=count+1
	. if 6=count set from=from+1,count=1
	quit
