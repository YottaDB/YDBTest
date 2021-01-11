;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
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
lock	;
	lock ^A1
	lock +^B2
	lock +^global(1)
	lock +^global("string")
	lock +^global("two words")
	lock +^global("three words here","two here")
	lock +^global("embedded"" quote")
	lock +^global("embedded = equals")
	lock +^global("embedded = and""")
	lock +^global("embed=and""nospace")
	write "Show only one lock with embedded = and quote",!
	s showlock="$LKE show -lock=""^global(\""embedded = and\""\""\"")"""
	zsystem showlock
	write "Remove only one lock with embedded = and quote without space",!
	s clearlock="$LKE clear -nointeractive -lock=""^global(\""embed=and\""\""nospace\"")"""
	zsystem clearlock
	write !,"Remove only one lock ^global(two words)",!
	s clearlock="$LKE clear -nointeractive -lock=""^global(\""two words\"")"""
	zsystem clearlock
	write !,"Remove only one lock ^global(embedded = equals)",!
	s clearlock="$LKE clear -nointeractive -lock=""^global(\""embedded = equals\"")"""
	zsystem clearlock
	write !,"Clear all locks",!
	s clearall="$LKE clear -nointeractive"
	zsystem clearall
