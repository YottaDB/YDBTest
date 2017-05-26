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

; Routine to validate the output of ZSHOW "A" at present time based on the provided arguments:
;
;   dirCount - The number of directories to expect in the report. If the value is negative, do not use any count
;              with dirBase when matching the directory name.
;   dirBase  - Base of the directory name to which (optionally) append the index for name matching.
;   objCount - Number of objects to expect in each directory. If the value is negative, only ensure that the
;              number of records found is less than that.
;   error    - String where the error message is to be placed, if needed.
;   rctldump - Variable where the output of ZSHOW "A" is to be redirected.
;
rctldump(dirCount,dirBase,objCount,error,rctldump)
	new i,j,l,dirPrefix,expDir,line,pos,dir,records,rtns,rtnName,quit,innerQuit,recCountMatch

	set error=""
	if (dirCount>0) set dirPrefix=1
	else  set dirCount=-dirCount,dirPrefix=0
	if (objCount>0) set recCountMatch=1
	else  set objCount=-objCount,recCountMatch=0
	zshow "A":rctldump
	set (l,quit)=0

	for i=dirCount:-1:1 do  quit:quit
	.	set l=l+1
	.	if ('$data(rctldump("A",l))) set error="Could not read line "_l_" of zshow ""A""." set quit=1 quit
	.	set line=rctldump("A",l)
	.	if ("Object Directory"'=$extract(line,1,16)) set error="Unexpected output on line "_l_" of zshow ""A""." set quit=1 quit
	.	set dir=$zparse($piece(line," ",12),"NAME")
	.	set expDir=$select(dirPrefix:dirBase_i,1:dirBase)
	.	if (expDir'=dir) set error="Expected '"_expDir_"' for entryname on line "_l_" of zshow ""A"" but got '"_dir_"'." set quit=1 quit
	.	set l=l+2
	.	if ('$data(rctldump("A",l))) set error="Could not read line "_l_" of zshow ""A""." set quit=1 quit
	.	set line=rctldump("A",l)
	.	set records=$piece(line," ",12) ; Extract the number of routines from the following string: "# of routines / max      : 100 / 100"
	.	if (""=records) set error="NULL output on line "_l_" of zshow ""A""." set quit=1 quit
	.	if ((recCountMatch&(objCount'=records))!('recCountMatch&(objCount<records))) set error="Expected (no more than) "_objCount_" records but got "_records_" on line "_l_" of zshow ""A""." set quit=1 quit
	.	kill rtns
	.
	.	quit:(0=records)
	.
	.	set innerQuit=0
	.	for l=l:1 do  quit:quit!innerQuit
	.	.	if ('$data(rctldump("A",l))) set error="Could not read line "_l_" of zshow ""A""." set quit=1 quit
	.	.	if (rctldump("A",l)["    rec#") set l=l-1,innerQuit=1 quit
	.
	.	quit:quit
	.
	.	for j=1:1:records do  quit:quit
	.	.	set l=l+1
	.	.	if ('$data(rctldump("A",l))) set error="Could not read line "_l_" of zshow ""A""." set quit=1 quit
	.	.	set line=rctldump("A",l)
	.	.	set rtnName=$piece(line," ",7)
	.	.	if ($data(rtns(rtnName))) set error="Duplicate routine '"_rtnName_"' on line "_l_" of zshow ""A""." set quit=1 quit
	.	.	set rtns(rtnName)=1
	quit (""'=error)
