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
gtm7321	; routine to test -nowarning compiler qualifier
	;
	zlink "gtm7321a.m"					; $zcompile should control whether there are errors
	do ^gtm7321a						; check that we go an object file
	set $zcompile=$select(""=$zcompile:"-nowarning",1:"")	; reverse the setting
	write "Reverse the setting established by the environment variable and ZLINK again",!
	zlink "gtm7321a.m"					; and repeat
	quit
