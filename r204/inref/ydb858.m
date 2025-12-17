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
; This M program
; Gets a hex value offset from the command line
; opens a PIPE device to gdb $gtm_dist/mumps
; uses that pipe device to output the code at the address
; at libyottadb.so+offset
gdbpipefreez;
	; Get offset from ZCMDLINE.
	set offset=$ZCMDLINE
	set dev="gdb"
	; Start gdb.
	open dev:(command="gdb $gtm_dist/mupip":exception="goto done")::"PIPE"
	use dev
	set gdbPrompt="(gdb) "
	do waitForPrompt(gdbPrompt)
	new libydbLine,readLine,mOut,lineIndex
	write "start freeze -on DEFAULT",!
	do waitForPrompt(gdbPrompt)
	write "catch load libyottadb.so",!
	do waitForPrompt(gdbPrompt)
	write "continue",!
	do waitForPrompt(gdbPrompt)
	write "info proc mappings",!
	set libydbLine=""
	set foundPrompt=0
	set lineIndex=1
	do waitForPromptRet(gdbPrompt,.mOut)
	; Finding the base address of "libyottadb.so"
	for  do  QUIT:(foundPrompt=1)!(mOut<lineIndex)
	 . set readLine=mOut(lineIndex)
	 . if readLine["libyottadb.so" DO
	 . . set libydbLine=readLine
	 . . set foundPrompt=1 ;We only want the first libyottadb.so line
	 . set lineIndex=lineIndex+1
	; Extract the base address from the line that contains it.
	; libydbLine should be in this format.
	;          Start Addr           End Addr       Size     Offset  Perms  objfile
	;       0xfffff6e10000     0xfffff79f4000   0xbe4000        0x0  r-xp   /usr/library/V985_R203BEN/dbg/libyottadb.so
	new I,nextIndex,readyToQuit,currChar
	set readyToQuit=0
	for I=1:1:25 DO  QUIT:readyToQuit=1
	 . set currChar=$EXTRACT(libydbLine,I)
	 . if '((currChar=$CHAR(11))!(currChar=$CHAR(32))) DO
	 . . for nextIndex=1:1:35 DO  QUIT:(currChar=$CHAR(11))!(currChar=$CHAR(32))
	 . . . set currChar=$EXTRACT(libydbLine,nextIndex+I)
	 . . set nextIndex=nextIndex-1
	 . . set base=$EXTRACT(libydbLine,I,I+nextIndex)
	 . . set readyToQuit=1
	;
	set nextCMD="list *"_base_"+"_offset
	; Make gdb output the code around base+offset.
	write "set listsize 20",!
	do waitForPrompt(gdbPrompt)
	write nextCMD,!
	; save the code gdb generated in toRet.
	new gdbline,toRet,numfail,startLine,linesAdded,started,fullOutbackup,readLine,foundPrompt,gdbOut,outputIndex
	set numfail=0
	set toRet=""
	set linesAdded=0
	set started=0
	set outputIndex=1
	set fullOutbackup=""
	set gdbline=""
	set startLine="this comment and the next 2 lines after this comment are checked in the test"
	set foundPrompt=0
	do waitForPromptRet(gdbPrompt,.gdbOut)
	for  do  QUIT:(linesAdded>4)!(gdbOut<outputIndex)
	 . set gdbline=gdbOut(outputIndex)
	 . set fullOutbackup=fullOutbackup_gdbline_$CHAR(10)
	 . if started=1 DO
	 . . set toRet=toRet_$CHAR(10)_gdbline ;If not the first line, add newline (char 10)
	 . . set linesAdded=linesAdded+1
	 . if gdbline[startLine DO   ; We only want startLine through startLine+5 of the full gdb output.
	 . . set started=1
	 . . set toRet=toRet_gdbline ; Do not add newline before the first line
	 . . set linesAdded=linesAdded+1
	 . set outputIndex=outputIndex+1
	; Print the code gdb generated.
	use $principal
	if toRet="" DO
	 . w "target code not found, dumping full output below",!
	 . w fullOutbackup,!
	write toRet,!
	use dev
	close dev
	quit
waitForPrompt(prompt);
	; Reads and discards all input until it gets to the prompt.
	new readSoFar
	set readSoFar=""
	for  read cmdop:0.01 do  quit:readSoFar=prompt
	.	; If $TEST is 1, it means the read did not time out. That means we read a full newline terminated line.
	.	; So keep reading in that case after noting down what was read (in case we need to display it later).
	.	; If $TEST is 0, it means the read timed out. In that case, accumulate whatever was read so far with
	.	; whatever was read this iteration and note it in the "readSoFar" variable and move on to the next iteration.
	.	if '$test set readSoFar=readSoFar_cmdop quit
	.	set readSoFar=""
	.	; set readData($incr(readData))=cmdop
	; set readData($incr(readData))=readSoFar
	; use $principal zwrite readData use dev
	quit
waitForPromptRet(prompt,readData);
	; Like waitForPrompt but the lines are saved in a list
	; in the readData variable that is expected to be passed
	; in by reference. readData will be the number of elements
	; in read data, the elements will be indexed in the order read
	; starting with index 1.
	new readSoFar
	set readSoFar=""
	for  read cmdop:0.01 do  quit:readSoFar=prompt
	.	; If $TEST is 1, it means the read did not time out. That means we read a full newline terminated line.
	.	; So keep reading in that case after noting down what was read (in case we need to display it later).
	.	; If $TEST is 0, it means the read timed out. In that case, accumulate whatever was read so far with
	.	; whatever was read this iteration and note it in the "readSoFar" variable and move on to the next iteration.
	.	if '$test set readSoFar=readSoFar_cmdop quit
	.	set readSoFar=""
	.	set readData($incr(readData))=cmdop
	set readData($incr(readData))=readSoFar
	; use $principal zwrite readData use dev
	quit
