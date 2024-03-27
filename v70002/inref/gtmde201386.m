;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sigintdiv ;
        write "# perform tricky calculation",!
        set $etrap="goto e01"
        ;
        set N1=26489595746075820900000000000000
        set N2=887952097261892.795
        write ((10**(-N2))*N1)**(-2)
        ;
        write "TEST-E-INTERNAL test error: no DIVZ (crash or error)",!
        quit
e01     ;
        write "error caught: ",$piece($zstatus,",",3,4),!
        quit
