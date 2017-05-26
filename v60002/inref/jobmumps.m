;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jobmumps;
	; Job process ID is not appended to the output file.
	Set pwd=$ZTRNLNM("PWD")
	view "JOBPID":0
	;
	; case 1: No parameters to job command.
	;
	set cmd="hworld"
	do ^jnoview(cmd)
	zsystem "mv *.mjo *.mje case1/"
	;
	; case 2: Pass input,output,error and default directory to job command
	;
	Set def=pwd_"/case2/"
	set procparam="INPUT=""input.mji"":OUTPUT=""output.mjo"":ERROR=""error.mje"":"
	set procparam1=procparam_"DEFAULT="""_def_""""
	Set cmd="hworld:("_procparam1_")"
	do ^jnoview(cmd)
	view "JOBPID":1
	;
	; case 3: Job-off process and in different default directory with jobpid appended.
	;
	set def=pwd_"/case3/"
	set procparam1=procparam_"DEFAULT="""_def_""""
	Set cmd="hworld:("_procparam1_")"
	do ^jnoview(cmd)
	;
	; case 4: Job-off process with parameter to routine entrypoint and with timeout
	;
	set def=$ZTRNLNM("PWD");
	set def=pwd_"/case4/"
	set procparam1=procparam_"DEFAULT="""_def_""""
	set cmd="timehworld(needed,timeout):("_procparam1_")";
	;
	;	Randomly decide if timeout is required.
	;		if yes,
	;			randomly decide value of the timeout. timeout value is
	;			ranges from 0 to 10 seconds
	;		if not,
	;			set the timeout for -1
	;
	set needed=$random(2)
	if needed=1 do
	. set timeout=$random(10)
	else  set timeout=-1
	do jnoview1^jnoview(cmd,needed)
	Quit
