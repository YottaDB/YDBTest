;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Helper script for the gtm7919 test to parse the generated messages from either the terminal or
; syslog, and extract individual arguments.
gtm7919
	new msgFile,tabFile,tab,newline
	new INPUT,OUTPUT,INSYSLOG,MESSAGES

	; Determine whether we are parsing syslog (singleline) or terminal (multiline) messages.
	set INSYSLOG=(101=$ztrnlnm("gtm_white_box_test_case_number"))

	set INPUT=$piece($zcmdline," ",2)
	set OUTPUT=$piece($zcmdline," ",3)

	; Choose the default tab and newline escape sequences.
	set tab=$$getTabChars()
	set newline=$$getNewlineChars()

	; Override the selected tab escape sequence if a file with one was provided.
	set tabFile=$piece($zcmdline," ",4)
	if (""'=tabFile) do
	.	open tabFile:readonly
	.	use tabFile
	.	read tab
	.	close tabFile

	; Get the message information.
	set msgFile=$piece($zcmdline," ",1)
	set msgFile="setMsgInfo^"_msgFile
	do @msgFile@(.MESSAGES,tab,newline)

	open INPUT
	open OUTPUT:newversion

	do:(INSYSLOG) processSyslogMessages
	do:('INSYSLOG) processTermMessages

	close INPUT
	close OUTPUT

	quit

; Parse messages printed to the terminal. Messages could comprise several lines of text.
processTermMessages
	new linesToGo,curMessage,line,quit,multiline,mnemonic,numOfLines,count,index

	set linesToGo=0
	set curMessage=""
	for  use INPUT quit:$zeof  read line do:linesToGo!(""'=$$FUNC^%TRIM(line))
	.	set quit=0,multiline=0
	.
	.	if (linesToGo) do
	.	.	set linesToGo=linesToGo-1
	.	.	if (linesToGo) do
	.	.	.	set curMessage=curMessage_$char(13)_line
	.	.	.	set quit=1
	.	.	else  do
	.	.	.	set line=curMessage_$char(13)_line
	.	.	.	set curMessage=""
	.	.	.	set multiline=1
	.	quit:quit
	.
	.	if ('multiline) do
	.	.	do prepareMessage(.line,.mnemonic,0)
	.	.	set numOfLines=MESSAGES(mnemonic,"lines")
	.	.	set:(1'=numOfLines) linesToGo=numOfLines-1,curMessage=line,quit=1
	.	quit:quit
	.
	.	set count=MESSAGES(mnemonic,"args")
	.	if (count) do
	.	.	set result=$$parseArgs(line,mnemonic,count)
	.	.	do:(result) error("Argument parsing failed.")
	.
	.	do printMessageArgs(mnemonic,count)

	quit

; Parse messages printed to the syslog. All messages consist of only one line.
processSyslogMessages
	new line,mnemonic,count

	for  use INPUT quit:$zeof  read line do:(""'=$$FUNC^%TRIM(line))
	.	do prepareMessage(.line,.mnemonic,1)
	.
	.	set count=MESSAGES(mnemonic,"args")
	.	if (count) do
	.	.	set result=$$parseArgs(line,mnemonic,count)
	.	.	do:(result) error("Argument parsing failed.")
	.
	.	do printMessageArgs(mnemonic,count)

	quit

; Ensure the presence of the key components of the message, and record its mnemonic and text.
prepareMessage(text,mnemonic,syslog)
	new start,end,from,pos

	set start=$find(text,"%")
	do:('start) error("Did not find message facility.")
	set start=$find(text,"-",start)
	do:('start) error("Did not find message severity.")
	set start=$find(text,"-",start)
	do:('start) error("Did not find message mnemonic.")
	set end=$find(text,", ",start)
	do:('end) error("Did not find message text.")

	set mnemonic=$extract(text,start,end-3)
	set text=$extract(text,end,$length(text))

	if (syslog) do
	.	set from=" -- generated from "
	.	set pos=0
	.	for start=$length(text):-1:1 set pos=$find(text,from,start) quit:pos
	.	do:('pos) error("Did not find message 'from' fragment.")
	.	set text=$extract(text,1,start-1)

	quit

; Once a message has been processed, this function can print all the extracted arguments.
printMessageArgs(mnemonic,count)
	new i

	use OUTPUT
	write mnemonic,!
	for i=1:1:count write MESSAGES(mnemonic,"args",i),!
	write !
	quit

; Extract the arguments out of the message text based on the precollected information available through an
; M routine passed in the first command line argument.
parseArgs(message,mnemonic,count)
	new i,originalMessage,lastSearchLine,quit,argLine,searchStart,searchLimit,postChars,endFound
	new endPos,preChars,startFound,startPos

	set originalMessage=message

	set lastSearchLine=-1
	set quit=0
	if (INSYSLOG) do
	.	set searchStart=$length(message)
	.	set searchLimit=searchStart+1

	for i=count:-1:1 do  quit:quit
	.	; For multi-line arguments
	.	if ('INSYSLOG) do
	.	.	set argLine=MESSAGES(mnemonic,"args",i,"line")
	.	.	if (lastSearchLine'=argLine) do
	.	.	.	set lastSearchLine=argLine
	.	.	.	set message=$piece(originalMessage,$char(13),argLine)
	.	.	.	set searchStart=$length(message)
	.	.	.	set searchLimit=searchStart+1
	.
	.	set postChars=MESSAGES(mnemonic,"args",i,"postChars")
	.	if ("<END>"=postChars)&(('INSYSLOG)!((INSYSLOG)&(count=i))) set endPos=$length(message)
	.	else  do
	.	.	set endFound=0
	.	.	for searchStart=searchStart:-1:1 do  quit:endFound
	.	.	.	set endPos=$find(message,postChars,searchStart)
	.	.	.	set:(endPos&(endPos<=searchLimit)) endPos=searchStart-1,endFound=1
	.	.	if ('endFound) set quit=1
	.	.	else  set searchLimit=searchStart
	.	quit:quit
	.
	.	set preChars=MESSAGES(mnemonic,"args",i,"preChars")
	.	if ("<START>"=preChars)&(('INSYSLOG)!((INSYSLOG)&(1=i))) set startPos=1
	.	else  do
	.	.	set startFound=0
	.	.	for searchStart=searchStart-$length(preChars)+1:-1:1 do  quit:startFound
	.	.	.	set startPos=$find(message,preChars,searchStart)
	.	.	.	set:(startPos&(startPos<=searchLimit)) startFound=1
	.	.	if ('startFound) set quit=1
	.	.	else  set searchLimit=startPos
	.	quit:quit
	.	set MESSAGES(mnemonic,"args",i)=$extract(message,startPos,endPos)

	quit quit

; Get the default tab escape sequence.
getTabChars()
	quit $char(9)

; Get the default newline escape sequence.
getNewlineChars()
	quit ", "

; Simplistic error handler to fail this test and print a ZSHOW dump.
error(error)
	use $principal
	write error,!
	zshow "*"
	halt
