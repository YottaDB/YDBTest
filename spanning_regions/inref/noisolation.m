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
noisolation	;
	write "# Randomly open a few regions by doing global refrences that map to those regions",!
	set reflist=$ztrnlnm("noisolation_reflist")
	for i=1:1:10 set ref(i)=$piece(reflist," ",i) if 1=ref(i) set sub=10**i+i set ^global(sub)=1
	write "# Check there is no memory addition due to repeated view NOISOLATION",!
	for i=1:1:10 view "NOISOLATION":"^global"
	set zrealstor1=$zrealstor
	for i=1:1:1000 view "NOISOLATION":"^global"
	set zrealstor2=$zrealstor
	write:zrealstor1'=zrealstor2 "ZREALSTOR-E-NOTSAME $zrealstor not the same : zrealstor1=",zrealstor1,"zrealstor2=",zrealstor2,!
	write "# Open the remaining regions by doing corresponding global references. There should be no errors",!
	for i=1:1:10 if 0=ref(i) set sub=10**i+i set ^global(sub)=0
