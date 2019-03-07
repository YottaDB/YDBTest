;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2006, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
viewbadchar(verror) ;
		; ##################################################################################################################################
		; The routine produces two output logs
		; i) alwaysbadchar.out ==> this contains the write of all badchar errors. No matter what with respect to BADCHAR setting this should always error out.
		; ii) viewbadchar_<verror>.out ==> this contains all character oriented functions output based on BADCHAR view setting
		; will contain BADCHAR errors if verror passed is expected and will NOT contain any error if verror is notexpected
		; The test script after calling this routine should appropriately process the viewbadchar.out using check_err_exists.csh etc. to
		; eliminate known errors from the outfile
		; NOTE: This routine should be called after executing global^unicodesampledata
		; ##################################################################################################################################
		;
		set file1="alwaysbadchar.out"
		open file1:(APPEND)
		set save=verror
		set verror="expected" ; always throw badchar
		use file1
		write "TEST-I-write of a bad character begins - should produce always BADCHAR error",!
		do justwrite
		set verror=save ; restore verror for the rest of the test
		write "TEST-I-write of bad characters completed",!
		close file1
		;;;
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set filex="invdlrcval_"_verror_".out"
		open filex:(APPEND)
		use filex
		write "TEST-I-char function check on sentinels begins, should produce INVDLRCVAL error",!
		do charsentinels
		write "TEST-I-char function check on sentinels completed",!
		close filex
		;;;
		set file2="viewbadchar_"_verror_".out"
		open file2:(APPEND)
		use file2
		set start1=^cntstrbadchars,start2=^cntstrsentinelss
		set end1=^cntstrbadchare,end2=^cntstrsentinelse
		for loopcnt=1,2 do
		. set s="start"_loopcnt
		. set e="end"_loopcnt
		. for i=@s:1:@e do
		. . set xxx=^str(i)
		. . set ccc=^comments(i)
		. . set yyy=^ucp(i)
		. . ; ZCONVERT will return BADCHAR irrespective of badchar setting so remove it from the list
		. . ; ZCHAR will not return BADCHAR instead returns INVDLRCVAL on the ucp code point value.corresponding ucp(cnti) will be -1
		. . ; because $a of that will be -1. so remove it from the list
		. . for j="$ASCII(xxx)","$EXTRACT(xxx)","$JUSTIFY(xxx,100)","$LENGTH(xxx)","$PIECE(xxx,""c"")","$TRANSLATE(xxx)","$ZSUBSTR(xxx,1)","$ZWIDTH(xxx)" do
		. . . kill flag
		. . . set dummy="set blah="_j
		. . . x dummy
		. . . if ((0=$DATA(flag))&("expected"=verror)) write "TEST-E-EXPECTED BADCHAR NOT ISSUED on "_j_" for - "_ccc,!
		close file2
		do find
		quit
find ;
		; FIND is treated separately here because of the following
		; 1) Issue BADCHAR error if the delimiter string (second argument) has an invalid byte sequence.
		; 2) Issue BADCHAR error if it finds an invalid byte sequence in the input string (first argument) during its processing.
		; 3) NOT issue BADCHAR error if it has found a match but there is an invalid byte sequence after the match point in the input string.
		; 4) NOT issue BADCHAR error if the input string's byte length is LESS than the delimiter string's byte length.
		set file2="viewbadchar_"_verror_".out"
		open file2:(APPEND)
		use file2
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		for i=1:1:^cntstr do
		. ; this setting is critical to overcome point 4 and have the input string always GREATER than the badchar find string
		. set ccc=^comments(i)
		. set tmp=^str(i)
		. for t=1:1:500 s tmp=tmp_"a"
		. for jj=^cntstrbadchars:1:^cntstrbadchare do
		. . set xxx=^str(jj)
		. . for j="$FIND(xxx,""s"")","$FIND(xxx,xxx)","$FIND(tmp,xxx)" do
		. . . kill flag
		. . . set dummy="set blah="_j
		. . . x dummy
		. . . if ((0=$DATA(flag))&("expected"=verror)) write "TEST-E-EXPECTED BADCHAR NOT ISSUED on $FIND for - "_j_" "_^comments(jj)_" - "_ccc,!
		close file2
		quit
justwrite;
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set j="just a plain write of badchar"
		set maini="write ^str(i),!"
		 for i=^cntstrbadchars:1:^cntstrbadchare do
		 . set ccc=^comments(i)
		 . kill flag
		 . xecute maini ; entire routine operates on xecutes followed by ZGOTO on error trap, so follow suite even here
		 . if ((0=$DATA(flag))&("expected"=verror)) write "TEST-E-EXPECTED BADCHAR NOT ISSUED on "_maini_" for - "_ccc,!
		quit
charsentinels ;
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set j="$CHAR on sentinels"
		for i=^cntstrsentinelss:1:^cntstrsentinelse do
		. set xxx=^str(i)
		. set yyy=^ucp(i)
		. set ccc=^comments(i)
		. kill flag
		. set dummy="set blah=$CHAR(yyy)"
		. x dummy
		. if ((0=$DATA(flag))&("expected"=verror)) write "TEST-E-EXPECTED BADCHAR NOT ISSUED on "_j_" for - "_ccc,!
		quit
convert ;
		; ZCONVERT always throws a BADCHAR so process it separate
		set verror="expected"
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set file3="viewbadchar_zconvert.out"
		open file3:(APPEND)
		use file3
		set j="$ZCONVERT"
		for i=^cntstrbadchars:1:^cntstrbadchare do
		. set ccc=^comments(i)
		. for case="L","U","T" do
		. . kill flag
		. . set dummy="set blah="""_$ZCONVERT(^str(i),case)_""""
		. . x dummy
		. . if (0=$DATA(flag))&($view("BADCHAR")) write "TEST-E-EXPECTED BADCHAR NOT ISSUED for ZCONVERT of - "_ccc,!
		close file3
		quit
errortrap ;
		if (($FIND($zstatus,"YDB-E-BADCHAR")=0)&($FIND($zstatus,"YDB-E-INVDLRCVAL")=0)) set $ZTRAP="" w "TEST-E-UNEXPECTED "_$zstatus_" ERROR " quit
		if ("notexpected"=verror) write "TEST-E-UNEXPECTED BADCHAR ISSUED on "_j_" for - "_ccc,!
		W "$ZSTATUS for "_ccc_" "_$zstatus,!
		set lab=$PIECE(errpos,"+",1)
		set offset=$PIECE($PIECE(errpos,"+",2),"^",1)+1
		set nextline=lab_"+"_offset
		set nextline=$ZLEVEL-1_":"_nextline ; since we have xecutes that increases the ZLEVEL this setting is critical to avoid looping
		set flag=""
		ZGOTO @nextline
