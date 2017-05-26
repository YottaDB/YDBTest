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
-*
+^a(subs=:) -commands=SET -xecute="Set ^b(subs)=^a(subs)"
+^b(subs=:) -commands=SET -xecute="TStart () Set ^c(subs)=^b(subs) TCommit"
+^c(subs=:) -commands=SET -xecute="Set ^d(subs)=^c(subs)"
+^d(subs=:) -commands=SET -xecute=" Write ""Nested call - restarting now ($TRestart="",$TRestart,"") ($ZTLevel="",$ZTLevel,"")"",! TRestart:(2>$TRestart)"
