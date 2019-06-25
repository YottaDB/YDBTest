;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; uses all of the variants of %TRIM
; with the optional second argument set
gtm8017 ;

	write "Testing default behavior of %TRIM (trimming <TAB> <SP>)",!
	set strToTrim=$c(9,32,32,9)_"<- Trim this, and that ->"_$c(32,32,9,9)

	write "String before LR trimming: ",strToTrim,"| space marker",!
	set strTrimmed=$$FUNC^%TRIM(strToTrim)
	write "String after LR trimming: ",strTrimmed,"| space marker",!,!

	write "String before L trimming: ",strToTrim,"| space marker",!
	set strTrimmed=$$L^%TRIM(strToTrim)
	write "String after L trimming: ",strTrimmed,"| space marker",!,!

	write "String before R trimming: ",strToTrim,"| space marker",!
	set strTrimmed=$$R^%TRIM(strToTrim)
	write "String after R trimming: ",strTrimmed,"| space marker",!,!

	write "Testing optional second argument of %TRIM",!
	set strToTrim="ababcccc<- Trim this, and that ->abcabcabc"

	write "Trimming ""abc""",!
	write "String before LR trimming: ",strToTrim,!
	set strTrimmed=$$FUNC^%TRIM(strToTrim,"abc")
	write "String after LR trimming: ",strTrimmed,!,!

	write "String before L trimming: ",strToTrim,!
	set strTrimmed=$$L^%TRIM(strToTrim,"abc")
	write "String after L trimming: ",strTrimmed,!,!

	write "String before R trimming: ",strToTrim,!
	set strTrimmed=$$R^%TRIM(strToTrim,"abc")
	write "String after R trimming: ",strTrimmed,!,!
	quit
