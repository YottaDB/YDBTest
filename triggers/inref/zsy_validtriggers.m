;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validtriggers
	; This M routine takes a trigger file, for example
	; triggers/inref_u/validtriggers.trg, and attempts to load and
	; unload triggers in a random fashion.
	;
	; This version of validtriggers.m has "zsy_" in its name because
	; it uses zsystem calls to mupip  to load individual triggers
	set tf=$piece($ZCMDLINE," ",1)
	set trigger="$MUPIP trigger -triggerfile="
	open tf:readonly
	use tf:exception="goto EOF"
	set file="",lc=0
	use tf for  Read line set file=file_line_$char(10),lc=lc+1
EOF	if '$ZEOF use $p zmessage +$ZStatus
	close tf
	; Begin random trials
	for trial=1:1:20 do
	. use $p write !!,"Test # ",trial,!
	. set testfile="testfile"_trial_".trg"
	. open testfile:TRUNCATE
	. use testfile
	. set cmd=$random(3),op=$select(0=cmd:"+",1=cmd:"-",1:"")
	. if ""=op write "-*",!
	. use testfile write "; Op is ~",op,"~",!
	. for line=1:1:$random(40)+1 do
	. . set record=$piece(file,$char(10),$random(lc)+1)
	. . if ("-"=op)&("+"=$extract(record,1)) set $extract(record,1)="-"
	. . use testfile write record,!
	. close testfile
	. use $p write trigger_testfile,!
	. set script="script"_trial_".csh"
	. open script:newversion
	. use script
	. write $$load^validtriggers(testfile),!
	. write $$select^validtriggers(trial),!
	. write $$reverse^validtriggers(trial,testfile),!
	. write $$repeat^validtriggers(trial),!
	. write $$select^validtriggers(trial_"b"),!
	. close script
	. zsystem "$tst_tcsh ./script"_trial_".csh"
	Quit
	;
	; load a trigger file
load(testfile)
	quit "$MUPIP trigger -triggerfile="_testfile_" -noprompt"
	;
	; show all installed triggers
select(id)
	quit "$MUPIP trigger -select out"_id_".trg"
	;
	; change all trigger updates to removals and vice versa
reverse(id,tfile)
	new saveio set saveio=$IO
	new ofile set ofile="out"_id_"rem.trg"
	open tfile:readonly
	open ofile:newversion
	for  quit:$zeof  do
	. use tfile read line
	. quit:(line="-*")!(line?1"-".A1"*")
	. set op=$extract(line,1)
	. if op="-" set $extract(line,1)="+"
	. if op="+" set $extract(line,1)="-"
	. use ofile write line,!
	. use tfile
	close tfile close ofile
	use saveio
	quit "$MUPIP trigger -triggerfile="_ofile_" -noprompt"
	;
	; reload the triggers
repeat(id)
	quit "$MUPIP trigger -triggerfile=out"_id_".trg"
