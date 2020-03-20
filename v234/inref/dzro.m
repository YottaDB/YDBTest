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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dzro	; ; ; Set, then reset $ZCOMPILE and $ZROUTINES, then check them.
	;
	New tmp

	Set tmp=$ZCOMPILE
	Set $ZCOMPILE="/ignore/nolist/object/length=66/space=1"
	Set x=$ZCOMPILE
	Set $ZCOMPILE="/object"
	Write !,$SELECT(x="/ignore/nolist/object/length=66/space=1":"OK",1:"BAD")," from DZRO"
	Set $ZCOMPILE=tmp

	Set zroutinesvariable89012345678901=".(. $gtm_tst/$tst/inref $gtm_exe) $gtm_exe"
	Set tmp=$ZROUTINES
	Set $ZROUTINES=zroutinesvariable89012345678901
	Set x=$ZROUTINES
	Set expectx=".(. "_$ztrnlnm("gtm_tst")_"/"_$ztrnlnm("tst")_"/inref "_$ztrnlnm("gtm_exe")_") "
	Set expectx=expectx_$ztrnlnm("gtm_exe")_"("_$ztrnlnm("gtm_exe")_")"
	Set $ZROUTINES=""
	Write !,$SELECT(x=expectx:"OK",1:"BAD")," from DZRO"
	Set $ZROUTINES=tmp

	Quit
