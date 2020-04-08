;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
errors ;
		;;;
		; NOTE: BADCHSET and BADCASECODE are compile time errors unlike run time
		; so pass the unaccepted strings as a variable when we use the error trap mechanism below
badchset ;
		set errcnt=0,cnt=0
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set fname="temp.txt"
		set cnt=cnt+1 open fname:(ICHSET="whatever")
		set cnt=cnt+1 open fname:(OCHSET="blah")
		set cnt=cnt+1 open fname:(ICHSET="")
		set cnt=cnt+1 open fname:(OCHSET="")
		set cnt=cnt+1,type="utf-48" write $ZCONVERT("a",type,"utf-8"),!
		set cnt=cnt+1,type="utf-18" write $ZCONVERT("a","utf-8",type),!
		set cnt=cnt+1,type="M",type1="utf8" write $ZCONVERT("a",type1,type),!
		set cnt=cnt+1,type="UTF16ME",type1="M" write $ZCONVERT("a",type1,type),!
		set cnt=cnt+1,type="ＵＴＦ-８",type1="Ｍ" write $ZCONVERT("a",type1,type),!
		do ^examine(errcnt,cnt,"TEST-E-ERROR expected BADCHSET/INVZCONVERT missed")
		quit
dlrzctoobig ;
		set errcnt=0,cnt=0
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set cnt=cnt+1 write $ZCHAR(256),!
		set cnt=cnt+1 write $ZCHAR(300),!
		set cnt=cnt+1 write $ZCHAR(1000),!
		set cnt=cnt+1 write $ZCHAR(124,285,0),!
		set cnt=cnt+1 write $ZCHAR(0,255,256),!
		set cnt=cnt+1 write $ZCHAR(256,255,255),!
		set cnt=cnt+1 write $ZCHAR(267,287,254),!
		set cnt=cnt+1 write $ZCHAR(1000,1000,1000),!
		do ^examine(errcnt,cnt,"TEST-E-ERROR expected DLRZCTOOBIG missed")
		quit
badcasecode ;
		set errcnt=0,cnt=0
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set str="abc"
		set cnt=cnt+1,code="a" write $ZCONVERT(str,code),!
		set cnt=cnt+1,code="1111" write $ZCONVERT(str,code),!   ; multi-character string in second argument
		set cnt=cnt+1,code="X" write $ZCONVERT(str,code),!
		set cnt=cnt+1,code="Ｘ" write $ZCONVERT(str,code),!     ; multi-byte character in second argument
		set cnt=cnt+1,code="29" write $ZCONVERT(str,code),!       ; numeric second argument
		write $ZCONVERT(str,"L"),!
		do ^examine(errcnt,cnt,"TEST-E-ERROR expected BADCASECODE missed")
		quit
bommismatch ;
		set errcnt=0
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set file="bommismatch.out" open file:(CHSET="UTF-16") use file
		write "I should have a BOM before and is big endian by default"
		close file
		zsystem "if (""os390"" == $gtm_test_osname) chtag -tc 1202 "_file
		open file:(CHSET="UTF-16LE") use file
		read errstr
		close file
		if (0=errcnt) write "TEST-E-ERROR expected BOMMISMATCH not issued",!
		zsystem "if (""os390"" == $gtm_test_osname) chtag -tc 1200 "_file
		open file:(CHSET="UTF-16BE") use file
		read origstr
		close file
		w origstr,!
		if (origstr'="I should have a BOM before and is big endian by default") write "TEST-E-ERROR un-expected BOMMISMATCH issued",!
		quit
errortrap ;
		use $P
		if (($FIND($zstatus,"YDB-E-BADCHSET")=0)&($FIND($zstatus,"YDB-E-BADCASECODE")=0)&($FIND($zstatus,"YDB-E-DLRZCTOOBIG")=0)&($FIND($zstatus,"YDB-E-BOMMISMATCH")=0)&($FIND($zstatus,"YDB-E-INVZCONVERT")=0)) set $ZTRAP="" w "TEST-E-UNEXPECTED "_$zstatus_" ERROR " quit
		write $ZSTATUS,!
                set lab=$PIECE(errpos,"+",1)
                set offset=$PIECE($PIECE(errpos,"+",2),"^",1)+1
                set nextline=lab_"+"_offset
		set errcnt=errcnt+1
                goto @nextline
