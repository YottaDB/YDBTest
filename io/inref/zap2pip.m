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
zap2pip
	; started by wrany.m to output a PIP line to the file named in piece 1 of $zcmdline
	; bomlen in piece 2 of $zcmdline is 0, 2, or 3.  If it is 2 then use the shorter number of PIP characters
	; as each is 2 bytes.  bomsel is in piece 3 of $zcmdline and is 0, 1 or 2.
	; If bomlen is 2 then  if bomsel is 0 open with UTF-16BE else open with UTF-16LE
	; if bomlen is 0 and bomsel is 1 open with UTF-16LE
	set p=$piece($zcmdline," ",1)
	set bomlen=$piece($zcmdline," ",2)
	set bomsel=$piece($zcmdline," ",3)
	if (2=bomlen)!(0'=bomsel) do
	. set pip="PIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPP"
	. if 0=bomsel do
	.. open p:(ochset="UTF-16BE")
	. else  do
	.. open p:(ochset="UTF-16LE")
	else  do
	. set pip="PIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIPPIP"
	. open p
	for  quit:$zeof  do
	. read x
	. if $zeof quit
	. use p:seek=x
	. w pip,!
	. use $p
	. write !
	quit

