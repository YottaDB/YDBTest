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
eoftest;
createFilesTruncate;
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	write "createFiles for truncation followed by reads",!
	do init
	set unistr(1)="This will be truncated by last 1 byte -١٢٣٤٥٧₁₂₃₄"
	set unistr(2)="This will be truncated by last 2 byte -١٢٣٤٥٧₁₂₃₄０１２３４５６７"
	set unistr(3)="This will be truncated by last 3 byte -١٢٣٤٥٧₁₂₃₄０１２３４５６７乴亐亯仑件伞佉佷"_$CHAR(1111110,1111111,1111112)
	set unistr(4)="This will be truncated by last 1 byte -١٢٣٤٥٧₁₂₃₄０１２３４５６７乴亐亯仑件伞佉佷"_$CHAR(1111110,1111111,1111112)
	set unistr(5)="This will be truncated by last 1 byte -١٢٣٤٥٧₁₂₃₄０１２３４５６７乴亐亯仑件伞佉佷"_$CHAR(1111110,1111111,1111112)
	set unistr(6)="This will be truncated by last 1 byte -١٢٣٤٥٧₁₂₃₄０１２３４５６７乴亐亯仑件伞佉佷"_$CHAR(1111110,1111111,1111112)
	;Surrogate Pairs : (U+D800-U+DFFF)
	set unistr(7)="This will be truncated by last 2 bytes of a surrogate pair -١٢٣٤٥٧₁₂₃₄０１２３４５６７乴亐亯仑件伞佉佷"_$CHAR(65536,65537,65538)
	set unistr(8)="This is a simple ASCII file (0-127)"
	f fno=1:1:8 do
	. set zlengths(fno)=$$createFile1Line^basicUnicodeIO(fileinfo(fno),unistr(fno))
	zwr zlengths
	zwr fileinfo
	quit
createFilesEncoding;
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	write "createFiles for different encoding reads",!
	do init
	for i=1:1:8 do
	. set unistr="█▇▆▅▄▃▂▁"_$ZCHAR(0)
	. set zlengthe(i)=$$createFile1Line^basicUnicodeIO(fileinfo(i),unistr)
	zwr zlengthe
	quit
readTruncates;
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	write !,!,!,"readTruncates",!
	do init
	set verbose=1
	for fno=1:1:8 do
	. set filename=$piece(fileinfo(fno),"|",1)
	. set encoding=$piece(fileinfo(fno),"|",2)
	. write "filename=",filename," : encoding=",encoding,!
	. set (rec,str)=""
	. do open^io(filename,"READONLY:RECORDSIZE=32000:EXCEPTION=""set err=""""open"""""_" goto ioerror""",encoding)
	. do use^io(filename,"EXCEPTION=""set err=""""use"""""_" goto ioerror""")
	. do badFileRead(.str)
	. close filename
	. use $P  zwr str if ($DATA(zb)) zwr zb
	quit
readBadEncoding;
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	write !,!,!,"readBadEncoding",!
	write "readBadEncoding test has the following characteristics",!
	write !,"The actual data is solid blocks which will turn into chinese when the encoding is UTF16(LE,BE)",!
	write !,"Issue BOMMISMATCH when LE and BE are read interchangeably",!
	write !,"Issue BADCHAR when UTF16 data is read using UTF8 encoding",!,!
	do init
	set verbose=1
	for fno=1,4,5,6,8 do
	. set filename=$piece(fileinfo(fno),"|",1)
	. set encoding=$piece(fileinfo(fno),"|",2)
	. write "filename=",filename," : encoding=",encoding,!
	. set str=""
	. if $ZV["OS390" zsystem "chtag -tc 1208 "_filename
	. do badFileOpenRead("UTF-8",fno)
	. if $ZV["OS390" zsystem "chtag -tc 1204 "_filename
	. do badFileOpenRead("UTF-16",fno)
	. if $ZV["OS390" zsystem "chtag -tc 1200 "_filename
	. do badFileOpenRead("UTF-16BE",fno)
	. if $ZV["OS390" zsystem "chtag -tc 1202 "_filename
	. do badFileOpenRead("UTF-16LE",fno)
	. if $ZV["OS390" zsystem "chtag -tc 1208 "_filename
	. do badFileOpenRead("M",fno)
	quit
badFileOpenRead(encoding,fno)
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
;	do open^io(filename,"READONLY:RECORDSIZE=32000:EXCEPTION=""set err=""""open"""""_" goto ioerror""",encoding)
;	do use^io(filename,"EXCEPTION=""set err=""""use"""""_" goto ioerror""")
	set (str,zb)=""
	do open^io(filename,"READONLY:RECORDSIZE=32000",encoding)
	; 4=fno specifies a file written in UTF-16 encoding so the preceding open will detect bom mismatch for encoding=UTF-16LE
	; so don't do the use/read in this case
	if '((4=fno)&("UTF-16LE"=encoding)) do
	. do use^io(filename)
	. read str
	. close filename
	. use $P  zwr str zwr zb
	quit
badFileRead(str)
	set (rec,str,zb)=""
	read str
	quit
init
	write !,!,!,"init",!
	set fileinfo(1)="utf8-1.txt|UTF-8|0|1114111"
	set fileinfo(2)="utf8-2.txt|UTF-8|0|1114111"
	set fileinfo(3)="utf8-3.txt|UTF-8|0|1114111"
	set fileinfo(4)="utf16.txt|UTF-16|0|1114111"
	set fileinfo(5)="utf16_BE.txt|UTF-16BE|0|1114111"
	set fileinfo(6)="utf16_LE.txt|UTF-16LE|0|1114111"
	set fileinfo(7)="utf16-Surrogate.txt|UTF-16|0|1114111"
	set fileinfo(8)="ascii.txt|M|0|1114111"
	quit
ioerror
	set zb=$ZB
	use $PRINCIPAL
	write "=================================================",!
	write "Source of error was ",err,!
	write $ZSTATUS,!
	write "continue...",!
	write "=================================================",!
	close filename
	quit
