;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7700	;
	; ----------------------------------------------------------------------------------------------------------------
	; Test that GDE SHOW -COMMANDS works fine in case * namespace is mapped to a non-DEFAULT region OR
	; the DEFAULT region and/or segment is renamed to something else OR local locks is mapped to a non-DEFAULT region.
	; ----------------------------------------------------------------------------------------------------------------
	;
	; Run 8 testcases test1 thru test8.
	; Take all commands from the "common" section below and then take the test specific section (e.g. "test1") below.
	; Use these commands to generate a gde command input file (e.g. test1.gde).
	; Create a gld (e.g. test1.gld) using these commands.
	; Run gde show -commands on this global directory to ensure the output is accurate.
	; Do this for test2, test3, ..., test8
	;
	new quitloop,i,j,line,mcode,unix,file,echostr,gdecmd,piece1,piece2
	set $etrap="zshow ""*""  halt"	; have simple error trap
	set vms=$zver["VMS"
	set $piece(echostr,"-",100)=""
	for i=1:1:8  do
	. write echostr,!
	. write "  --> Running subtest test"_i,!
	. write echostr,!
	. set file="test"_i_".gde"
        . open file:(newversion)
	. use file
	. for module="common","test"_i do
	. . set quitloop=0
	. . for j=1:1  do  quit:quitloop
	. . . set line=module_"+"_j_"^gtm7700"
	. . . set mcode=$text(@line)
	. . . set gdecmd=$piece(mcode,";",2)
	. . . if gdecmd="quit" set quitloop=1 quit
	. . . ; if VMS, transform DEFAULT to $DEFAULT and -xxx to /xxx
	. . . if vms do
	. . . . set gdecmd=$translate(gdecmd,"-","/")
	. . . . if gdecmd["DEFAULT" set $piece(gdecmd,"DEFAULT")=$piece(gdecmd,"DEFAULT")_"$"
	. . . write gdecmd,!
	. close file
	. ;
	. if 'vms do unix(i)
	. if vms  do vms(i)
	quit
unix(i)	;
	new file
	set file="test"_i_".csh"
	open file:(newversion)
	use file
	write "set echo",!
	write "setenv gtmgbldir test"_i_".gld",!
	write "$GDE @test"_i_".gde",!
	write "$GDE show -commands > test_showcmd"_i_".gde",!
	close file
	zsystem "tcsh "_file
	;
	set file="test_showcmd"_i_".csh"
	open file:(newversion)
	use file
	write "set echo",!
	write "setenv gtmgbldir test_showcmd"_i_".gld",!
	write "$GDE @test_showcmd"_i_".gde",!
	close file
	zsystem "tcsh "_file
	;
	set file="test_diff"_i_".csh"
	open file:(newversion)
	use file
	write "set echo",!
	write "diff test"_i_".gld test_showcmd"_i_".gld",!
	close file
	zsystem "tcsh "_file
	quit
vms(i)	;
	new file
	set file="test"_i_".com"
	open file:(newversion)
	use file
	write "$ set verify",!
	write "$ define gtm$gbldir test"_i_".gld",!
	write "$ GDE @test"_i_".gde",!
	write "$ define/user sys$output test_showcmd"_i_".gde",!
	write "$ GDE show /commands",!
	close file
	zsystem "@"_file
	;
	set file="test_showcmd"_i_".com"
	open file:(newversion)
	use file
	write "$ set verify",!
	write "$ define gtm$gbldir test_showcmd"_i_".gld",!
	write "$ GDE @test_showcmd"_i_".gde",!
	close file
	zsystem "@"_file
	;
	set file="test_diff"_i_".csh"
	open file:(newversion)
	use file
	write "$ set verify",!
	write "$ diff test"_i_".gld test_showcmd"_i_".gld",!
	close file
	zsystem "@"_file
	quit
common	;
	;change -segment DEFAULT -file=mumps.dat
	;add -name a -region=areg
	;add -region areg -dyn=aseg
	;add -segment aseg -file=a
	;add -name b -region=breg
	;add -region breg -dyn=bseg
	;add -segment bseg -file=b
	;add -name c -region=creg
	;add -region creg -dyn=cseg
	;add -segment cseg -file=c
	;quit
test1	;
	;change -name * -region=AREG
	;quit
test2	;
	;rename -region DEFAULT REGDFLT
	;quit
test3	;
	;rename -segment DEFAULT SEGDFLT
	;quit
test4	;
	;change -name * -region=AREG
	;rename -region DEFAULT REGDFLT
	;quit
test5	;
	;change -name * -region=AREG
	;rename -segment DEFAULT SEGDFLT
	;quit
test6	;
	;rename -region DEFAULT REGDFLT
	;rename -segment DEFAULT SEGDFLT
	;quit
test7	;
	;change -name * -region=AREG
	;rename -region DEFAULT REGDFLT
	;rename -segment DEFAULT SEGDFLT
	;quit
test8	;
	;change -name * -region=AREG
	;locks  -region=CREG
	;delete -region DEFAULT
	;delete -segment DEFAULT
	;quit
