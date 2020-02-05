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
	set ^%ZOSF("TRAP")="$ZT=""G ""_X"
	new $ET,$ES
	set $ET="D BOO"
	set $ZT="G BOO"
	write "ET: ",$ET,!
	write "ZT: ",$ZT,!
	set $ET="D ERROR^%ut"
	set X="TRAP^XUTMG43",@^%ZOSF("TRAP")
	write "ET: ",$ET,!
	write "ZT: ",$ZT,!
	quit

