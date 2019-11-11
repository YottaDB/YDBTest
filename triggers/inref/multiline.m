;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
multiline
	new triggerfiles
	set triggerfiles=""
	do ^echoline
	do gentrigfiles(.triggerfiles)
	zkill triggerfiles
	do loadtrigfiles(.triggerfiles)
	do testoneline
	do validate
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; validate that we can "select" the multiline triggers to a file and
	; reload them.  If there is a reference file mismatch, check the output
	; of mupipresp.out for errors from mupip and check the trigger file
	; multiline_all.trg for any errors
validate
	do ^echoline
	new resp,marker,mupipresp,i
	set resp="",marker=$translate($justify("",41)," ","=")
	set mupipresp="mupipresp.out"
	open mupipresp:newversion
	write "Export and re-import the triggers",!
	do select^dollarztrigger(,"multiline_all.trg")
	do delete^dollarztrigger()
	do mupip^dollarztrigger("multiline_all.trg",.resp)
	use mupipresp
	for i=1:1  quit:'$data(resp(i))  quit:resp(i)=marker  write resp(i),!
	for  quit:'$data(resp(i))  do
	.	use mupipresp write resp(i),!
	.	use $p write resp(i),!
	.	quit:'$data(resp($increment(i)))
	close mupipresp
	do select^dollarztrigger(,"multiline_post.trg")
	do ^echoline
	ztrigger ^multiline
	ztrigger ^oneline
	if $data(^fired) zwrite ^fired
	else  write "FAIL",!
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; test multiline conditions with $ztrigger("item",cmd)
testoneline
	new line,cmd,status,result
	do ^echoline
	write "$gtm_exe/mumps -run testoneline^multiline",!
	set static="+^oneline -command=S,ZTR -name=oneline"
	set file="testoneline.trg.trigout"
	open file:newversion
	for i=1:1:5  do
	.	set line=$text(oneliners+i^multiline)
	.	set status=$select($piece(line,";",2)="FAIL":0,1:1)
	.	set cmd=$piece(line,";",3)
	.	use file
	.	xecute "set result="_cmd_" use $p write $select(status=result:""PASS "",1:""FAIL ""),i,!"
	close file
	do ^echoline
	quit

oneliners
	;PASS;$ztrigger("item",static_i_" -xecute=""set x="_i_" do l^mrtn()"""_$char(10))
	;FAIL;$ztrigger("item",static_i_" -xecute=""set x="_i_" do l^mrtn()"_$char(10,34))
	;FAIL;$ztrigger("item",static_i_" -xecute=""set x="_i_$char(32,10,9)_"do l^mrtn()""")
	;FAIL;$ztrigger("item",static_i_" -xecute="""_$char(10,9)_"set x="_i_" do l^mrtn()""")
	;FAIL;$ztrigger("item",static_i_" -xecute="_$char(60,60,10,9)_"set x="_i_" do l^mrtn()"""_$char(10,62,62,10))
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; this is purely evil test that uses smoketest.m to validate that we
	; can do anything inside a multiline trigger
smoketest
	do ^echoline
	write "Using smoketest.m from manual_tests as a trigger",!
	; need to grab smoketest.m.  when run by hand we won't have gtm_tst set
	set gtmtst=$ztrnlnm("gtm_tst")
	if gtmtst="" set gtmtst="/gtc/staff/gtm_test/current/T990"
	; smoketest.m has a trollback sitting around which breaks the trigger transaction
	new $estack
	set $etrap="do ^incretrap",expect="TRIGTLVLCHNG"
	; input and output files
	set file="smoketest.trg",msource=gtmtst_"/manual_tests/inref/smoketest.m"
	open msource:readonly
	open file:newversion
	use file
	; start writing the trigger(s)
	write "+^smoke -command=K -xecute=""set x=1"" -name=deleteme",!
	write "+^smoke -command=S -xecute=""set x=2"" -name=dontdeleteme",!
	write "+^smoke -command=ZTR -xecute=<<",!
	use msource
	for  read line quit:$zeof  do
	.	use file
	.	if $increment(bytes,$length(line)+1)>1048576  do
	.	.	write ">>",!
	.	.	write "+^smoke -command=ZTR -xecute=<<",!
	.	.	kill bytes
	.	write line,!
	.	use msource
	close msource
	use file write ">>",!
	close file
	; load the trigger
	do file^dollarztrigger("smoketest.trg",1)
	; execute the trigger
	ztrigger ^smoke
	do ^echoline
	write "Ensure that moving large triggers on delete works",!
	set x=$ztrigger("item","-deleteme")
	do select^dollarztrigger(,"smoketest_select.trg")
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; this test trawls through the inline trigger files and loads them
	; the inline trigger files indicate whether or not we expect the trigger
	; load to pass or to not pass.
