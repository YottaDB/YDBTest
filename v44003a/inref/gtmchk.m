;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtmchk	;
	; D9D12-002404 - %YDB-F-GTMCHECK, Internal GT.M error
	; To verify that GT.M reports an LABELUNKNOWN at gtmchk+5^gtmchk
	;
	d labdef^d002404	; the label exists, d002404 is linked successfully
	d labundef^d002404(10)	; label doesn't exist. Should report LABELUNKNOWN.
	q
