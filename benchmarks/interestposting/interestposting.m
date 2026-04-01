;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

interestposting
	set njobs=+$zcmdline
	set ^acn=0,^count=0,^jobcount=0
	set ^stage=1
	for i=1:1:njobs job child set child(i)=$zjob
	for  quit:^jobcount=i  hang 0.1
	set ^stage=2
	set numaccts=^numaccts
	set start=$zut
	for  quit:^count=njobs  hang 0.001
	set end=$zut
	set ^stage=3
	for i=1:1:njobs set pid=child(i) for  quit:'$zgetjpi(pid,"ISPROCALIVE")  hang 0.001
	write "Jobs = ",njobs," : Time taken by ",$ztrnlnm("verno")," = ",end-start/(10**6)," seconds",!
	quit

child
	set numaccts=^numaccts
	if $increment(^jobcount)
	for  quit:^stage=2  hang 0.1

	for  set acn=$increment(^acn)  quit:acn>numaccts  do
	.	tstart ():serial
	.	set val=^ACN(numaccts+acn)
	.	set balance=$piece(val,"|",2)*1.05
	.	set $piece(val,"|",2)=balance
	.	set ^ACN(numaccts+acn)=val
	.	tcommit
	if $increment(^count)
	for  quit:^stage=3  hang 0.1
	quit

dbinit	;
	set ^numaccts=1000000
	set numaccts=^numaccts
	for i=1:1:numaccts set ^ACN(i+numaccts)=$j(" ",50)_"|"_(numaccts+i)_"|"_$j(" ",50)
	quit

