;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2006, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bomtest;
createFiles;
	set mainlvl=$ZLEVEL
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	write "do init",!
	do init
	write "Now Create Big and Little endian files with BOM",!
	; GTM writes BOM only when OCHSET is "UTF-16" and that will be big-endian by default according to
	; unicode standard. So to output a LE BOM open the file in "M" mode and write the fffe string
	set unistr="Some kanji 散りぬるを我 "
	set file="bom_big_end.txt" open file:(OCHSET="UTF-16") use file write unistr close file
	set file="bom_little_end.txt" open file:(OCHSET="M") use file write $ZCH(255,254,0) close file
	; $ZCHAR(0) needs to be written as well along with the BOM because the open close above would have outputted
	; a 0a at the end which when appended with unistr below and read by LE format will cause inappropriate pairing
	; of bytes and BADCHAR error. So output a zero along with BOM and pair it with 0a to produce 0a00 - $C(2560) in the string read.
	if $ZV["OS390" zsystem "chtag -tc 1202 "_file
	open file:(APPEND:OCHSET="UTF-16LE") use file write unistr close file
	;
	;
	set verbose=1
	write "Now Read",!
	for fno=1:1:2 do
	. use $P  write "======fileinfo=",fileinfo(fno),"=====",!,!
	. set filename=$piece(fileinfo(fno),"|",1)
	. if $ZV["OS390" zsystem "chtag -tc 1208 "_filename
	. do open^io(filename,"READONLY:RECORDSIZE=32000","UTF-8")
	. do use^io(filename,"")
	. do badFileReadRepeat(.str)
	. close filename
	. use $P  zwr str
	. ;
	. set filename=$piece(fileinfo(fno),"|",1)
	. if $ZV["OS390" zsystem "chtag -tc 1204 "_filename
	. do open^io(filename,"READONLY:RECORDSIZE=32000","UTF-16")
	. do use^io(filename,"")
	. do badFileReadRepeat(.str)
	. close filename
	. use $P  zwr str
	. ;
	. set filename=$piece(fileinfo(fno),"|",1)
	. if $ZV["OS390" zsystem "chtag -tc 1202 "_filename
	. do open^io(filename,"READONLY:RECORDSIZE=32000","UTF-16LE")
	. ; if 1=fno the bom mismatch will be detected in the open so don't do the use/read
	. ; if 2=fno the bom will match so do the use/read
	. if 2=fno do
	. . do use^io(filename,"")
	. . do badFileReadRepeat(.str)
	. . close filename
	. . use $P  zwr str
	. ;
	. set filename=$piece(fileinfo(fno),"|",1)
	. if $ZV["OS390" zsystem "chtag -tc 1200 "_filename
	. do open^io(filename,"READONLY:RECORDSIZE=32000","UTF-16BE")
	. ; if 2=fno the bom mismatch will be detected in the open so don't do the use/read
	. ; if 1=fno the bom will match so do the use/read
	. if 1=fno do
	. . do use^io(filename,"")
	. . do badFileReadRepeat(.str)
	. . close filename
	. . use $P  zwr str
	. ;
	. set filename=$piece(fileinfo(fno),"|",1)
	. do open^io(filename,"READONLY:RECORDSIZE=32000","M")
	. do use^io(filename,"")
	. ; disable badchar because $length will be exercised in the badFileReadRepeat label
	. view "NOBADCHAR"
	. do badFileReadRepeat(.str)
	. close filename
	. use $P  zwr str
	. ;
	. set filename=$piece(fileinfo(fno),"|",1)
	. if $ZV["OS390" zsystem "chtag -tc 1208 "_filename
	. do open^io(filename,"READONLY:RECORDSIZE=32000","")
	. do use^io(filename,"")
	. do badFileReadRepeat(.str)
	. close filename
	. use $P  zwr str
	;
	quit
init
	set fileinfo(1)="bom_big_end.txt|UTF-16BE"
	set fileinfo(2)="bom_little_end.txt|UTF-16LE"
	quit
	;
badFileReadRepeat(str)
	set (rec,str)=""
	for  do  quit:($ZEOF!($length(rec)=0))
	. read rec
	. set str=str_rec
	quit
