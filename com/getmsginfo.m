;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parses error messages defined in one or more GT.M *.msg files and creates a 'messages.m' file that can be sourced ;
; by an M program to obtain information required to process messages out of an actual log.                          ;
;                                                                                                                   ;
; To parse all GT.M messages, do                                                                                    ;
;                                                                                                                   ;
;   mumps -run getmsginfo  <outfile>.m                 \                                                            ;
;                          $sr_port/cmerrors.msg       \                                                            ;
;                          $sr_port/gdeerrors.msg      \                                                            ;
;                          $sr_port/merrors.msg        \                                                            ;
;                          $sr_unix_gnp/cmierrors.msg  \                                                            ;
;                          $sr_unix/gtmsecshr_wrapper.c                                                             ;
;                                                                                                                   ;
; The resultant file, <outfile>.m, contains an only label, 'setMsgInfo', which can be invoked via a DO command on   ;
; setMsgInfo^<messages>. The caller needs to specify the variable where the message information is to be stored,    ;
; and substitutions for tab and newline characters (in case it expects that those will be escaped in some fashion). ;
;                                                                                                                   ;
; NOTE: The generation of message information for gtmsecshr_wrapper.c will only work starting V6.2-000.             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getmsginfo
	new INSYSLOG,INTEST,SEVERE,MSGCNTL,MSGNBIT,MSGFAC,out,tempOut,filenum,border,X,file,line,count,piece

	; The white-box test scenario #101 means that ZMESSAGEs are printed to the syslog. We care because syslog daemons
	; escape newline characters, thus rendering all multiline messages on a single line. In the terminal, though, we
	; can expect one message entity to take several lines.
	set INSYSLOG=(101=$ztrnlnm("gtm_white_box_test_case_number"))

	; Detect if we are executed within a GT.M test (assuming InfoHub otherwise) to either preserve or filter out all
	; messages of type UNUSEDMSG... because those should never be found in the syslog of a real GT.M application.
	set INTEST=(101=$ztrnlnm("tst_working_dir"))

	set $ecode="",$etrap="set x=$zjobexam() zhalt 1"
	; Prepare a mapping for warning levels.
	set SEVERE("warning")=0
	set SEVERE("success")=1
	set SEVERE("error")=2
	set SEVERE("info")=3
	set SEVERE("fatal")=4
	set SEVERE("severe")=4

	; Set the numeric bases for different bytes comprising a message ID.
	set MSGCNTL=134217728	; 2**27
	set MSGNBIT=32768	; 2**15
	set MSGFAC=65536	; 2**16

	; Open the output file and write the label name.
	set out=$piece($zcmdline," ",$increment(filenum))
	set tempOut=out_"."_$horolog
	open out:newversion
	open tempOut
	use tempOut

	; Print the copyright header; use ?<value> because tab characters generate LITNONGRAPH errors.
	set border=";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",X=$length(border)-1
	write border,!
	write ";",?X,";",!
	write ";",?8,"Copyright ",$zdate($horolog,"YYYY")," Fidelity Information Services, Inc",?X,";",!
	write ";",?X,";",!
	write ";",?8,"This source code contains the intellectual property",?X,";",!
	write ";",?8,"of its copyright holder(s), and is made available",?X,";",!
	write ";",?8,"under a license.  If you do not know the terms of",?X,";",!
	write ";",?8,"the license, please stop and do not read further.",?X,";",!
	write ";",?X,";",!
	write border,!

	; To allow storing message information in the user-specified variable, make it a parameter to the function.
	write "setMsgInfo(messages,tab,newline)",!

	; Go through all files supplied in command line arguments and generate message information for each.
	for  set file=$piece($zcmdline," ",$increment(filenum))  quit:file=""  do parseMsgs(file,tempOut)

	; Print the quit line, close the output file, and quit.
	use tempOut
	write $char(9)_"quit"
	close tempOut

	; Reopen the temporary file to process tabs and newlines.
	open tempOut:readonly
	for  use tempOut quit:$zeof  read line do
	.	set count=$length(line,"<TAB>")
	.	set piece=$piece(line,"<TAB>",1)
	.	for i=2:1:count set piece=piece_"""_tab_"""_$piece(line,"<TAB>",i)
	.	set line=piece
	.
	.	set count=$length(line,"<NEWLINE>")
	.	set piece=$piece(line,"<NEWLINE>",1)
	.	for i=2:1:count set piece=piece_"""_newline_"""_$piece(line,"<NEWLINE>",i)
	.	set line=piece
	.
	.	use out
	.	write line,!

	; Close both open files.
	close out
	close tempOut

	; Remove the temporary file.
	zsystem "rm "_tempOut

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parse messages out of the specified file and print the extracted information in the output file.                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
parseMsgs(file,out)
	new index,line,info,facility,base,msg,mnemonic,text,i,firstChar,infoPos,severity,id,argCount

	; Open the specified file.
	open file:readonly
	use file

	; Obtain the facility and base message ID.
	for  read line set line=$zconvert(line,"U") quit:$zeof  quit:line[".FACILITY"
	set info=$piece(line,$char(9),3)
	set facility=$piece(info,",",1)
	set base=MSGCNTL+MSGNBIT+(+$piece($translate(info," "),",",2)*MSGFAC)

	; Go through all remaining lines that begin with a capital letter.
	for  use file quit:$zeof  read msg quit:msg[".end"  do:$extract(msg,1)?1u
	.	; The below logic expects to find a message in one of the following formats:
	.	;   MNEMONIC <error message text>/severity/fao=###!/ansi=### ! comment
	.	; or
	.	;   MNEMONIC "error message text"/severity/fao=###!/ansi=### ! comment
	.
	.	; Update the message index.
	.	if $increment(index)
	.
	.	; Since certain messages use tab explicitly (as opposed to '!_'), we cannot convert all tabs to spaces
	.	; to simplify parsing. So, try both spaces and tabs when extracting the mnemonic and the actual message.
	.	for i=1:1 quit:$char(9,32)[$extract(msg,i)
	.	set mnemonic=$extract(msg,1,i-1)
	.	quit:(""=mnemonic)
	.
	.	; When invoked for InfoHub, we want to filter out all unused messages.
	.	quit:('INTEST)&(mnemonic["UNUSEDMSG")
	.
	.	; Continue parsing the rest of the message definition.
	.	for i=i:1 quit:((" "'=$extract(msg,i))&($char(9)'=$extract(msg,i)))
	.	set text=$extract(msg,i,$length(msg))
	.	set firstChar=$extract(text)
	.	if (firstChar="<") set text=$piece($piece(text,"<",2),">",1)
	.	if (firstChar'="<") set text=$piece(text,"""",2)
	.
	.	; Obtain the severity.
	.	set infoPos=$find(msg,text)
	.	set severity=$translate($piece($extract(msg,infoPos,$length(msg)),"/",2)," ")
	.
	.	; Calculate the ID.
	.	set id=base+(8*index)+SEVERE(severity)
	.
	.	; Get number or message arguments, recording related information as well.
	.	set argCount=$$getMsgArgCount(text,mnemonic)
	.
	.	; To generate properly escaped strings, we use the zwrite function, for which we first need to
	.	; initialize variables containing those strings.
	.	set messages(mnemonic)=msg
	.	set messages(mnemonic,"facility")=facility
	.	set messages(mnemonic,"severity")=severity
	.	set messages(mnemonic,"id")=id
	.	set messages(mnemonic,"text")=text
	.	set messages(mnemonic,"args")=argCount
	.
	.	; Finally print the stuff out.
	.	use out
	.	write $char(9)_"set "
	.	zwrite messages(mnemonic)
	.	write $char(9)_"set "
	.	zwrite messages(mnemonic,"facility")
	.	write $char(9)_"set "
	.	zwrite messages(mnemonic,"severity")
	.	write $char(9)_"set "
	.	zwrite messages(mnemonic,"id")
	.	write $char(9)_"set "
	.	zwrite messages(mnemonic,"text")
	.	write $char(9)_"set "
	.	zwrite messages(mnemonic,"args")
	.	if ('INSYSLOG) write $char(9)_"set " zwrite messages(mnemonic,"lines")
	.	for i=1:1:argCount do
	.	.	write $char(9)_"set "
	.	.	zwrite messages(mnemonic,"args",i,"type")
	.	.	write $char(9)_"set "
	.	.	zwrite messages(mnemonic,"args",i,"preChars")
	.	.	write $char(9)_"set "
	.	.	zwrite messages(mnemonic,"args",i,"postChars")
	.	.	if ('INSYSLOG) write $char(9)_"set " zwrite messages(mnemonic,"args",i,"line")
	.	write !
	.	use file

	close file

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Process the message arguments and return their total count. Works for both single- and multiline messages. The    ;
; resultant structure is of form                                                                                    ;
;                                                                                                                   ;
;   messages(<mnemonic>)				Full message text, including all argument type directives.  ;
;   messages(<mnemonic>,"facility")			Facility issuing the message, such as GTM or GDE.           ;
;   messages(<mnemonic>,"severity")			Default everity of the message, such as 'info' or 'fatal'.  ;
;   messages(<mnemonic>,"id")				Numeric ID of the message given the default severity.       ;
;   messages(<mnemonic>,"text")				Textual part of the message.                                ;
;   messages(<mnemonic>,"args")				Number of arguments.                                        ;
;   messages(<mnemonic>,"args",<idx>,"type")		Type of the idx-th argument, such as 'AD' or 'UL'.          ;
;   messages(<mnemonic>,"args",<idx>,"preChars")	Characters preceding the idx-th argument.                   ;
;   messages(<mnemonic>,"args",<idx>,"postChars")	Characters following the idx-th argument.                   ;
;                                                                                                                   ;
; where <mnemonic> is the mnemonic of the message ("DBFILEXT," etc.), and <idx> is the index of the                 ;
; message argument. Note that special strings "<START>" and "<END>" are used for "preChars" and "postChars"         ;
; expressions to indicate that the search boundaries are confined by either the beginning or end of the line.       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMsgArgCount(msg,mnemonic)
	new i,count,piece,length,preChars,postChars,postCharsFlushed,char,msgLength,line

	; First, make sure that there are no explicit tabs in the text.
	set count=$length(msg,$char(9))
	set piece=$piece(msg,$char(9),1)
	for i=2:1:count set piece=piece_"!_"_$piece(msg,$char(9),i)
	set msg=piece

	; Commence the processing.
	set count=0,length=$length(msg)
	set preChars="<START>",postChars="",postCharsFlushed=0
	set line=1
	for i=1:1:length do
	.	; Extract the first character of the remaining string.
	.	set char=$extract(msg,i)
	.
	.	if ("!"=char) do
	.	.	; See if '!' is for an argument or one of special escape sequences.
	.	.	set msgLength=$$getMsgArgLength(msg,i+1,length,.type)
	.	.	if (msgLength) do
	.	.	.	; If we have come across an argument, record the collected information, update the counts,
	.	.	.	; and reset state variables.
	.	.	.	set i=i+msgLength
	.	.	.	set count=count+1
	.	.	.	set messages(mnemonic,"args",count,"type")=type
	.	.	.	set:('INSYSLOG) messages(mnemonic,"args",count,"line")=line
	.	.	.	set messages(mnemonic,"args",count,"preChars")=preChars
	.	.	.	set:(1<count) messages(mnemonic,"args",count-1,"postChars")=postChars
	.	.	.	set (preChars,postChars)=""
	.	.	.	set postCharsFlushed=0
	.	.	else  do
	.	.	.	; If this is a special escape sequence, make sure it is one of the valid ones; otherwise, skip.
	.	.	.	if ("!"=$extract(msg,i+1)) set char="!",i=i+1							; !! = !
	.	.	.	else  if ("_"=$extract(msg,i+1)) set char="<TAB>",i=i+1						; !_ = <tab>
	.	.	.	else  if ("/"=$extract(msg,i+1)) do:('INSYSLOG)  set:(INSYSLOG) char="<NEWLINE>" set i=i+1	; !/ = <newline>
	.	.	.	.	set line=line+1
	.	.	.	.	set char="<START>"
	.	.	.	.	set postCharsFlushed=1
	.	.	.	.	set preChars="<START>"
	.	.	.	.	set:(""=postChars) postChars="<END>"
	.
	.	; If the current character was a non-argument, keep updating the state variables.
	.	if (("!"'=char)!(msgLength=0)) do
	.	.	set preChars=$select(preChars="<START>":char,preChars'="<START>":preChars_char)
	.	.	set:('postCharsFlushed) postChars=postChars_char

	; Update the info for the last argument in case there was at least one.
	set:(0<count) messages(mnemonic,"args",count,"postChars")=$select(postChars="":"<END>",postChars'="":postChars)
	set:('INSYSLOG) messages(mnemonic,"lines")=line

	; Return the number of arguments discovered.
	quit count

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check whether we have an argument encoding starting at the specified position, and if so, fill in the details     ;
; about the argument and return the length of the placeholder. If no valid argument encoding is found, return 0.    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMsgArgLength(msg,startPos,length,type)
	new pos,return,nextChar

	set type=""

	; Checking for !n... format.
	quit:(startPos>length) 0
	for pos=startPos:1:length set nextChar=$extract(msg,pos) quit:('$$isDigit(nextChar))  set type=type_nextChar
	set:(pos'=startPos) type="n"_type

	; Checking for !n*c format.
	if ((pos'=startPos)&("*"=$extract(msg,pos))) do
	.	set pos=pos+1
	.	if (pos>length) set return=0 quit
	.	set type=type_"*c"
	.	set return=pos-startPos+1
	quit:$data(return) return

	; Checking for ![n]@... format.
	if ("@"=$extract(msg,pos)) do
	.	set pos=pos+1
	.	if (pos>length) set return=0 quit
	.
	.	; Checking the following character.
	.	set nextChar=$extract(msg,pos)
	.	if (("U"'=nextChar)&("X"'=nextChar)&("Z"'=nextChar)) set return=0 quit
	.	set pos=pos+1
	.	if (pos>length) set return=0 quit
	.	set type=type_"@"_nextChar
	.
	.	; Checking the following character.
	.	set nextChar=$extract(msg,pos)
	.	if (("J"'=nextChar)&("Q"'=nextChar)) set return=0 quit
	.	set type=type_nextChar
	.	set return=pos-startPos+1
	quit:$data(return) return

	set nextChar=$extract(msg,pos)

	; Checking for ![n]A... format.
	if ("A"=nextChar) do
	.	set pos=pos+1
	.	if (pos>length) set return=0 quit
	.	set type=type_"A"
	.
	.	; Checking the following character.
	.	set nextChar=$extract(msg,pos)
	.	if (("C"'=nextChar)&("D"'=nextChar)&("F"'=nextChar)&("S"'=nextChar)&("Z"'=nextChar)) set return=0 quit
	.	set type=type_nextChar
	.	set return=pos-startPos+1
	quit:$data(return) return

	; Checking for ![n]S..., ![n]U..., or ![n]Z... format.
	if (("S"=nextChar)!("U"=nextChar)!("Z"=nextChar)) do
	.	set pos=pos+1
	.	if (pos>length) set return=0 quit
	.	set type=type_nextChar
	.
	.	; Checking the following character.
	.	set nextChar=$extract(msg,pos)
	.	if (("B"'=nextChar)&("W"'=nextChar)&("L"'=nextChar)&("J"'=nextChar)&("Q"'=nextChar)) set return=0 quit
	.	set type=type_nextChar
	.	set return=pos-startPos+1
	quit:$data(return) return

	; Checking for ![n]X... format.
	if ("X"=nextChar) do
	.	set pos=pos+1
	.	if (pos>length) set return=0 quit
	.	set type=type_"X"
	.
	.	; Checking the following character.
	.	set nextChar=$extract(msg,pos)
	.	if (("B"'=nextChar)&("W"'=nextChar)&("L"'=nextChar)&("J"'=nextChar)) set return=0 quit
	.	set type=type_nextChar
	.	set return=pos-startPos+1
	quit:$data(return) return

	quit 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns 1 if the passed variable is a digit, and 0 otherwise.                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isDigit(d)
	; New used variables (except arguments) for scope separation.
	new asc

	set asc=$ascii(d)
	quit ((asc>=48)&(asc<=57))
