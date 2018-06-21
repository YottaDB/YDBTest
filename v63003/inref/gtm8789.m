;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm8789
        for i=1:1:3  do
        . new $zgbldir
        . set ^a(i)=i
        quit
trig    ;
        set $zgbldir="x.gld"
        set ^a($ztval)=$ztval
        quit
trigx   ;
        set ^b($ztval)=$ztval
        quit
dump    ;
        for gbldir="mumps.gld","x.gld" do
        . write "---> $zgbldir = ",gbldir,!
        . set $zgbldir=gbldir
        . if $data(^a) zwrite ^a
        . if $data(^b) zwrite ^b
        quit


