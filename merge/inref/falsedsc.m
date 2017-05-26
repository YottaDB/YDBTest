;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
falsedsc;
	write "falsedsc test starts",!
	write "S9B12-002008 MERGE command gives false MERGEDESC error",!
	set $ZTRAP="GOTO errcont^errcont"
	set ^var(100)=100
	set ^var(100,200)=300
	set ^var("ind")="abc"
	set ^var("ind1")="def"
	set ^var("ind2")="ghi"
	set ^var("ind2","ind4")="jkl"
	;
	merge ^var2("new")=^var
	write "ZWR ^var2",!  zwrite ^var2
	;
	merge ^var(102)=^var(100)
	write "ZWR ^var(102)",!  zwrite ^var(102)
	kill ^var(102)
	;
	merge ^var(100,209)=^var(100,200)
	write "ZWR ^var(100,209)",!  zwrite ^var(100,209)
	kill ^var(100,209)
	;
	merge ^var(1000)=^var(100)
	write "ZWR ^var(1000)",!  zwrite ^var(1000)
	kill ^var(1000)
	;
	merge ^var(10)=^var(100)
	write "ZWR ^var(10)",!  zwrite ^var(10)
	kill ^var(10)
	;
	merge ^var("inda")=^var("ind")
	write "ZWR ^var(""inda"")",!  zwrite ^var("inda")
	kill ^var("inda")
	;
	kill ^var("ind3")
	merge ^var("ind3")=^var("ind2")
	write "ZWR ^var(""ind3"")",!  zwrite ^var("ind3")
	;
	kill ^var("ind")
	merge ^var("ind")=^var("ind2")
	write "ZWR ^var(""ind"")",!  zwrite ^var("ind")
	;
	write "GTM-6935 MERGE self c/should be a NOOP rather than an error",!
	kill ^var
	set ^var="Hello world"
	merge ^var=^var
	write "ZWR ^var",!  zwrite ^var
	;
	new varlcl
	set varlcl="Hello local world"
	merge varlcl=varlcl
	write "ZWR varlcl",! zwrite varlcl
	;
	new i,j
	kill ^var
	set ^var(5)="str"
	for i=1:1:10 merge ^var(5)=^var(i) write "i=",i,!
	;
	set varlcl(5)="strlcl"
	for j=1:1:10 merge varlcl(5)=varlcl(j) write "j=",j,!
	;
	write "GTM-3589 MERGE of an undefined value should be a NOOP rather than an error",!
	kill ^var,varlcl
	merge ^var(1)=^var
	merge varlcl(1)=varlcl
	merge ^var(1)=varlcl
	merge varlcl(1)=^var
	write "$data(^VAR)=",$data(^VAR),!
	write "$data(^varlcl)=",$data(^lcl),!
	;
	write "Test of MERGE LVN1(1,2)=LVN2 where both src and dst are undef at time of merge",!
	merge LVN1(1,2)=LVN2
	write "$query(LVN1(1)) = ",$query(@"LVN1(1)"),!
	;
	write "falsedsc test done",!
	;
	quit


