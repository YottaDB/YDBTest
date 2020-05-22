;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb492	;
	do ^sstep
	write $zwrite($translate("abcd"_$c(128)_"efgh"_$c(128),$c(128))),!
	write $zwrite($translate("abcd"_$c(1024)_"efgh"_$c(1025),"bcecyz"_$c(1024))),!
	write $zwrite($translate("abcd"_$c(1024)_"efgh"_$c(1025),$c(1025))),!
	write $zwrite($translate("a"_$c(1024)_"e"_$c(16384),$c(16384))),!
	write $zwrite($translate("a"_$c(1024)_"e"_$c(16384),"abcdfghijklmnopqrstuvwxyz"_$c(16384))),!
	write $zwrite($translate("abcd"_$c(128)_"efgh"_$c(128),$c(128),"")),!
	write $zwrite($translate("abcd"_$c(1024)_"efgh"_$c(1025),"bcecyz"_$c(1024),"")),!
	write $zwrite($translate("abcd"_$c(1024)_"efgh"_$c(1025),$c(1025),"bcfhyz"_$c(1024))),!
	write $zwrite($translate("a"_$c(1024)_"e"_$c(16384),$c(16384),$c(65536))),!
	write $zwrite($translate("a"_$c(1024)_"e"_$c(16384),"abcdfghijklmnopqrstuvwxyz"_$c(16384),$c(65536)_"abcdefgh")),!
	quit

