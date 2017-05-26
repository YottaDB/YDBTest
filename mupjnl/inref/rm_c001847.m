;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2003, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	s fn="rmpid"_+$ztrnlnm("gtm_test_jobid")_".mjo" o fn u fn w "PID ",$J,! c fn u $P
	s ^sema1=1
	;q
	FOR i=1:1:200 DO
	. w "\"
        . TStart ():(serial:transaction="BA")
        . FOR j=1:1:320 SET ^bdata(j)=$j(1,600)
        . TC
	. w "|"
        . TStart ():(serial:transaction="BA")
        . FOR j=1:1:320 SET ^adata(j)=$j(1,600)
        . TC
	. w "/"
        . TStart ():(serial:transaction="BA")
        . FOR j=1:1:320 SET ^cdata(j)=$j(1,600)
        . TC
	w "TEST-E-NOTKILLED, the main process did not kill this routine",!

        Q
