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
pipe	;
	set njobs=8
	set jmaxwait=0
	set ^stop=0,^done=1
	do ^job("child^gtm8002",njobs,"""""")
	for i=1:1:15 quit:$get(^done)=njobs  hang 1
	set ^stop=1
	do wait^job
	; verify
	set error=0
	for i=1:1:njobs  do
	. if ^a(i)'=2  write "TEST-E-FAIL : ^a(",i,")=",^a(i)," : Expected=",2,!  if $incr(error)
	. if ^b(i)'=2  write "TEST-E-FAIL : ^b(",i,")=",^b(i)," : Expected=",2,!  if $incr(error)
	. if ^c(i)'=2  write "TEST-E-FAIL : ^c(",i,")=",^c(i)," : Expected=",2,!  if $incr(error)
	. ; Ensure child*.txt are all 0 bytes in size (before the fix, this would
	. ; contain bytes that should have gone to the *.dat files)
	. set file="child"_i_".txt"
	. open file:(readonly)
	. use file
	. read line
	. if (""'=line)!('$zeof) use $p write "TEST-E-FAIL : ",file," is not 0 in size",! if $incr(error)
	. close file
	. ; Ensure "mdevice*.m" contain the right data
	. if i#2=1 quit
	. for gbl="a","b","c" do
	. . set file="mdevice"_gbl_i_".m"
	. . open file:(readonly)
	. . use file
	. . for index=1,2 do
	. . . read line if (line'=(" set ^"_gbl_"("_i_")="_index)) do
	. . . . use $p
	. . . . write "TEST-E-FAIL : ",file," : Line ",index," is not correct : Expected = set ^"_gbl_"("_i_")="_index,!
	. . . . if $incr(error)
	. . . . use file
	. . if ('$zeof) do
	. . . read line
	. . . if (line'="")!('$zeof) use $p write "TEST-E-FAIL : ",file," eof not reached",! if $incr(error)
	. . else  use $p  write "TEST-E-FAIL : ",file," : Premature EOF detected",! if $incr(error)
	. . close file
	if 'error write "--> Test PASSED",!
	quit

child	;
	if jobindex=1 do specialchild
	set pipe="gtmPipe",pipeErr="gtmErr"
	open pipe:(command="ps -ef":stderr=pipeErr)::"PIPE"
	use pipe
	write /eof
	if jobindex#2=1 do
	. ; case (a) : open THREE database files
	. set ^a(jobindex)=1,^b(jobindex)=1,^c(jobindex)=1
	else  do
	. ; case (b) : open THREE M file devices
	. set mdevicea="mdevicea"_jobindex_".m"
	. open mdevicea:(newversion)
	. use mdevicea
	. write " set ^a("_jobindex_")=1",!
	. set mdeviceb="mdeviceb"_jobindex_".m"
	. open mdeviceb:(newversion)
	. use mdeviceb
	. write " set ^b("_jobindex_")=1",!
	. set mdevicec="mdevicec"_jobindex_".m"
	. open mdevicec:(newversion)
	. use mdevicec
	. write " set ^c("_jobindex_")=1",!
	view "DBFLUSH"
	close pipe
	set file="child"_jobindex_".txt"
	open file:(newversion)
	use file
	if jobindex#2=1 do
	. ; case (a) continuation
	. set ^a(jobindex)=2,^b(jobindex)=2,^c(jobindex)=2
	else  do
	. ; case (b) continuation
	. use mdevicea
	. write " set ^a("_jobindex_")=2",!
	. close mdevicea
	. use mdeviceb
	. write " set ^b("_jobindex_")=2",!
	. close mdeviceb
	. use mdevicec
	. write " set ^c("_jobindex_")=2",!
	. close mdevicec
	. ; do the same sets as case (a) but through an M program
	. for gbl="a","b","c" do @("^mdevice"_gbl_jobindex)
	. use file
	hang $r(8)
	view "DBFLUSH"
	if $incr(^done)
	quit

specialchild	;
	for i=1:1  quit:^stop=1  set (^a(jobindex,i),^b(jobindex,i),^c(jobindex,i))=$j(jobindex,10000)
	quit

