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
xecutelimits	;
	new gap,max,file,i,j,k
	set gap=$piece($zcmdline," ",1)
	set max=$piece($zcmdline," ",2)
	set file="xecutelimits_"_gap_"_"_max_".trg"
	open file:(newversion:stream:nowrap)
	use file:(width=65535:nowrap)
	for i=gap-3,gap-2,gap-1,gap,gap-1,gap-2,gap-3 do
	. write "+^SAMPLE("_$incr(k)_") -commands=S -xecute=<<",!
	. for j=1:1:max write " write 1,!",$j("write 2,!",i),!
	. write ">>",!
	close file
	quit
