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
mergecoll ;
	kill ^a,^b,^c
	set ^a(1,"")=100
	set ^a(1,2,3,"dfg")=300
	set ^a(1,2,"abc")=200
	set ^a(1)=900
	set ^a("efgh")=1000
	write "zwrite ^a",!
	zwrite ^a
	set $ztrap="goto errorAndCont^errorAndCont"
	;
	write !,"# kill ^b ; merge ^b=^a ; zwrite ^b",!
	merge ^b=^a
	zwrite ^b
	write !,"# kill ^c ; merge ^c=^a ; zwrite ^c",!
	write "# Since CREG does not allow null subscripts, the below merge shoud error out",!
	merge ^c=^a
	zwrite ^c
	set isspan=$ztrnlnm("gtm_test_spanreg")
	if ((1=isspan)!(3=isspan)) do
		. write !,"# kill ^c ; merge ^c(1,2)=^a ; zwrite ^c",!
		. write "# ^c(1,2) maps to DEFAULT, which allows null subscripts. So the below merge should be fine",!
		. kill ^c
		. merge ^c(1,2)=^a
		. zwrite ^c
	;
	write !,"# kill ^b ; merge ^b(""xyz"")=^a ; zwrite ^b",!
	kill ^b
	merge ^b("xyz")=^a
	zwrite ^b
	;
	write !,"# kill ^b ; merge ^b(""xyz"")=^a(1) ; zwrite ^b",!
	kill ^b
	merge ^b("xyz")=^a(1)
	zwrite ^b
	;
	write !,"# kill ^a ; merge ^a(""efgh"")=^b ; zwrite ^a",!
	kill ^a
	merge ^a("efgh")=^b
	zwrite ^a
	;
	write !,"# kill ^a ; merge ^a(""efgh"")=^b(""xyz"",2) ; zwrite ^a",!
	kill ^a
	merge ^a("efgh")=^b("xyz",2)
	zwrite ^a
	quit
