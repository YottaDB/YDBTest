;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2003, 2013 Fidelity Information Services, Inc	;
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
tpntpupd;
	; this test tries to do random database operations with random nested TP transactions with random TCOMMIT/TROLLBACK
	; this does a mix of nontp and tp transaction and assumes a multi-region database.
	; two routines that predate and are almost similar to this are v43001b test's d002164.m and v44003 test's c002134.m
	;
	; if ^secgldno is defined, it will randomly use that global directory (as well as the gtmgbldir)
	; then ^secgldnm will be pointing to the base name of the gld,
	; and the actual global directories will be named accordingly in the following fashion:
	; ^secgldno = 3
	; ^secgldnm = mumpssec
	; mumpssec0.gld
	; mumpssec1.gld
	; mumpssec2.gld
	; it will access the different global directories either by (re)setting $ZGBLDIR or with external references (^|"x.gld"|x)
	; if the two global directories use the same database files, this will test C9E04-002596
	;
	set $etrap="zshow ""*"" halt"
	set nreg=8
	set tpopers=1+$r(5)	; # of database operations within a TP transaction
	set tpopers=2**tpopers	; is randomly chosen anywhere from 2**1 to 2**5
	set tpnomultigld=$select(($ztrnlnm("test_subtest_name")="C9E04002596")&(""'=$ztrnlnm("test_replic")):1,1:0)
	;
	; Test that NOISOLATION commands for non-existent globals in the default global directory work fine even if
	; there is a huge list of non-existent globals that are specified. This is specifically present to test that
	; process_gvt_pending_list() processes the linked list of pending gvts correctly as each region gets opened.
	;
	if (""=$ztrnlnm("ydb_app_ensures_isolation")) do
	. VIEW "NOISOLATION":"+^aa,^aaa,^aaaa,^bb,^bbb,^bbbb,^cc,^ccc,^cccc,^dd,^ddd,^dddd"
	. VIEW "NOISOLATION":"+^ee,^eee,^eeee,^ff,^fff,^ffff,^gg,^ggg,^gggg,^hh,^hhh,^hhhh"
	. VIEW "NOISOLATION":"+^ii,^iii,^iiii"
	; else dse_cache.csh has already set the env var to the above list of globals
	;
	if $data(^secgldno)  do
	.	set secgldno=^secgldno
	.	if '$data(^secgldnm) write "TEST-E-NOGLD What is the gld name? Cannot go on." halt
	.	set secgldnm=^secgldnm
	.	; Before we start any database access, let us do some NOISOLATION related tests.
	.	; There is no global variable that we can turn on NOISOLATION but we want to test that VIEW "NOISOLATION" as well
	.	; so we choose to turn it ON on a few variables that we know for sure are not used in this testcase. Also try out
	.	; a test case where different NOISOLATION characteristics are specified for the same global name through different
	.	; global directories. Ensure the NOISOLATION specification spans across a lot of the database files.
	.	; Run the VIEW command BEFORE any databases are opened. Check their NOISOLATION status at the end of the process
	.	; when we are sure all databases would have been opened.
	.	; The tests below rely on the fact that we have at least 4 secondary global directories.
	.	;
	.	if secgldno'<4 do
	.	.	set $zgbldir=secgldnm_"0.gld"
	.	.	VIEW "NOISOLATION":"+^azzzz,^czzzz,^ezzzz,^gzzzz"
	.	.	set $zgbldir=secgldnm_"1.gld"
	.	.	VIEW "NOISOLATION":"-^azzzz,^bzzzz,^czzzz,^dzzzz,^hzzzz"
	.	.	set $zgbldir=secgldnm_"2.gld"
	.	.	VIEW "NOISOLATION":"+^czzzz,^azzzz,^bzzzz,^dzzzz,^gzzzz"
	.	.	set $zgbldir=secgldnm_"3.gld"
	.	.	VIEW "NOISOLATION":"-^fzzzz,^dzzzz,^hzzzz"
	.	.	; Note down the combinations we expect NOISOLATION to have a value TRUE at the end of the test
	.	.	; Every other combination we expect NOISOLATION to return a value FALSE.
	.	.	; This is tested at the end of the test.
	.	.	; The only global variables that need to have NOISOLATION value of 1 are ^ezzzz and ^gzzzz and
	.	.	; this should be true across ALL the 4 global directories.
	.	.	set expect(secgldnm_"0.gld","^ezzzz")=1
	.	.	set expect(secgldnm_"1.gld","^ezzzz")=1
	.	.	set expect(secgldnm_"2.gld","^ezzzz")=1
	.	.	set expect(secgldnm_"3.gld","^ezzzz")=1
	.	.	set expect(secgldnm_"0.gld","^gzzzz")=1
	.	.	set expect(secgldnm_"1.gld","^gzzzz")=1
	.	.	set expect(secgldnm_"2.gld","^gzzzz")=1
	.	.	set expect(secgldnm_"3.gld","^gzzzz")=1
	;
	set fullstr="abcdefghi"
	view "NOUNDEF"
	set maxindex=10**($r(4))
	;
	for  quit:^stop=1  do
	.	set level=0
	.	set type=$random(2)
	.	if type=0 do nontp
	.	if type=1 do tp
	;
	if $data(^secgldno)&(secgldno'<4)&('tpnomultigld) do
	.	; Before quitting, check that conflicting NOISOLATION statuses for the same global variable have
	.	; been resolved AFTER the database was opened. It is possible that the tp and nontp tests above did
	.	; not open all regions in all global directories. To work around that, open all regions before doing
	.	; the NOISOLATION test. The loop below is structured in such a way that it opens the regions in the
	.	; first iteration (iter=1) and tests the NOISOLATION values in the second (iter=2).
	.	;
	.	set globalstr="abcdefgh"
	.	set len=$length(globalstr)
	.	for iter=1:1:2  do
	.	.	for i=0:1:3  do
	.	.	.	set secgld=secgldnm_i_".gld"
	.	.	.	set $zgbldir=secgld
	.	.	.	for j=1:1:len  do
	.	.	.	.	set gbl="^"_$extract(globalstr,j)_"zzzz"
	.	.	.	.	if iter=1 set x=+$get(@gbl)	; ensure database file is opened in first iteration
	.	.	.	.	if iter=2  do
	.	.	.	.	.	set stat=$VIEW("NOISOLATION",gbl)
	.	.	.	.	.	if stat'=+$get(expect(secgld,gbl)) do
	.	.	.	.	.	.	; print out an error and ensure the test will fail
	.	.	.	.	.	.	; as long as '-E- is in the string, it will get caught by the test system
	.	.	.	.	.	.	write "TEST-E-NOISOL: Gld[",secgld,"] Gbl[",gbl,"] NOISOLATION[",stat,"]",!
	quit

nontp	;
	set space=$j(" ",$tl+1)
	do oper
	if $data(secgldno) do pickgld
	write space,str,!
	xecute str
	quit

tp	;
	do space
	; since we do a $r(nreg) below we will touch some but not all regions
	set count=$r(tpopers)
	write space,"tstart ():serial",!
	tstart ():serial
	if tpnomultigld&($tlevel=1)&$data(secgldno) do
	. set str="set tpgld="""_secgldnm_$random(secgldno)_".gld"""
	. write space,str,!
	. xecute str
	do space
	write space,"$trestart = ",$trestart,!
	for i=1:1:count  do
	.	set nest=$r(2)
	.	if nest=1 do tpnest
	.	do oper
	.	if ($data(secgldno))&(str'["tpgld") do pickgld
	.	write space,str,!
	.	if str'="" xecute str
	do space
	set tptype=$r(2)
	;i tptype=0 w space,"trollback ",$tl-1,! trollback $tl-1
	;e  w space,"tcommit",! tcommit
	write space,"tcommit",! tcommit
	do space
	quit

tpnest	;
	if level>1 quit
	set level=level+1
	do tp
	set level=level-1
	quit

space	;
	set space=$j("    ",($tl+1)*4)
	quit

oper	;
	set reg=$r(nreg+1)
	set global=$e(fullstr,reg+1)_"databaseoperationintpntpupdate"
	set index=$r(maxindex)
	set operation=$r(6)
	if operation=0 do xset
	if operation=1 do xkill
	if operation=2 do xget
	if operation=3 do xlock
	if operation=4 do xincr
	if operation=5 do noop
	quit

tpnomultigldcheck(str)
	if tpnomultigld set str="set $zgbldir=tpgld "_str
	quit

xset	;
	set str="set ^"_global_"("_index_")=$j($j,10+$r(7500))"
	do tpnomultigldcheck(.str)
	quit

xkill	;
	set str="kill ^"_global_"("_index_")"
	do tpnomultigldcheck(.str)
	quit

xget	;
	set str="set tmp=$get(^"_global_"("_index_"))"
	quit

xlock	;
	set str="lock +^"_global_"("_index_")  lock -^"_global_"("_index_")"
	quit
xincr	;
	set str="set x=$increment(^"_global_"("_index_"))"
	do tpnomultigldcheck(.str)
	quit

noop	;
	set str=""
	quit

pickgld	;
	; pick a global directory (as pointed by secgldno and secgldnm)
	set rgld=$random(4)
	; 0: plain vanilla (^x),
	; 1: $zgbldir="other.gld"
	; 2: $zgbldir=""
	; 3: change ^x in str into ^|"other.gld"|x
	set actgld=secgldnm_$random(secgldno)_".gld"
	if 1=rgld set tmpstr="set $ZGBLDIR="""_actgld_"""" write space,tmpstr,! xecute tmpstr
	if 2=rgld set tmpstr="set $ZGBLDIR=""""" write space,tmpstr,! xecute tmpstr
	if 3=rgld do
	.	set up=$find(str,"^")
	.	if 'up quit
	.	set str=$extract(str,1,up-1)_"|"""_actgld_"""|"_$extract(str,up,$length(str))
	.	set up=$find(str,"^",up+1)
	.	if 'up quit
	.	set str=$extract(str,1,up-1)_"|"""_actgld_"""|"_$extract(str,up,$length(str))
	quit
