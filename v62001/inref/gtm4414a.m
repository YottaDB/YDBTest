;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm4414a
	set l="A"_$tr($j(" ",1024*1024-6)," ","X")_"B" ; l="A..B" 1MB
	set l("A"_$tr($j(" ",1024*1024-9)," ","X")_"B")=1 ; l("A..B")=1 1MB
	set *a("A"_$tr($j(" ",1024*1024-10)," ","X")_"B")=l ; *a("A..B")=l 1MB
	set local("")=20.1
	set outofscopebuddy="foo"
	set loccount=$random(512)+1
	set killedalias="I"
	set killedalias(1)="see"
	set killedalias(1,2)="dead"
	set killedalias(1,2,"x")="aliases"
	write "# Generating "_loccount_" locals.",!
	for lc=1:1:loccount do
	.   ; 8192 is the indirection limit
	.   for  set randloc=$$genrand() quit:$length(randloc)<=8191
	.   set @randloc
	; Alias containers
	set *container(1)=local ; container with in-scope alias
	set *container(2)=nonexist ; container with no in-scope alias
	set *container(3)=killedalias ; container with a killed alias (GTM-8465)
	kill *killedalias
	do setalias(.passbyrefalias) ; pseudo alias created by pass-by-reference
	; alias created by tstart is being passed correctly
	; we aren't following wholesome (ACID) TP practice here in order to test the behavior of passing a restart lvn
	set restartvar="before"
	tstart (restartvar)
	set restartvar="after"
	set file="localsintp.out"
	do zwrtofile
	job tstartjob:(output="tstartjob.mjo":error="tstartjob.mje":passcurlvn)
	trollback
	write:restartvar'="after" "TEST-E-FAIL restartvar was modified by testart: "_restartvar,!
	do ^waitforproctodie($zjob)
	; More aliases
	set *inscopealias=outofscopebuddy ; alias with no in other in-scope "buddy"
	new outofscopebuddy
	write "# Saving the locals to parentlocals.out",!
	set file="parentlocals.out"
	do zwrtofile
	write "# Passing the locals to the child",!
	job child:(output="childlocals.mjo":passcurlvn)
	write "# Waiting for the child to finish writing and quit",!
	do ^waitforproctodie($zjob)
	quit
child
tstartjob
passbyrefjob
	zwrite
	quit
genrand()
	new key,value,i
	set key=$char(65+$random(26)) ; Make sure the first character is a letter
	set key=key_$$^%RANDSTR($random(32)+1)
	set substrcount=$random(32)
	if substrcount'=0 do
	.  set key=key_"("
	.  for i=1:1:substrcount-1 set key=key_""""_$$^%RANDSTR($random(2048))_""","
	.  set key=key_""""_$$^%RANDSTR($random(2048))_""")"
	set value=$$^%RANDSTR($random(2048))
	quit key_"="""_value_""""

setalias(aliasvar)
	set aliasvar="bar"
	set file="localsinpassbyref.out"
	do zwrtofile
	job passbyrefjob:(output="passbyrefjobjob.mjo":error="passbyrefjob.mje":passcurlvn)
	do ^waitforproctodie($zjob)
	quit

zwrtofile
	open file:newversion
	use file
	zwrite
	close file
	quit