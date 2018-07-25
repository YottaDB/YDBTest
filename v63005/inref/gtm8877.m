;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
zsystemfn
	set $etrap="do incrtrap^incrtrap"
	zsystem "echo 'original input'"
	quit

pipeopenfn
	set $etrap="do incrtrap^incrtrap"
	set p="pipe"
	open p:(command="echo 'original input'")::"PIPE"
	use p
	read x
	use $p
	write x
	close p
	quit

tpzsystemfn
	set $etrap="do incrtrap^incrtrap"
	tstart
	do zsystemfn^gtm8877
	tcommit
	quit

tppipeopenfn
	set $etrap="do incrtrap^incrtrap"
	tstart
	do pipeopenfn^gtm8877
	tcommit
	quit

filterfn(inarg,outarg)
	set outarg=-1
	quit +outarg

filterfn2(inarg,outarg)
	set outarg="echo 'filtered output'"
	quit +outarg

reczsystfilter(inarg,outarg)
	set outarg="echo 'recursive zsystem'"
	zsystem outarg
	quit +outarg

recpipefilter(inarg,outarg)
	set outarg="echo 'recursive pipe'"
	set p="pipe"
	open p:(command=outarg)::"PIPE"
	quit +outarg
