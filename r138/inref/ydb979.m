;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	write "Invoke correct entry point, not main",!
	zhalt 1

;
; Entry point to lookup and report length of the given envvar
;
showEnvVarLen
	set envVar=$zpiece($zcmdline," ",1)
	if envVar="" do
	. write "Missing parameter - name of envvar to return the length of",!
	. zhalt 1
	set envVarValue=$ztrnlnm(envVar)
	write !,"$",envVar," length is ",$zlength(envVarValue),!
	quit
