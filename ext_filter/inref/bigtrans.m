;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bigtrans
	; create a big transaction

	tstart
	; create one large set to vary the transaction size
	set ^b=$justify("abc",$random(20000))
	for i=1:1:2000 do
	. set ^a(i)=i_":abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
	tcommit
	; create a big global
	set ^BigGlobal=$justify("12345",32225)
	set ^BigGlobal2=$justify("123456",32226)
	set ^BigGlobal3=$justify("1234567",32227)
	set ^SmallGlobal=$justify("12345",30)
	quit

