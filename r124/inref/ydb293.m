;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb293
	write "# Updating the database, which will trigger a switch of gld files"
        for i=1:1:3  do
        . new $zgbldir
        . set ^a(i)=i
        quit
trig    ;
	open "newdir.txt"
	use "newdir.txt" read newdir
	use $principal
        set $zgbldir=newdir_"/mumps.gld"
	kill newdir
	close "newdir.txt"
        set ^a($ztval)=$ztval
        quit
trigx   ;
        set ^b($ztval)=$ztval
        quit
dump    ;
	open "newdir.txt"
	use "newdir.txt" read newdir
	use $principal
        for gbldir="mumps.gld",newdir_"/mumps.gld" do
        . set $zgbldir=gbldir
        . write "---> $zgbldir = ",$zgbldir,!
        . if $data(^a) zwrite ^a
        . if $data(^b) zwrite ^b
        quit


