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
zshowprin
	; replace test variable fields like /dev/pts/4 with an asterisk like /dev/pts/*
	; get rid of any $C(13) characters from "expect" output
	set p="zshow_principal.outx"
	open p:readonly
	use p
	for  do  quit:$ZEOF
	. read x
	. ; due to possible difference in expect output convert any ttypn to pts/0
	. set p2=$piece(x,"ttyp",2)
	. if p2 set x=$piece(x,"ttyp",1)_"pts/0 "_$extract(p2,$find(p2," "),1000)
	. use $p
	. ; if line begins with TEST, ZSHOW, $P, or %GTM write as is
	. if ((5=$find(x,"TEST"))!(6=$find(x,"ZSHOW"))!(3=$find(x,"$P"))!(5=$find(x,"%GTM"))) write $piece(x,$C(13),1),! use p quit
	. ; if line begins with /dev A( or 0 clean it up
	. set Aseen=$find(x,"A(")
	. if ((5=$find(x,"/dev"))!(2=$find(x,"0"))!Aseen) do cleanup(x,Aseen)
	. use p
	quit

cleanup(x,aseen)
	set p1="1"
	for i=1:1:20  do  quit:$find(p1(i),$c(13))!(""=p1(i))
	. set p1(i)=$piece(x," ",i)
	set np=i-1
	for j=1:1:np do
	. set dev=$find(p1(j),"/dev/pts/")
	. if dev write $extract(p1(j),0,dev-1)_"* " quit
	. if $find(p1(j),"WIDTH") write "WIDTH=* " quit
	. if $find(p1(j),"LENG") write "LENG=* " quit
	. write p1(j)," "
	; need to write the trailing quote for A( lines due to parsing of contained quotes
	if aseen write """"
	write !
	quit
