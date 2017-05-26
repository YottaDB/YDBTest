;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
label
	; As long as none of the below crashes, we are good
	set a=$ZCH(189)_" ello world!"
	set b=$PIECE(12345,34,2)

	; These will error out, but they shouldnt cause the compiler to stop or not emit object code
	set c=$PIECE("Hello "_$ZCH(190)_" world!",$ZCH(191),1,2)
	set d=$ZSUBSTR("Hello "_$ZCH(192)_" world!",2,5)
	set e=$ASCII($ZCH(193))
	set f=$TRANSLATE("Hello, this is doge?"_$ZCH(194),"Htid","DdiD")
