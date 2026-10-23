;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mergeop;;
;	Test for merge among globals & locals with varying null collation order among them. All cases should be successful
globalglobal;
	SET ^aglobalvar("")=10
	SET ^aglobalvar(1)=1
	SET ^aglobalvar(1,"")=11
	SET ^aglobalvar(1,"",1)=111
	SET ^bvariableglobally("")=20
	SET ^bvariableglobally(2)=2
	SET ^bvariableglobally(2,"")=22
	SET ^bvariableglobally(2,"",1)=222
	SET ^c("")=30
	SET ^c(3)=3
	SET ^c(3,"")=33
	SET ^c(3,"",1)=333
	SET ^c(3,"",3)=700
	SET ^d("")=40
	SET ^d(4)=4
	SET ^d(4,"")=44
	SET ^d(4,"",1)=444
	ZWR ^aglobalvar,^bvariableglobally,^c,^d
;
	write "=====================================================",!
	WRITE "MERGE global=global",!
;
;	merge two globals of same std. null collation
	write "MERGING ^aglobalvar(1)=^c(3,"") Result in std.nullcollation",!
	MERGE ^aglobalvar(1)=^c(3,"")
	write "naked reference now is ",$reference,!
	write "naked indicator checked, value written should be 11",!
	zwrite ^(1,"")
	ZWRITE ^aglobalvar
;
;	merge nostd. null collating globals with std. null collating globals
	write "MERGING ^d(4)=^aglobalvar(1) Result in nostd.nullcollation",!
	MERGE ^d(4)=^aglobalvar(1)
	write "naked reference now is ",$reference,!
	write "naked indicator checked, value written should be 11",!
	zwrite ^(4,"")
	ZWRITE ^d
;
;	merge std. null collating globals with nostd. null collating globals
	write "MERGING ^c(3,"")=^bvariableglobally(2) Result in std.nullcollation",!
	MERGE ^c(3,"")=^bvariableglobally(2)
	write "naked reference now is ",$reference,!
	write "naked indicator checked, value written should be 700",!
	zwrite ^("",3)
	ZWR ^c
;
;	merge two globals of same nostd. null collation
	write "MERGE ^bvariableglobally(2)=^d(4) Result in nostd.nullcollation",!
	MERGE ^bvariableglobally(2)=^d(4)
	write "naked reference now is ",$reference,!
	write "naked indicator checked, value written should be 111",!
	zwrite ^(2,"",1)
	ZWRITE ^bvariableglobally
;
globallocal;
	SET lcl("")="null"
	SET lcl(5)="five"
	SET lcl(5,"")="five_null"
	SET lcl(5,"",1)="five_null_one"
	SET lcl(5,"","x")="five_null_x"
	ZWRITE lcl
	ZWRITE ^aglobalvar
;
	write "=====================================================",!
	WRITE "MERGE global=local",!
;
;	merge std. null collating globals with nostd. null collating locals
	WRITE "MERGE ^aglobalvar(1)=lcl(5,"""") Result in std.nullcollation",!
	MERGE ^aglobalvar(1)=lcl(5,"")
	ZWRITE ^aglobalvar
;
;	merge globals with locals of same nostd. null collation
	WRITE "MERGE ^bvariableglobally(2)=lcl(5,"""") Result in nostd.nullcollation",!
	MERGE ^bvariableglobally(2)=lcl(5,"")
	ZWRITE ^bvariableglobally
;
;	change locals collating order to M std.
	kill lcl
	WRITE $$set^%LCLCOL(0,1)
	SET lcl("")="null"
	SET lcl(5)="five"
	SET lcl(5,"")="five_null"
	SET lcl(5,"",1)="five_null_one"
	SET lcl(5,"","x")="five_null_x"
	ZWRITE lcl
;
;	merge globals with  locals of same std. null collation
	WRITE "MERGE ^aglobalvar(1)=lcl(5,"") Result in std.nullcollation",!
	MERGE ^aglobalvar(1)=lcl(5,"")
	ZWRITE ^aglobalvar
;
;	merge nostd. null collating globals with std. null collating locals
	WRITE "MERGE ^bvariableglobally(2)=lcl(5,"""") Result in nostd.nullcollation",!
	MERGE ^bvariableglobally(2)=lcl(5,"")
	ZWRITE ^bvariableglobally
;
localglobal;
;
	write "=====================================================",!
	WRITE "MERGE local=global",!
;
;	merge locals with  globals of same std. null collation
	WRITE "MERGE lcl(5,"""")=^aglobalvar(1) Result in std.nullcollation",!
	MERGE lcl(5,"")=^aglobalvar(1)
	ZWRITE lcl
	write "naked reference now is ",$reference,!
	write "check naked indicator reference here, value written should be 11",!
	zwrite ^(1,"")
;
;	merge std. null collating locals with  nostd null collating globals
	WRITE "MERGE lcl(5,"""")=^bvariableglobally(2) Result in std.nullcollation",!
	MERGE lcl(5,"")=^bvariableglobally(2)
	ZWRITE lcl
	write "naked reference now is ",$reference,!
	write "check naked indicator reference here, value written should be 111",!
	zwrite ^(2,"",1)
;
;	change locals collating order to GT.M std.
	kill lcl
	WRITE $$set^%LCLCOL(0,0)
	SET lcl("")="null"
	SET lcl(5)="five"
	SET lcl(5,"")="five_null"
	SET lcl(5,"",1)="five_null_one"
	SET lcl(5,"","x")="five_null_x"
;
;	merge nostd. null collating locals with  std null collating globals
	WRITE "MERGE lcl(5,"""")=^c(3,"") Result in nostd.nullcollation",!
	MERGE lcl(5,"")=^c(3,"")
	ZWRITE lcl
	write "naked reference now is ",$reference,!
	write "check naked indicator reference here, value written should be 700",!
	zwrite ^("",3)
;
;	merge locals with  globals of same nostd. null collation
	WRITE "MERGE lcl(5,"""")=^d(4) Result in nostd.nullcollation",!
	MERGE lcl(5,"")=^d(4)
	ZWRITE lcl
	write "naked reference now is ",$reference,!
	write "check naked indicator reference here, value written should be 11",!
	zwrite ^(4,"")
	quit
;
