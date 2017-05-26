validtriggers
	; This M routine takes a trigger file, for example
	; triggers/inref_u/validtriggers.trg, and attempts to load and
	; unload triggers in a random fashion.
	;
	; This version of validtriggers.m has "do_" in its name because
	; its trigger loading routine are called via DOs which use 
	; $ZTrigger to load individual triggers
	Set tf=$piece($ZCMDLINE," ",1)
	; read the passed in file name until EOF
	Open tf:readonly
	Use tf:exception="goto EOF"
	Set file="",lc=0
	Use tf For  Read line Set file=file_line_$char(10),lc=lc+1
EOF	If '$ZEOF use $p zmessage +$ZStatus
	Close tf
	; Begin random trials
	For trial=1:1:20 Do
	. Use $p Write !!,"Test # ",trial,!
	. Set testfile="testfile"_trial_".trg"
	. Open testfile:TRUNCATE
	. Use testfile
	. Set cmd=$random(3),op=$select(0=cmd:"+",1=cmd:"-",1:"")
	. If ""=op Write "-*",!
	. Use testfile Write "; Op is ~",op,"~",!
	. For line=1:1:$random(40)+1 Do
	. . Set record=$piece(file,$char(10),$random(lc)+1)
	. . If ("-"=op)&("+"=$extract(record,1)) Set $extract(record,1)="-"
	. . Use testfile Write record,!
	. Close testfile
	. Use $p Write "$ZTrigger(",testfile,")",!
	. do load^validtriggers(testfile)
	. do select^validtriggers(trial)
	. do reverse^validtriggers(trial)
	. do repeat^validtriggers(trial)
	. do select^validtriggers(trial_"b")
	. zsy $$diffem^validtriggers(trial)
	Quit
	;
	; load a trigger file
load(testfile)
	if '$ZTrigger("FILE",testfile) write "Error loading triggers from ",testfile,!
	quit
	;
	; show all installed triggers
select(id)
	new tfile set tfile="out"_id_".trg"
	open tfile:newversion use tfile
	if '$ZTrigger("SELECT") use $p write "Error writing triggers to ",tfile,!
	close tfile
	quit
	;
	; change all trigger updates to removals and vice versa
reverse(id)
	new tfile set tfile="out"_id_".trg"
	new ofile set ofile="out"_id_"r.trg"
	open tfile:readonly
	open ofile:newversion
	for  q:$zeof  do
	. use tfile read line
	. set op=$extract(line,1)
	. if op="-" set $extract(line,1)="+"
	. if op="+" set $extract(line,1)="-"
	. use ofile write line
	. use tfile
	close tfile close ofile use $p
	if '$ZTrigger("FILE",ofile) write "Error removing triggers from ",tfile,!
	quit
	;
	; reload the triggers
repeat(id)
	new tfile set tfile="out"_id_".trg"
	if '$ZTrigger("FILE",tfile) write "Error reloading triggers from ",tfile,!
	quit
	;
	; diff the output of the separate trigger selects
diffem(id)
	quit "diff out"_id_".trg out"_id_"b.trg >> bogusparsing.out"
