;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to generate random transactions for $FIND() and $EXTRACT() on various types of strings and
; lengths to exercise the UTF8 scan-cache code. Testing using this routine typically uses two GT.M versions.
; This routine is run with one of them (perhaps the current production version) which generates the test
; cases and the expected results. The generated routine is self contained and should be run with a different
; version to make sure it comes up with the same results for all the test cases. Failures are noted.
;
; The types of strings we will operate on are as follows:
;   1. 3 strings of only ASCII chars < 33 bytes (no cache)
;   2. 3 strings of only ASCII chars >= 33 bytes (cacheable)
;   3. 5 strings of mixed ASCII and UTF8 chars < 33 bytes (no cache)
;   4. 25 strings of mixed ASCII and UTF8 chars >= 33 bytes (cachable) (broken up into various size ranges)
;   5. 3 strings of only UTF8 chars < 33 bytes (no cache)
;   6. 3 strings of only UTF8 chars >= 33 bytes (cacheable)
;
; All strings are at least 20 bytes in length so there's at least *something* to scan. The maximum length
; depends some on the usage. For example, the default cache size is to allow 32 groups. Since pure UTF8
; is restricted to 66 bytes per group to aid in scanning, 32 groups of 66 chars can scan 2112 chars so the
; max is set respectably high.
;
; Note since the utfchars string will have a character length in the neighborhood of 170K chars but a byte length
; of nearly 700K bytes and since this string is used heavily in initialization as well as the test itself, it
; is best for $gtm_utfcgr_string_groups to be set very high (default 32) to something like 4096 to allow this
; routine and the generated routine to run as fast as possible. Initially, while $gtm_curpro is a version
; without the UTF8 cacheing code we are testing here, the generation will run quite slow. But that will improve
; once the initial version with this support (V6.2-003) becomes $gtm_curpro (current production verion).
;
init(cases)
	set MINLEN=20
	set MAXWORDLEN=35
	set FALSE=0,TRUE=1
	set CHARBYCHAR=0,WORDBYWORD=1
	set CHARTYPASC=0,CHARTYPUTF=1
	set debug=FALSE
	set TAB=$char(9)
	set MAXCONST=700
	set $etrap="zwrite $zstatus zshow ""*"" break:debug  zhalt 1"
	set:(0=$data(cases)) cases=$ZCMDLINE+0
	set:(0=cases) cases=10			; Default primarily for testing
	;
	; Firstly, define the character sets to generate strings from. Use only printable chars since these strings
	; will end up as constants in a generated program.
	;
	set asciichars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+=-}]{[""':;?/>.<,"
	set asciicharslen=$length(asciichars)
	;
	; Our UTF8 selection will comprise a selections of chars that cause 2, 3, and 4 byte expansions.
	;
	set zlevel=$zlevel
	set utfchars2bytes=""
	for ccode=$$FUNC^%HD("80"):1:$$FUNC^%HD("7FF") set utfchars2bytes=utfchars2bytes_$$genbytes(ccode)
	set utfchars3bytes=""
	for ccode=$$FUNC^%HD("8FF"):1:$$FUNC^%HD("FFFF") set utfchars3bytes=utfchars3bytes_$$genbytes(ccode)
 	;
	; This next range has 1M characters in it which are 4 bytes each so we will do only every 10th char randomizing
	; the start point slightly so all chars are eventually used at one time or another.
	;
	set utfchars4bytes=""
	for ccode=$$FUNC^%HD("1000")+$random(10):10:$$FUNC^%HD("10FFFF") set utfchars4bytes=utfchars4bytes_$$genbytes(ccode)
	set utfchars=utfchars2bytes_utfchars3bytes_utfchars4bytes	; Should be comfortably under the 1MB limit
	set utfcharslen=$length(utfchars)
	write "Character sets built - now building strings",!
	;
	; Now, generate the strings we will operate on:
	;   - 3 strings of only ASCII chars < 33 bytes (no cache)
	;   - 3 strings of only ASCII chars >= 33 bytes (cacheable)
	;   - 5 strings of mixed ASCII and UTF8 chars < 33 bytes (no cache)
	;   - 25 strings of mixed ASCII and UTF8 chars >= 33 bytes (cachable) (broken up into various size ranges)
	;   - 3 strings of only UTF8 chars < 33 bytes (no cache)
	;   - 3 strings of only UTF8 chars >= 33 bytes (cacheable)
	;
	set strcnt=0
	do genstr(3,TRUE,FALSE,32,MINLEN)		; 3 strings - ascii-only - max len 32, minlen 20
	do genstr(3,TRUE,FALSE,256,33)			; 3 strings - ascii-only - max len 256, minlen 33
	do genstr(5,TRUE,TRUE,32,MINLEN)		; 5 strings - mixed - maxlen 32, minlen 20
	do genstr(5,TRUE,TRUE,2500,33)			; 5 strings - mixed - maxlen 2500, minlen 20
	do genstr(15,TRUE,TRUE,500,33)			; 15 strings - mixed - maxlen 500, minlen 20
	do genstr(5,TRUE,TRUE,200,33)			; 5 strings - mixed - maxlen 200, minlen 20
	do genstr(3,FALSE,TRUE,32,MINLEN)		; 3 strings - utf8-only - max len 32, minlen 20
	do genstr(3,FALSE,TRUE,2500,33)			; 3 strings - utf8-only - max len 2500, minlen 33
	;
	; In debug mode, dump our strings to a debug file
	;
	do:(debug)
	. new file
	. set file="utfcacheGenrand.zwr.txt"
	. open file:new
	. use file
	. zwrite strings
	. close file
	write "String generation complete - moving on to generate test cases",!
	;
	; First open the file and write the values of the strings() array.
	;
	set file="utfcacheGenerated.m"
	open file:(new:stream:nowrap:chset="M")
	use file
	write ";",!
	write "; Generated by ",$text(+0),".m",!
	write ";",!
	write TAB,"set errors=0",!
	for i=1:1:strcnt do
	. set strval=strings(i)
	. do setstring(strval,"set string=","set string=string_")
	. write TAB,"set strings(",i,")=string",!
	;
	; Generate the desired number of cases of the following form:
	;
	;   1.  Cases can be for $EXTRACT() or $FIND() (randomly chosen)
	;   2.  Each case choses a random location within the string to operate on.
	;   2.  For each case, there are three subcases that will operate on location-1, location, and location+1
	;
	for case=1:1:cases do
	. set stridx=$random(strcnt)+1
	. set randloc=$random($length(strings(stridx))-2)+2	; Avoids first and last char so can do +1 and -1 access
	. set casetype=$random(2)			; 0=$extract(), 1=$find()
	. write TAB,";",!,TAB,"; Test case #",case,!,TAB,";",!
	. ;
	. ; For each subcase the starting location is (in sequence) randloc-1, +0, and +1. Each subcase computes
	. ; its own random endpoint. Randomize the order this is done in (forwards/backwards) so cacheing is used
	. ; differently across similar test cases.
	. ;
	. if $random(2) do				; Generate subcases "forward"
	. . for subcase=-1:1:1 do genextractsubcases:(0=casetype),genfindsubcases:(1=casetype)
	. else  for subcase=1:-1:-1 do genextractsubcases:(0=casetype),genfindsubcases:(1=casetype)
	;
	; Write epilogue and error count
	;
	write TAB,";",!
	write TAB,"; Epilogue",!
	write TAB,";",!
	write TAB,"write ""Total of ",cases," test cases with "",errors,"" error(s)"",!",!
	close file
	quit

;
; Routine to take a given string and write it as one or more SET statements to build up the string. GT.M's maximum
; command line width is 8192 (MAX_SRCLINE in compiler.h). Our maximum line byte-length is 2500 but since we are
; allocating 2, 3, and 4 byte UTF8 characters, it is possible for some of these long lines to overflow the SET
; command we generate. So we split up setting the string values into multiple sets with a maximum length of 700
;  bytes. This follows from the potential 11X increase in the $ZWRITE() format of a given string. A max line of
; 8192 divided by 11 yields 740 bytes but some of those bytes will be the set command and the variable and its
; append value so we cap it at 700 bytes. Write it in M mode as we may be breaking up some valid UTF8 chars.
;
setstring(str,firstprefix,otherprefix)
	new writeprefix,strval,strpart
	set writeprefix=firstprefix
	set strval=str
	for  quit:(""=strval)  do
	. set strpart=$zextract(strval,1,MAXCONST)
	. set strval=$zextract(strval,MAXCONST+1,999999)
	. write TAB,writeprefix,$zwrite(strpart),!
	. set writeprefix=otherprefix
	quit

;
; Routine to generate an extract subcase. The local vars are all setup so no parms necessary.
;
genextractsubcases
	set startloc=randloc+subcase
	write TAB,";    subcase ",subcase,!
	set endloc=$random($length(strings(stridx))-startloc+1)+startloc
	set strxtr=$extract(strings(stridx),startloc,endloc)
	do setstring(strxtr,"set expectedstring=","set expectedstring=expectedstring_")
	write TAB,"set xtrstr=$extract(strings(",stridx,"),",startloc,",",endloc,")",!
	write TAB,"if (xtrstr'=expectedstring) do",!
	write TAB,". set errors=errors+1",!
	write TAB,". write ""Case ",case," ($EXTRACT()) subcase value: ",subcase,"  **** Failed - string is not as expected"",!",!
	write TAB,". zwrite expectedstring,xtrstr",!
	quit

;
; Routine to generate an extract subcase. The local vars are all setup so no parms necessary.
;
genfindsubcases
	set startloc=randloc+subcase
	;
	; Choose a random char to search for in the string that occurs at the random location or after it (to end of string)
	;
	set charloc=$random($length(strings(stridx))-startloc+1)+startloc
	set char=$extract(strings(stridx),charloc)
	write TAB,"set floc=$find(strings(",stridx,"),",$zwrite(char),",",charloc,")",!
	write TAB,"if (floc'=",charloc+1,") do",!
	write TAB,". set errors=errors+1",!
	write TAB,". write ""Case ",case," ($FIND()) subcase value: ",subcase,"  expected $find() value: ",charloc+1,"  but received "",floc,!",!
	quit

;
; Routine to generate the byte stream for a given UTF8 code. Done in a separate routine so error handling can recover
; for invalid codes.
;
genbytes(ccode)
	new $etrap
	set $etrap="if (150381090=($zstatus+0)) set $ecode="""" quit """""
	quit $char(ccode)

;
; Routine to generate random strings given the parameters. Strings are added to strings() array with strcnt
; containing the number.
;
genstr(cnt,genascii,genutf,maxlen,minlen)
	new stridx,genmix,gentype,genlen,wordchars,newword
	set genlen=$random(maxlen-minlen)+minlen+1
	;
	; Decide on the type of generation. Possibles are:
	;
	; 1. Char-by-char - Each char is independently decided on and generated.
	; 2. Word-by-word - Once we decide on a char type, generate some number of chars of the same type.
	;                   Note this method is only useful if both genascii & genutf are TRUE.
	;
	set genmix=(genascii&genutf)
	;
	; One iteration for each string we are generating
	;
	for stridx=$increment(strcnt):1:$increment(strcnt,cnt-1) do
	. set str=""
	. set genlen=$random(maxlen-minlen)+minlen+1
	. if (genlen<minlen) zwrite maxlen,minlen,genlen break:debug  write !,"generation failed" zhalt 1
	. set gentype=$select(genmix:$random(2),TRUE:CHARBYCHAR)	; 0=char-by-char, 1=word-by-word
	. set wordchars=0						; Force recompute inside loop
	. set chartype=CHARTYPUTF					; Default for first go thru
	. for  do  quit:(genlen<($zlength(str)+$zlength(char)))  set str=str_char
	. . ;
	. . ; Whether we are doing word-by-word or char-by-char, figure out which character type we should be
	. . ; be selecting from.
	. . ;
	. . if (genmix) do
	. . . if (WORDBYWORD=gentype) do
	. . . . if (0=wordchars) set wordchars=$random(MAXWORDLEN)+1,chartype=$random(2) ; In word-by-word, only reset char type when wordlen=0
	. . . else  set chartype=$random(2)
	. . else  set chartype=$select(genascii:CHARTYPASC,genutf:CHARTYPUTF)
	. . set char=$select(CHARTYPASC=chartype:$zextract(asciichars,$random(asciicharslen)+1),TRUE:$extract(utfchars,$random(utfcharslen)+1))
	. . set:(0<wordchars) wordchars=wordchars-1			; Easier to do this regardless than to test if needed
	. set strings(stridx)=str,stringlen(stridx)=$length(str),stringzlen(stridx)=$zlength(str)
	. write:(debug) "string(",stridx,")  charlen=",$length(str),"  bytelen=",$zlength(str),"  gentype=",gentype,"  genlen=",genlen,!
	quit
