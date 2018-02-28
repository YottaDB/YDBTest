;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nestedtriggers ;
        ; Load one trigger for ^a that does a set ^b=1
        if $ztrigger("item","+^a -name=a0 -commands=S -xecute=""set ^b=1""")
	set jmaxwait=0
	set ^stop=0
        do ^job("child^nestedtriggers",8,"""""")
	hang 15
	set ^stop=1
	do wait^job
        quit

child   ;
        for i=1:1 quit:^stop=1  do
        . set ^a=1
        . set j=i#3
        . ; Keep adding and deleting triggers for "set ^b" (concurrently done by multiple children)
        . ; thereby causing the likelihood of restarts while trying to read a nested trigger source
        . ; This exposed a bug where nested triggers cause the process to sometimes terminate
        . ; abnormally with SIGABRT (SIG6) error. In dbg, one used to see a stack-smashing error.
        . if $ztrigger("item","+^b -name=myname"_$j_j_" -commands=S -xecute=""write "_i_",!""")
        . if $ztrigger("item","-^b -name=myname"_$j_j_" -commands=S -xecute=""write "_i_",!""")
        quit
