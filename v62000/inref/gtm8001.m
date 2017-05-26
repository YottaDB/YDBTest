;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8001	;test that ^%LCLCOL does not complain when a set causes no change
	;prior to gtm8001 any set with a subscripted local variable defined failed, even if it made no change
	new (act)
	if '$data(act) new act set act="if $increment(cnt) do fail"
	new $etrap
	set $etrap="goto fail",$ecode="",$zstatus=""
	for lc=0,1 for nc=0,1 for sc=0,1 kill a do
	. write !,lc,nc,sc
	. if '$$set^%LCLCOL(lc,nc,sc) xecute act
	. set a(1)=1
	. xecute:'$$set^%LCLCOL(lc) act
	. xecute:'$$set^%LCLCOL(lc,"") act
	. xecute:'$$set^%LCLCOL(lc,"","") act
	. xecute:'$$set^%LCLCOL(,nc) act
	. xecute:'$$set^%LCLCOL(,nc,"") act
	. xecute:'$$set^%LCLCOL("",nc) act
	. xecute:'$$set^%LCLCOL("",nc,"") act
	. xecute:'$$set^%LCLCOL(,,sc) act
	. xecute:'$$set^%LCLCOL("",,sc) act
	. xecute:'$$set^%LCLCOL(,"",sc) act
	. xecute:'$$set^%LCLCOL("","",sc) act
	. xecute:'$$set^%LCLCOL(lc,nc) act
	. xecute:'$$set^%LCLCOL(lc,nc,"") act
	. xecute:'$$set^%LCLCOL(lc,,sc) act
	. xecute:'$$set^%LCLCOL(lc,"",sc) act
	. xecute:'$$set^%LCLCOL(,nc,sc) act
	. xecute:'$$set^%LCLCOL("",nc,sc) act
	. xecute:'$$set^%LCLCOL(lc,nc,sc) act
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0),!
	quit
fail	write !,"__________________________",!,$zstatus,!
	zshow $select(""=$ecode:"vs",1:"*")
	write:""'=$ecode !,"FAIL from ",$text(+0),!
	quit
