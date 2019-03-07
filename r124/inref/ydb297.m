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
ydb297
	set ^X(1)=1
	set ^X(2)=0
	set ^X(3)=0
	set ^X(4)=$ZTRNLNM("hang")
	do ^job("lockhang^ydb297",3,"""""")
	quit
lockhang
	for  quit:^X(jobindex)
	set substr="10096 10153 10221 10304 10789 11114 11121 11302 "
        set substr=substr_"11348 11367 11396 11464 11675 12120 12158 12311 "
        set substr=substr_"12371 12459 12766 13021 13248 13432 13448 13537 "
        set substr=substr_"13618 13845 13986 14060 14156 14347 14854 15148 "
        set substr=substr_"15207 15227 15720 15818 15967 16199 16407 16514 "
        set substr=substr_"16586 17021 17083 17399 17449 17489 17633 17674 "
        set substr=substr_"17711 17741 18189 18450 18495 18684 18799 18949 "
        set substr=substr_"19049 19291 19399 19478 19615 19875 19908 20057 "
        set substr=substr_"20182 20190 20500 20545 20619 20934 20994 21039"
	for i=1:1:$length(substr," ") do mylock($piece(substr," ",i))
	zsystem "$LKE show |& $grep SPACEINFO"
	set ^X(jobindex+1)=1
	for  quit:^X(4)
	write "# SEGMENT DATA--NUMBER OF TIMES OVER 31 LOCKS HASHED TO THE SAME VALUE: "
	write $$^%PEEKBYNAME("sgmnt_data.lock_hash_bucket_full_cntr","DEFAULT")
	quit

mylock(subs)
        set name="^a("_subs_")"
        write "Attempting LOCK +",name,":0"
        LOCK +@name:0
        if $test=1  write " : SUCCESS",!
        else        write " :  -------------------------> FAILURE",!
        quit


