;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8191	;Verify VIEW "POOLIMIT" and $VIEW("POOLLIMIT")
	;
	new (act,debug)
	if '$data(act) new act set act="if $increment(cnt) use $principal zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="do ^incretrap";,$zstep="zprint @$zposition zstep into"
	set (^a,^d,^m,^A,^D,^M)=1
	for i=100:-25:0 for j="","%" for reg="default","DEFAULT","areg","AREG","mmreg","MMREG" do
	. new $estack
	. set accmeth=$view("GVACCESS_METHOD",reg)
	. view "POOLLIMIT":reg:"50%"
	. set bts=2*$view("POOLLIMIT",reg)
	. view "POOLLIMIT":reg:i_j
	. set pool=$view("POOLLIMIT",reg)
	. if ""=j,pool'=$select("MM"=accmeth:0,25=i:32,1:i),$increment(cnt) xecute act
	. if "%"=j,pool'=$select("MM"=accmeth:0,+i=75:bts*.5,+$translate(i,1):i*bts/100,1:0),$increment(cnt) xecute act
	view "poollimit"
	view "poollimit":"areg"
	set expect="VIEWARGCNT"
	if $view("poollimit"),$increment(cnt)
	set expect="NOREGION"
	if $view("poollimit","*"),$increment(cnt)
	if $view("poollimit",$char(65,82,0,71)),$increment(cnt)
	set expect="VIEWGVN"
	if $view("region","^"_$char(65,0,66)),$increment(cnt)
	if $view("noisolation","^"_$char(65,0,66)),$increment(cnt)
	set expect="VIEWLVN"
	if $view("lv_ref",$char(65,0,66)),$increment(cnt)
	write !,$select('$get(cnt):"PASS",1:"FAIL")," from ",$text(+0)
	quit
