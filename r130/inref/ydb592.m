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

ydb592	;
	lock ^sync
        job jobstart
	set ^pid("Parent")=$job
	set ^pid("Child")=$zjob
	lock  ; signal child to do zsystem
	do ^waitforproctodie(^pid("Child"))
        quit

jobstart
	new pidsub,pidstr
	lock ^sync
	set pidsub="" for  set pidsub=$order(^pid(pidsub)) quit:pidsub=""  do
	. write pidsub_" pid shows up in ps -ef output as : "
	. set pidstr="^"_^pid(pidsub)_" "
	. ; see how process shows up in ps -ef output
	. ; first cut and sed is to remove the userid column (first column)
	. ; next grep is to search for the desired pid
	. ; next sed is to trim out everything until the first '/' which is the start of the command line of the process
        . set zsystr="ps -ef | cut -d ' ' -f 2- | sed 's/^  *//g' | grep '"_pidstr_"' | sed 's,.* /,/,'"
	. zsystem zsystr
        quit

