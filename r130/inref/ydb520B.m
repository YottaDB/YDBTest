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
	set ^%ZOSF("TRAP")="$ET=""G ""_X"
	new $ZT,$ES
	set $ZT="D BOO"
	set $ET="G BOO"
	write "ZT: ",$ZT,!
	write "ET: ",$ET,!
	set $ZT="D ERROR^%ut"
	set X="TRAP^XUTMG43",@^%ZOSF("TRAP")
	write "ZT: ",$ZT,!
	write "ET: ",$ET,!
	quit

