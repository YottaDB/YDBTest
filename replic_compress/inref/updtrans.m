;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updtrans
        tstart ():(serial:transaction="BA")     ; BA to avoid journal hardening wait in the test
        for i=1:1:2048 set ^x(i)=$j(i,900)
        tcommit
        quit
