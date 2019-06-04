;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	;
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
        ; Below are subscripts that hash to the same value (3857812303) modulo 4G (i.e.2**32)
        set substr="1445240077 4097034630 4388659035 4630999867 5407955935 6251931759 11417300836 10290985601"
        set substr=substr_" 11005068295 11434779216 12514012645 12676101741 17058576286 18738986112 18480244186 17280277179"
        set substr=substr_" 18379984114 24440525326 21696035853 25089805580 25561658649 29582647612 30357044280 27414314996"
        set substr=substr_" 32074740586 28582294681 31467579889 36848531774 46427764934 41893554996 48113940994 43052926029"
        set substr=substr_" 44129775493 47697200707 54939630888 55988509030 57060549750 51493002061 60309326336 53984812611"
        set substr=substr_" 54917189673 61308148430 56066818915 56431408489 63495468474 68545605854 66623834096"
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
