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
	;
incrtrap; ---------------------------------------------------------------------------------------------------------
	;   Error handler. Prints current error and continues processing from the next M-line
	;   If the variable "incrtrapSAMELINE" is defined, it will resume processing from the erroring M-line.
	;   If the variable "incrtrapNODISP" is defined, it will NOT display $ZSTATUS
	;   If the variable "incrtrapLEVEL" is set, it will do a zgoto $zlevel-incrtrapLEVEL. If not set, it will do zgoto $zlevel
	;
	;   Executes code in "incrtrapPRE" before doing anything and code in "incrtrapPOST" just before the ZGOTO
	;   code in "incrtrapPRE" before doing anything and code in "incrtrapPOST" just before the ZGOTO
	; ---------------------------------------------------------------------------------------------------------
	if $data(incrtrapPRE) xecute incrtrapPRE
	if $tlevel trollback
	new savestat,mystat,prog,line,lineincr,newprog,disperr
	set savestat=$zstatus
	set mystat=$piece(savestat,",",2,100)
	set prog=$piece($zstatus,",",2,2)
	set line=$piece($piece(prog,"+",2,2),"^",1,1)
	set lineincr=1
	if $data(incrtrapSAMELINE) set lineincr=0
	set line=line+lineincr
	set newprog=$piece($piece(prog,"^",1),"+",1)_"+"_line_"^"_$piece(prog,"^",2,3)
	set disperr=1
	if $data(incrtrapNODISP) set disperr=0
	if disperr  write "ZSTATUS=",mystat,!
	set newprog=($zlevel-$get(incrtrapLEVEL,0))_":"_newprog
	if $data(incrtrapPOST) xecute incrtrapPOST
	zgoto @newprog

