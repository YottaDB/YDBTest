;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Simplistic routine that won't be run but needs to exist. The test is compiling this routine with
; an alternate routine name and driving it with -run. Pre V62001, this would get an assertpro when
; it failed to load but GTM-8068 fixes that so it behaves the same as if run in direct mode
; so far as the error generated is concerned.
;
	write "hello world",!
	quit
