;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2004, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testnct	;
	set ^TESTINGLONGGLOBALNAME2345678901(1)=1
	set ^TESTINGLONGGLOBALNAME2345678901(-1)=-1
	set ^TESTINGLONGGLOBALNAME2345678901("%")="%"
	set ^TESTINGLONGGLOBALNAME2345678901("-2")="-2"
	set ^TESTINGLONGGLOBALNAME2345678901("ABCDEFGHIJKL")="ABCDEFGHIJKL"
	set ^TESTINGLONGGLOBALNAME2345678901("ZYXWVUTSR")="ZYXWVUTSR"
	set ^TESTINGLONGGLOBALNAME2345678901("abcdefghi")="abcdefghi"
	set ^TESTINGLONGGLOBALNAME2345678901("zyxwvutsr")="zyxwvutsr"
	zwrite ^?1"T".E
	;test set, get and kill of GBLDEF
	write "Now testing set get and kill of GBLDEF",!
	set gname="^setgetandkillusageofgbldef78901"
	set status=$$get^%GBLDEF(gname)
	set expected=$select(($ztrnlnm("gtm_test_sprgde_id")="ID4"):"0,1,0",1:"0")
	do ^examine(status,expected,"get GBLDEF for "_gname_" ")
	set enabled=$$set^%GBLDEF(gname,1,0)
	do ^examine(enabled,"1","set GBLDEF for "_gname_" ")
	set status=$$get^%GBLDEF(gname)
	do ^examine(status,"1,0,0","get GBLDEF for "_gname_" ")
	;set a few globals and check the collation order
	for i=65:3:90 set @gname@($c(i))=$c(i)
	for i=98:3:122 set @gname@($c(i))=$c(i)
	for i=0:1:9 set @gname@(i)=i
	for i=10:10:100 set @gname@(i)=i
	zwrite @gname
	kill @gname
	;now test the kill
	set killed=$$kill^%GBLDEF(gname)
	do ^examine(killed,"1","kill GBLDEF for "_gname_" ")
	set status=$$get^%GBLDEF(gname)
	do ^examine(status,expected,"get GBLDEF for "_gname_" ")
	write "PASSED testing set get and kill of GBLDEF",!
