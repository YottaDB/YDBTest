;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
badcharfollow
	; exercise bad character disk read processing for non-fixed and fixed, utf-8 and utf-16 modes
	new x,p
	set $ztrap="goto errorAndCont^errorAndCont"
	write "**********************************",!
	write "BAD CHARACTER PROCESSING, NON-FIXED, FOLLOW, UTF-8",!
	write "**********************************",!
	write !,"Processing utf8_nobom_tail",!
	set p="utf8_nobom_tail"
	open p:(follow:read)
	u p
	r x:0
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 136 $zb= 136","zb")
	r x
	do results(x,"$device= 0 $za= 0 $zeof= 0","")
	u p:nofollow
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"Processing utf8_nobom_head",!
	set p="utf8_nobom_head"
	open p:(follow:read)
	u p
	r x:0
	do results(x,"$device= 0 $za= 0 $zeof= 0 $test= 0","test")
	u p:nofollow
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 213 $zb= 213","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"**********************************",!
	write "BAD CHARACTER PROCESSING, NON-FIXED, FOLLOW, UTF-16",!
	write "**********************************",!
	write !,"Processing utf16_nobom_tail",!
	set p="utf16_nobom_tail"
	open p:(follow:readonly:ICHSET="UTF-16")
	u p
	r x:0
	do results(x,"$device= 0 $za= 0 $zeof= 0 $test= 0","test")
	u p:nofollow
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 10 $zb= 10","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"Processing utf16_nobom_head",!
	set p="utf16_nobom_head"
	open p:(follow:readonly:ICHSET="UTF-16")
	u p
	r x:0
	do results(x,"$device= 0 $za= 0 $zeof= 0 $test= 0","test")
	u p:nofollow
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 5 $zb= 5","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"**********************************",!
	write "BAD CHARACTER PROCESSING, NON-FIXED, NOFOLLOW, UTF-8",!
	write "**********************************",!
	write !,"Processing utf8_nobom_tail",!
	set p="utf8_nobom_tail"
	open p:readonly
	u p
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 136 $zb= 136","zb")
	r x
	do results(x,"$device= 0 $za= 0 $zeof= 0","")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"Processing utf8_nobom_head",!
	set p="utf8_nobom_head"
	open p:readonly
	u p
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 213 $zb= 213","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"**********************************",!
	write "BAD CHARACTER PROCESSING, NON-FIXED, NOFOLLOW, UTF-16",!
	write "**********************************",!
	write !,"Processing utf16_nobom_tail",!
	set p="utf16_nobom_tail"
	open p:(readonly:ICHSET="UTF-16")
	u p
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 10 $zb= 10","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"Processing utf16_nobom_head",!
	set p="utf16_nobom_head"
	open p:(readonly:ICHSET="UTF-16")
	u p
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 5 $zb= 5","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"**********************************",!
	write "BAD CHARACTER PROCESSING, FIXED, FOLLOW, UTF-8",!
	write "**********************************",!
	write !,"Processing utf8_nobom_tail",!
	set p="utf8_nobom_tail"
	open p:(fix:read:follow)
	u p:width="8"
	r x:0
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 136 $zb= 136","zb")
	use p:nofollow
	r x
	do results(x,"$device= 0 $za= 0 $zeof= 0","")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"Processing utf8_nobom_head",!
	set p="utf8_nobom_head"
	open p:(fix:read:follow)
	u p:width="8"
	r x:0
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 213 $zb= 213","zb")
	use p:nofollow
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"**********************************",!
	write "BAD CHARACTER PROCESSING, FIXED, FOLLOW, UTF-16",!
	write "**********************************",!
	write !,"Processing utf16_nobom_tail",!
	set p="utf16_nobom_tail"
	open p:(readonly:follow:fix:ICHSET="UTF-16")
	u p:width="5"
	r x:0
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 10 $zb= 10","zb")
	use p:nofollow
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"Processing utf16_nobom_head",!
	set p="utf16_nobom_head"
	open p:(readonly:follow:fix:ICHSET="UTF-16")
	u p:width="5"
	r x:0
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 5 $zb= 5","zb")
	use p:nofollow
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"**********************************",!
	write "BAD CHARACTER PROCESSING, FIXED, NOFOLLOW, UTF-8",!
	write "**********************************",!
	write !,"Processing utf8_nobom_tail",!
	set p="utf8_nobom_tail"
	open p:(fix:read)
	u p:width="8"
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 136 $zb= 136","zb")
	r x
	do results(x,"$device= 0 $za= 0 $zeof= 0","")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"In utf8_nobom_head",!
	set p="utf8_nobom_head"
	open p:(fix:read)
	u p:width="8"
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 213 $zb= 213","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"**********************************",!
	write "BAD CHARACTER PROCESSING, FIXED, NOFOLLOW, UTF-16",!
	write "**********************************",!
	write !,"Processing utf16_nobom_tail",!
	set p="utf16_nobom_tail"
	open p:(readonly:fix:ICHSET="UTF-16")
	u p:width="5"
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 10 $zb= 10","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	close p

	write !,"In utf16_nobom_head",!
	set p="utf16_nobom_head"
	open p:(readonly:fix:ICHSET="UTF-16")
	u p:width="5"
	r x
	do results(x,"$device= 1,BADCHAR error raised on input $za= 9 $zeof= 0 $key= 5 $zb= 5","zb")
	r x
	do results(x,"$device= 1,Device detected EOF $za= 9 $zeof= 1","")
	quit

results(x,expected,extra)
	; extra = test, zb, or testzb for additional ISVs
	new %io
	set %io=$io
	set z=$zeof,za=$za,d=$device,t=$test
	if extra["zb" set k=$zascii($key),zb=$zascii($zb)
	use $p
	write "x= "_x_" length(x)= "_$length(x),!
	write "expect:",!
	write expected,!
	write "$device= "_d_" $za= "_za_" $zeof= ",z
	if extra["zb" write " $key= "_k_" $zb= "_zb
	if extra["test" write " $test= "_t
	write !
	use %io
	quit