loadtrigfiles(list)
	new name
	set name=""
	for  set name=$order(list(name)) quit:name=""  do
	.	new resp set resp=""
	.	do ^echoline
	.	write "Validating ",name," expect ",list(name),!
	.	do file^dollarztrigger(name,$select(list(name)="FAIL":0,1:1))
	.	write "$gtm_exe/mupip trigger -trig=",name,!
	.	do check^dollarztrigger(name_".trigout")
	quit

gentrigfiles(list)
	new i,name,expectedresult,line
	for i=1:1 set line=$text(+i)  quit:line=""  do
	.	if $extract(line,1,5)="tfile"  do
	.	.	set name=$piece(line," ; ",1)
	.	.	set name=$extract(name,6,$length(name))_".trg"
	.	.	set expectedresult=$piece(line," ; ",2)
	.	.	set list(name)=expectedresult
	.	.	do text^dollarztrigger("+"_i_"^multiline",name)
	quit

	; this should be structurally valid
tfilevalid ; PASS
	;+^multiline -commands=S,ZTR -name=multiline1 -xecute=<<
	;	write "Please enjoy the experience",!
	;	do ^echoline
	;	set x=$increment(^fired($ZTNAme))
	;	do l^mrtn()
	;	; are comments parsed correctly?
	;	if $increment(i) write "true if",!
	;	if $increment(i) write "true if do",!
	;	if $increment(i) do
	;	. write "true if do space indent",!
	;	.	write "true if do tab indent",!
	;
	;	; how about space lines?
	;	for i=1:1:10 set $piece(out,$char(9),i)="true"_i
	;	write "for ",out,!
	;	kill out
	;	for i=1:1:10  do
	;	.	set $piece(out,$char(9),i)="true"_i*10
	;	write "for do ",out,!
	;	do ^echoline
	;
	;>>
	;+^multiline -commands=S,ZTR -name=multiline2 -xecute=<<
	;	set x=$increment(^fired($ZTNAme))
	;	set $piece(^fired($ZTNAme,x),$c(10),1)="Please enjoy the label hopping experience"
	;label1
	;	do label2
	;	quit
	;
	;label2
	;	do label3(1,2,3,4,5)
	;	quit
	;
	;label3(parm1,parm2,parm3,parm4,parm5)
	;	do label4()
	;	quit
	;
	;label4()
	;	set $piece(^fired($ZTNAme,x),$c(10),2)="I hope you enjoyed the label hopping experience"
	;	quit
	;>>
	;+^multiline -commands=S,ZTR -name=multiline3 -xecute=<<
	;	set x=$increment(^fired($ZTNAme))
	;	set ^fired($ZTNAme,x)="In GT.M triggers, triggers quit you!"
	;	quit
	;>>
	;+^multiline("halt") -commands=S,ZTR -name=multiline4 -xecute=<<
	;	set x=$increment(^fired($ZTNAme))
	;	set ^fired($ZTNAme,x)="In GT.M triggers, triggers halt you!"
	;	write "In GT.M triggers, triggers halt you!",!
	;	halt
	;>>
	;+^CIF(key1=:,1) -name=vIDX0000058i1 -commands=SET -delim=$C(124) -pieces=2 -xecute=<<
	; ; insert/update trigger for index CIF.TYPXNAM (Order by Type and Name)
	; S ikey2=$P($G(^CIF(key1,50)),$C(124),1); TYPE
	; S ikey3=$P($ZTVALUE,$C(124),2); XNAME
	; I ikey2="" S ikey2=$C(254)
	; I ikey3="" S ikey3=$C(254)
	; ; delete old index key
	; S okey2=$P($G(^CIF(key1,50)),$C(124),1); TYPE
	; S okey3=$P($ZTOLDVAL,$C(124),2); XNAME
	; I okey2="" S okey2=$C(254)
	; I okey3="" S okey3=$C(254)
	; K:((okey2'=ikey2)!(okey3'=ikey3)) ^XREF("TYPXNAM",okey2,okey3,key1)
	; S ^XREF("TYPXNAM",ikey2,ikey3,key1)=""
	;>>
	;; previous versions of GT.M would fail to load this trigger with the error
	;; "value larger than max record size" because the math for computing a valid
	;; length was incorrect
	;+^CIF(key1=:,1) -name=vIDX0000058i2 -commands=SET -delim=$C(124) -pieces=2 -xecute=<<
	; ; insert/update trigger for index CIF.TYPXNAM (Order by Type and Name)
	; S ikey2=$P($G(^CIF(key1,50)),$C(124),1); TYPE
	; S ikey3=$P($ZTVALUE,$C(124),2); XNAME
	; I ikey2="" S ikey2=$C(254)
	; I ikey3="" S ikey3=$C(254)
	; ; delete old inde
	;>>
	quit

	; use << without anything else
