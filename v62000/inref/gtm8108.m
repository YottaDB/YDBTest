;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8108	;
	quit

test1	;
	zshow "C":x(1)
	write $query(@"x"),!
	quit

test2	;
	zshow "B":x(1)
	write $query(@"x"),!
	quit

test3	;
	set @"x(1)"=dflt  write $query(@"x"),!
	quit

test4	;
	do ^sstep
	set x=1,*y(1)=x,z="y(2)"
	set @z=y(1)
	zwrite
	kill *
	zwrite
	quit

test5	;
        set ^stop=0
        set jmaxwait=0
        do ^job("test5child^gtm8108",10,"""""")
        hang 15
        set ^stop=1
        do wait^job
        quit
test5child ;
	set i=0
        for  quit:^stop=1  do
	. set istp=$random(2)
        . if istp tstart ():serial
	. ; do $query of most recent 3 sibling nodes to make sure active_lv has been maintained correctly all along
        . set x=$query(@"a($j,i-3)")
        . set x=$query(@"a($j,i-2)")
        . set x=$query(@"a($j,i-1)")
        . merge a($j,$incr(i))=^x(i)
        . if istp tcommit
        . kill ^x(i,$j) set ^x(i,$j)=$j	; induce restarts in MERGE command done above
	; Do one final active_lv maintenance check
        for j=1:1:i set x=$query(@"a($j,j)")
        quit
