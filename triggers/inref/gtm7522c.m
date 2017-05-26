;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7522c;
	; below is a test that $ztrigger output is correct even in case of concurrency related restarts
	set ^njobs=1+$r(10),^numtriggers=1+$r(10)
	set jmaxwait=0,^stop=0
	do ^job("child^gtm7522c",^njobs,"""""")
	; run the test for about 15 seconds (stop sooner if a failure is detected)
	for i=1:1:15  quit:^stop=1  hang 1
	set ^stop=1
	do wait^job
	quit

child	;
	; each child picks up a range of triggers that dont intersect the other children.
	; and these triggers get loaded, deleted, loaded, deleted, ... in a loop
	; we expect each child's output to be independent of restarts due to concurrent trigger updates by other children.
	set trgfile="child"_jobindex_".trg"
	set njobs=^njobs,maxi=(jobindex+(njobs*^numtriggers))
	open trgfile:(newversion)
	use trgfile
	for i=jobindex:njobs:maxi write "+^a"_i_" -commands=S -xecute=""set x=1""",!
	for i=jobindex:njobs:maxi write "-^a"_i_" -commands=S -xecute=""set x=1""",!
	close trgfile
	; compute expected output
	set cmpfile="child"_jobindex_".cmp"
	set selfile="child"_jobindex_".sel"
	zsystem "$gtm_exe/mumps -run gentrigload^randomtriggers "_trgfile_" "_cmpfile_" "_selfile
	; read .cmp file to facilitate later comparison
	open cmpfile:(readonly)
	use cmpfile
	for j=1:1  read cmpline(j)  quit:$zeof
	if cmpline(j)="" if $incr(j,-1)
	;
	set outfile="child"_jobindex_".log"
	for k=1:1 quit:^stop=1  do
	. open outfile:(newversion)
	. use outfile
        . if '$ZTRIGGER("FILE",trgfile)  write "TEST-E-FAIL",!
	. close outfile
	. ; check whether two files are identical
	. open outfile
	. use outfile
	. for i=1:1  read outline  quit:($zeof!(outline'=cmpline(i)))
	. if cmpline(i)="" if $incr(i,-1)
	. if ('$zeof!(i'=j)) use $p write "TEST-E-FAIL",!  zshow "*"  set ^stop=1  halt
	. close outfile:delete
	set ^index(jobindex)=k
	quit