tfilenomulti ; FAIL
	;+^multiline -commands=S,ZTR -name=nomulti0 -xecute=<<
	quit

	; use << without anything else and run into another trigger
tfilenomultitude ; FAIL
	;+^multiline -commands=S,ZTR -name=nomulti1 -xecute=<<
	;+^multiline -commands=S,ZTR -name=nomulti2 -xecute=<<
	quit

	; try to close the << on the same line
tfilefalsemulti ; FAIL
	;+^multiline -commands=S,ZTR -name=falsemulti1 -xecute=<<>>
	;+^multiline -commands=S,ZTR -name=falsemulti2 -xecute=<< >>
	quit

tfilequotes ; FAIL
	;+^multiline -commands=S,ZTR -name=quotes -xecute=<<"do l^mrtn()"
	;+^multiline -commands=S,ZTR -name=quotes2 -xecute=<<"
	;	do ^echoline
	;	do l^mrtn()
	;	do ^echoline
	;">>
	;+^multiline -commands=S,ZTR -name=quotes3 -xecute="<<
	;	do ^echoline
	;	do l^mrtn() set x="quotes3"
	;	do ^echoline
	;>>"
	quit

tfilestrayclose ; FAIL
	;+^multiline -commands=S,ZTR -name=strayclose -xecute="do l^mrtn()"
	;>>
	;+^multiline -commands=S,ZTR -name=strayclose2 -xecute=<<
	;	do l^mrtn() set x="strayclose2"
	;>>
	;>>
	quit

	; place a stray << on the trigger line
tfilestrayopen ; FAIL
	;+^multiline -commands=S,ZTR -name=strayopen -xecute="do l^mrtn()" <<
	;>>
	;+^multiline -commands=S,ZTR -name=strayopen2 -xecute=<<
	;	do l^mrtn() set x="strayopen2"
	;<<
	;>>
	quit

	; place spaces after the << marker
tfiletrailingspaces ; PASS
	;+^multiline -commands=S,ZTR -name=spaceafteropen -xecute=<<
	;	set x=$increment(^fired($ZTNAme))
	;	set ^fired($ZTNAme,x)="Sorry, I'm spacey after the <<"
	;>>
	quit

tfileleadingspaces ; FAIL
	;+^multiline -commands=S,ZTR -name=spacebeforopen -xecute=   <<
	;	write "Sorry, I'm spacey before the <<",!
	;>>
	;+^multiline -commands=S,ZTR -name=spacedopen -xecute=   <<
	;	write "Sorry, I'm spacey before and after the <<",!
	;>>
	quit


tfilecmdpos ; PASS
	;+^multiline -name=cmdpos -xecute=<< -commands=S,ZTR
	;	set x=$increment(^fired($ZTNAme))
	;>>
	quit

tfilegarbageafterclose ; FAIL
	;+^multiline -commands=S,ZTR -name=garbageafterclose -xecute=<<
	;	do l^mrtn() set x="garbageafterclose"
	;	set x="garbageafterclose"
	;>> -bad="this is bad"
	quit

tfilecmdafterclose ; FAIL
	;+^multiline -xecute=<<
	;	do l^mrtn()
	;	set x="cmdafterclose"
	;>> -commands=S,ZTR -name=cmdafterclose
	quit

tfilexecutegalore ; PASS
	;+^multiline -commands=S,ZTR -name=xecutegalore -xecute="do ^echoline" -xecute=<<
	;	set x=$increment(^fired($ZTNAme))
	;	set ^fired($ZTNAme,x)="xecutegalore"
	;>>
	quit

	; putting an error somewhere else other than the xecute string to confuse
	; the parser while it is reading the rest of the multi line xecute
tfileerrorsgalore ; FAIL
	;+^multiline -commands=K,ZTK -name=errorsgalore1 -xecute=<<
	;	do l^mrtn()
	;	set x="errorsgalore1"
	;>>
	;+^multiline -commands=S, -name=errorsgalore2 -xecute=<<
	;	do l^mrtn()
	;	set x="errorsgalore2"
	;>>
	;+^multiline -commands=S, -name=errorsgalore3 -xecute="do ^echoline" -xecute=<<
	;
	;	do l^mrtn()
	;
	;	set x="errorsgalore3"
	;>>
	;+^multiline -commands=S, -name=errorsgalore4 -xecute=<<
	;	do l^mrtn() set x="errorsgalore4"
	;>>
	quit
