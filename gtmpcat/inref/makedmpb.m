;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Before we start the process to actually core ourselves, fire up a mumps process in the secondary to validate the
	; structures available for it
	;
	Set ver=$Translate($Piece($ZVersion," ",2),"-.","")	; Get unpunctuated version
	ZSystem "$gtm_tst/$tst/u_inref/makedmp2ndry.csh >& makedmpsecndry-"_ver_".out.txt"
	;
	New $ETrap
	Set $ETrap="Do docore^makedmp() Write ""This won't really be written"",!"
	Set zzz=1/0	; Won't return from this
	Quit
