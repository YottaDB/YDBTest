;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tty	; Checks tty behavior
	W "This test tests deviceparameters for terminals.",!
	w "For each test, it gives a PASS/FAIL result, so check the lines:",!
	w "======> PASS/FAIL",!
	w "The TR for this issue is C9C05-002001",!
	w "re-enable this test (for unix and vms) once the TR is fixed",!
	halt
	w "---------------BEGIN TESTING----------------",!
	d r
	d rone
	d ttsync
	d ctrl
	q
ctrl	;
	U $P:(PASTHRU:NOTTSYNC)
	w "PASTHRU:NOTTSYNC",!
in	w "=>Enter ^a to ^z also ^? and ^\ (order is not important)",!
	w "=> Try ^c first.",!
	w "=>You should not see YDB-I-CTRLC.",!
	w "  If you do, please zc.",!
	w "=>If you get a sig-3, run again and do not input ^\",!
	w "=>^n might mess terminal, reset the terminal with ctrl-middle button -> ""Do Soft Reset"" option)",!
	w "=>To end read, hit return, then 0 and another return",!
	s q=0,x=""
	f  q:q=1  d
	. r xi
	. i xi=0 s q=1
	. e  s x=x_xi w "<=====Oops, fell out. Go back again(enter 0 to exit).",! zwr x
	w "Input taken. Can you read this?",!
	r tmp
	zwr x
	f i=1:1:26,28,127  d
	. s tmp=$C(i)
	. s char=" (^"_$C(i+64)_")"
	. i char<64,char>90 s char=""
	. i i'=13 d
	. . i 0=$F(x,$C(i)) w "===>FAIL. $C(",i,")",char," not found.",!
	. . e  i i'=13 w "PASS. $C(",i,")",char," is here",!
	. i i=13 d
	. . i 0=$F(x,$C(i)) w "===>PASS. $C(13) (^M) is NOT there.",!
	q
recov	r x
	zwr x
	zc
	q
ctrl1	w "type ^c then ret",!
	w "You sohuld not see YDB-I-CTRLC!. If you do, please zc (and then return)",!
	d rx($C(3))
	w "Type in ^a ^b ^d ^e ... ^j then ret",!
	d rx($C(1,2,4,5,6,7,8,9,10))
	w "Type in ^k ^l ^m then ret",!
	d rx($C(11,12,13))
	w "Type in ^n ret (the terminal might become unreadable, reset the terminal with ctrl-middle button -> ""Do Soft Reset"" option, then hit return)",!
	d rx($C(14))
	w "Can you read these characters?",!
	r dummy
	w "Can you read now?",!
	w "Type in ^o ^p... ^x ^y ret",!
	d rx($C(15,16,17,18,19,20,21,22,23,24,25))
	w "Type in ^z ret (should it suspend???)",!
	d rx($C(26))
	w "Could you come back?",!
	w "---------DONE TESTING--------",!
	w "There should not have been any FAILs",!
	q
r       ;
	w "initially:",!
        d xx("cb")
        d pas("xx","c"_$C(22)_"b")
        d nopas("xx","cb")
	q
rone	;
	d yy(22)
	d pas("yy",22)
	d nopas("yy",22)
	q
ttsync	;
	w "initially",!
	d zz("asq")
	w "PASTHRU:NOTTSYNC",!
	u $P:(PASTHRU:NOTTSYNC)
	d zz("a"_$C(19)_"s"_$C(17)_"q")
	w "PASTHRU:TTSYNC",!
	u $P:(PASTHRU:TTSYNC)
	d zz("asq")
	;w "leaving with :(PASTHRU:NOTTSYNC)",!
	;u $P:(PASTHRU:NOTTSYNC)
        q
pas(var,res)     ;
        w "PASTHRU",!
        u $P:(PASTHRU)
        d @var^tty(res)
        q
nopas(var,res)   ;
        w "NOPASTHRU",!
        u $P:(NOPASTHRU)
        d @var^tty(res)
        q
xx(res)	;
        w "Type in c<ctrl-v>b ret:"
        d rx(res)
	q
yy(res) 	;
	w "type ^v (and a ret if that doesn't show up):"
        r *x
        w !,"Length:",$l(x),!
        zwr x
	i (x=res) w "=====>PASS.",!
	e  w "=====>FAIL. Was expecting:" zwr res w "            but got " zwr x
        q
zz(res)	;
        w "type a<ctrl-s>s<ctrl-q>q ret:",!
        d rx(res)
	q
rx(res)	r x
	w !,"Length:",$l(x),!
	zwr x
	i (x=res) w "=====>PASS.",!
	e  w "=====>FAIL. Was expecting:" zwr res w "            but got " zwr x
	q
