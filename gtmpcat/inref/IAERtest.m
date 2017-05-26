;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; InterActive EntryRef demonstrator.
;
	new results1,results2,i,j,line,regname,critadr
	;
	; First, do a "cache all" to see what regions are attached and get addresses for their sections
	;
	do DoPcatCmd^gtmpcat("cache all",.results1)
	;
	; For each "lock_space" found in the results, grab mlk_ctldata
	;
	for i=1:1:results1(0) do
	. if (0'=$zfind(results1(i),"lock_space")) do
	. . set line=results1(i)
	. . do EliminateExtraWhiteSpace^gtmpcat(.line)
	. . set regname=$zpiece(line," ",1)
	. . set critadr=$zpiece(line," ",3)
	. . do DoPcatCmd^gtmpcat("dmp mlk_ctldata "_critadr,.results2)
	. . ;
	. . ; Locate the prccnt, blkcnt, and wakeup count and print them out
	. . ;
	. . for j=1:1:results2(0) do
	. . . if (0'=$zfind(results2(j),".prccnt")) do
	. . . . set line=results2(j)
	. . . . do EliminateExtraWhiteSpace^gtmpcat(.line)
	. . . . write "Region ",regname," prccnt: ",$zpiece(line," ",9,11),!
	. . . if (0'=$zfind(results2(j),".blkcnt")) do
	. . . . set line=results2(j)
	. . . . do EliminateExtraWhiteSpace^gtmpcat(.line)
	. . . . write "Region ",regname," blkcnt: ",$zpiece(line," ",9,11),!
	. . . if (0'=$zfind(results2(j),".wakeups")) do
	. . . . set line=results2(j)
	. . . . do EliminateExtraWhiteSpace^gtmpcat(.line)
	. . . . write "Region ",regname," wakeups: ",$zpiece(line," ",9,11),!
	quit
