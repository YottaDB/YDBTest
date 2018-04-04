;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
t ;
 s f="edmpattable"
 v "PATLOAD":f
 w !,"loaded file"
 v "PATCODE":"EDM"
 w !,"activated table"
 ;
m ;
 ; NOTE: the following line can always be compiled
 s h1=$h
 set patstr="""abc""?1v2k" w !,@patstr
 s h2=$h
 s dif=$$^difftime(h2,h1)
 w !,"TIME: (t.m) ",dif,!
 ;w !,"Now trying Y and Z:"
 ; NOTE: the following line can ONLY be compiled if the current
 ;       pattern table contains entries for ZvowelZ and YconsonY
 ; w !,"abc"?1ZvowelZ1YconsonY1k
 q
