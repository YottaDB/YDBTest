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

; This script creates the specified number of directories (first argument) dir1, dir2, dir3, and so on, each containing a certain
; (third argument) number of object files. It then fires off several (second argument) jobs to collectively attempt a ZRUPDATEs on
; every object file in every directory (dir1/relinksrch1.o, dir1/relinksrch2.o, ... , dir2/relinksrch1.o, dir2/relinksrch2.o, etc.).
; The jobs split the load randomly, thus ensuring a random routine-name entry into the relinkctl file. Because one more object file
; is ZRUPDATEd in each directory than supported per relinkctl file (the limit is lowered to 100 via a white-box test), at least one
; job is bound to fail with RELINKCTLFULL.
relinksrch
	new i,ndirs,njobs,nobjs,error,rctldump

	set ^ndirs=$piece($zcmdline," ",1)
	set ^njobs=$piece($zcmdline," ",2)
	set ^nobjs=$piece($zcmdline," ",3)
	set ndirs=^ndirs
	set njobs=^njobs
	set nobjs=^nobjs
	for i=1:1:ndirs  set $zroutines=$zroutines_" dir"_i_"*(dir"_i_")"
	do ^job("child^relinksrch",^njobs,"""""")
	if $$^rctldump(ndirs,"dir",-(nobjs-1),.error,.rctldump) write "TEST-E-FAIL, "_error,! zwrite rctldump zhalt 1
	quit

child
	new i,j,k,l,ndirs,njobs,nobjs,rtn,newrtn

	set ndirs=^ndirs
	set njobs=^njobs
	set nobjs=^nobjs
	set $zroutines=".*(.)"
	set k=0
	for i=1:1:ndirs  set $zroutines=$zroutines_" dir"_i_"*(dir"_i_")" do
	.	for j=jobindex:njobs:nobjs set rtn($incr(k))="dir"_i_"/relinksrch"_j_".o"
	write "Before sorting  : $h = ",$h,!
	for i=1:1:k do
	.	set l=(k-i+1)
	.	set j=$random(l)+1
	.	set newrtn(i)=rtn(j)
	.	if (j'=l) set rtn(j)=rtn(l)
	write "After sorting  : $h = ",$h,!
	zwrite newrtn
	do
	.	new $etrap
	.	set $etrap="lock +^rctlerror set x=""rctlerror.log"" open x:newversion use x write $zstatus close x set $ecode="""" lock -^rctlerror"
	.	for i=1:1:k zrupdate newrtn(i)
	write "After ZRUPDATE : $h = ",$h,!
	quit

error(text)
	use $principal
	write text,!
	zhalt 1
