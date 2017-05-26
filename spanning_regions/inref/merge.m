;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
merge	;
	for i=0:1:40 set ^a(i)=i
	write "# zwrite ^a with the default $zgbldir = ",$zgbldir,!
	zwr ^a
	write "# merge with extended reference ^|x.gld|a(1)=^a",!
	merge ^|"x.gld"|a(1)=^a
	set $zgbldir="x.gld"
	write "# zwrite ^a  : $zgbldir = ",$zgbldir,!
	zwr ^a
	write "# merge with extended reference ^|mumps.gld|a=^|x.gld|a",!
	merge ^|"mumps.gld"|a=^|"x.gld"|a
	set $zgbldir="mumps.gld"
	write "# zwrite ^a after the merge : $zgbldir = ",$zgbldir,!
	zwr ^a
	write "# kill ^a - set ^a - zwr ^a : $zgbldir = ",$zgbldir,!
	k ^a
	set ^a=3
	zwr ^a
	set $zgbldir="x.gld"
	write "# kill ^a(1) - set ^a - zwr ^a : $zgbldir = ",$zgbldir,!
	set ^a=2
	k ^a(1)
	zwr ^a
	quit
