;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testver	;
	;
	; Construct version from $ZVERSION & $ZYRELEASE
	;
	set zv=$translate($piece($zversion," ",2),".-")
	set zyre=$translate($piece($zyrelease," ",2),".-")
	set testver=$zconvert(zv_"_"_zyre,"U")
	set gtmverno=$ztrnlnm("gtm_verno")
	; If running test version is V9xx_Ryyy, then skip comparing V9xx against $ZVERSION (which would be V6*)
	set testzv=$piece(gtmverno,"_",1)
	set testzyre=$piece(gtmverno,"_",2,99)
	set:(testzv["V9") gtmverno=$zconvert(zv_"_"_testzyre,"U")
	if testver=gtmverno write "Passed the version test",!
	else                write "Should be ",gtmverno," but is ",testver,!
	quit
