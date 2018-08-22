;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Verify zshow statistics are displayed properly.
; This is called from basic.csh.
zshow
    set ^x=1
    for i=1:1:99 set ^x(i)=$justify(" ",2500)
    write "===================zshow ""G""===================",!
    zshow "G":val
    do out^zshowgfilter(.val,"DWT,CAT,BTD,DRD")	; filter out a few gvstats as they could contain varying output
    zwrite val
    quit
