;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Note - this routine contains code from FIS GT.M test code so is a derivative work
;        (specifically the code to eliminate adjacent whitespace characters).

	write "Illegal entry into this routine - invoke a specific entry point instead",!
	zhalt 1

;
; Routine to make sure at least two processes are accessing our database to increase the header
; file var max_procs.cnt as well as setting max_procs.time to the current time.
;
setconcproc
	set ^here=1		; Open DB for our process
	zsystem "$gtm_dist/mumps -run ^%XCMD 'set ^there=1'"	; Bump concurrent access count to 2
	quit

;
; Routine that runs in parallel with setconcproc so we can bump the max concurrent connections field/time.
;
there
	set ^there=1
	quit

;
; Routine to take two DSE DUMP -F output files, read them, find the lines with the values we are interested
; in (listed in fieldDesc() array below), and extract/compare the values to make sure they were upgraded
; correctly.
;
verifyDumps
	set fieldDesc(1)="Max conc proc time"
	set fieldDesc(2)="Max Concurrent processes"
	set fieldDesc(3)="Reorg Sleep Nanoseconds"
	for i=1:1:3 set fieldNum(fieldDesc(i))=i	; Create cross reference indexed by description
	set oldfile=$zpiece($zcmdline," ",1)
	set curfile=$zpiece($zcmdline," ",2)
	do readAndParseFile(oldfile,.oldFields,0)
	do readAndParseFile(curfile,.curFields,1)
	;
	; The oldfields and curfields arrays should hold the values of our 3 fields - compare them
	;
	set error=0
	for i=1:1:3 do
	. set indxDesc=fieldDesc(i)
	. write "Field Description: ",indxDesc
	. if oldFields(indxDesc)'=curFields(indxDesc) do
	. . write "Expected value: ",oldFields(indxDesc),"   Actual value: ",curFields(indxDesc),!
	. . set error=error+1
	. else  write ?46,"Value: ",curFields(indxDesc),!
	write:'error !,"SUCCESS: All values were upgraded correctly",!
	write:error !,"FAILURE: Not all values were correctly upgraded",!
	quit

;
; Routine to read a DSE fileheader dump file locating the fields we want and placing them into the given array
;
readAndParseFile(fn,fields,isr2)
	open fn:readonly
	set saveio=$io
	use fn
	for i=1:1 read rec quit:$zeof  do
	. set char12=$zextract(rec,1,2)
	. set char3=$zextract(rec,3)
	. quit:("  "'=char12)!(" "=char3)!(""=char3)	; Ignore blank lines or non-data lines
	. ;
	. ; Ignore all but lines with our 3 fields
	. ;
	. set found=0
	. for j=1:1:3 if (rec[fieldDesc(j)) set found=1 quit
	. quit:'found
	. ;
	. ; This line has one or more of the fields we are interested in - separate record into the two possible
	. ; areas that could contain values.
	. ; In r1.34, Part 1 is columns 03-43 and part 2 is columns 46-79
	. ; In r2.00, Part 1 is columns 03-51 and part 2 is columns 54-95
	. ;
	. if isr2 do
	. . set part1=$zextract(rec,3,51)
	. . set part2=$zextract(rec,54,95)
	. else  do
	. . set part1=$zextract(rec,3,43)
	. . set part2=$zextract(rec,46,79)
	. ;
	. ; Parse each part into a description and value and if one of them is ours, keep it, else ignore it
	. ;
	. do parsePart(part1,.fields)
	. do parsePart(part2,.fields)
	use saveio
	quit

;
; Routine to parse a DSE file header dump part into its requisite field description and value parts. If the pair
; is for a field we are interested in, add it to the fields array.
;
parsePart(part,fields)
	;
	; First chore is to remove all duplicate white space so the record can be easily parsed by $zpiece().
	;
	set part=$translate(part,$zchar(9)," ")		; Turn any tabs to spaces
	set len=$zlength(part)
	set nextPos=1					; Next position to look at
	set newPart=""
	for  quit:nextPos>len  do
	. set nextSpcPos=$zfind(part," ",nextPos)	; Find the next space
	. if (0<nextSpcPos) do
	. . set newPart=newPart_$zextract(part,nextPos,nextSpcPos-1)
	. . for nextPos=nextSpcPos:1:len+1 quit:(" "'=$zextract(part,nextPos))	; Going to plus 1 terminates the loop
	. else  set newPart=newPart_$zextract(part,nextPos,len),nextPos=len+1
	set part=newPart
	;
	; The part we are looking at should have minimal white space in it now. Since the last space delimited piece
	; of the string is the value, the description is the first 1-(n-1) pieces and the value is the nth piece.
	;
	set pieceLen=$zlength(part," ")
	set:""'=part fields($zpiece(part," ",1,pieceLen-1))=$zpiece(part," ",pieceLen)
	quit
