;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zjobv(k) ; drive zjob
	if $zjob'=0 w "FAILED: non-zero initial value of $ZJOB",! q
	for i=1:1:k do
	. kill ^zjout(0) lock +^x
	. job ^zjob(i)
	. set ^zjobs(i)=$zjob lock -^x
	. for j=1:1 quit:$$^isprcalv($zjob)=0  hang 0.1 ; wait till child process really dies
	. write ^zjout(i),!
	quit

zjobi	; invalid label reference
	new zjob job ^zjob(1) set ^goodjob=$zjob
	write $zjob,!
	job invlab^zjob(1):(error="zjobi.mje")
	quit
