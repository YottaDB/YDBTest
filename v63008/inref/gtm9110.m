;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This tests for the new GT.M shell command line limit of 32KiB.
;Exceeding the limit issues an error of CLISTRTOOLONG or
;CLIERR. In previous versions it caused a segemntation violation.
;CLISTRTOOLONG will be produced by using -run to run a command string
;over 32KiB.
	set cmdstr1="$ydb_dist/yottadb -run "
	set cmdx=$justify("",33000,1)
	set cmdx=$translate(cmdx," ","x")
	set cmdstr1=cmdstr1_cmdx
	write "# Checking for CLISTRTOOLONG(in v63007 a segmentation fault occurs)",!
	zsy ""_cmdstr1_""
