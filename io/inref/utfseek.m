;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utfseek
	; exercise sequential device seek for non-fixed and fixed UTF modes supporting io/sdseek.csh test
	; utfseekinit.m initializes the files used by this test and supports this routine during the test
	new x,p,p1
	set $ztrap="goto errorAndCont^errorAndCont"
	set pp="ppipe"
	; no actual I/O is done over the pipe but want it to run in M mode and be cleaned up automatically
	open pp:(comm="source $gtm_tst/$tst/u_inref/switch_chset_m.csh; $gtm_exe/mumps -r utfseekinit ":write)::"pipe"
	write "**********************************",!
	write "UTF-8 WITH BOM NON-FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek8withbom with 100 lines showing first and last lines:
	;x=    0 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 47
	;x=   99 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 4703
	do wait(1)
	set p="useek8withbom"
	open p
	use $p write !,"** write line 100 at end to test relative SEEK=-47 after a write",!!
	use p:seek="9999999"
	; use inseek in next use to show equivalence with seek for non-split device
	use p:inseek="-47"
	read x
	do results(x)
	; write another line at the end so last operation is a write
	set y=$piece(x,"- ",2)
	use p:seek="9999999"
	write " 100 - "_y,!
	; use outseek in next use to show equivalence with seek for non-split device
	use p:outseek="-47"
	read x
	do results(x)
	use $p write !,"** write line 101 at end, write line 102 in background with 2 sec delay, then do a read with follow to read 102",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write " 101 - "_y,!
	; write another line in the background and read with follow
	set ^a=2
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being 755",!!
	use p:seek="379"
	use p:seek="-94"
	use p:seek="+470"
	read x
	; offset will be 802 after read
	do results(x)
	write !,"** close with nodestroy, reopen restored and read 20 lines to test data and $ZKEY",!!
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	for i=1:1:20 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:nofix
	for i=1:1:20 use p read x do results(x)
	; try to seek before the beginning to verify it points to first byte (offset 0)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-9999999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write lines 103 and 104 at the end then seek=""-94"" to beginning of 103",!!
	use p:seek="9999999"
	write " 103 - "_y,!
	write " 104 - "_y,!
	use p:seek="-94"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-47"" to the beginning of 103, again",!!
	; truncate the last line and seek="-47" to the beginning of 103, again
	use p:truncate
	use p:seek="-47"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	close p
	; open with a seek to 755
	write !,"** open with a seek to 755 again",!!
	open p:seek="755"
	use p
	read x
	do results(x)
	close p
	; do some OPEN testing with SEEK
	; on open, append is applied first regardless of order, all others are applied as entered
	write !,"** open append:seek=""-282"" to read 5th from last line",!
	open p:(append:seek="-282")
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-47"" to read same line again",!
	open p:seek="-47"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+47"" to skip a line",!
	open p:seek="+47"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen append:seek=""-47"" to output last line",!
	open p:(append:seek="-47")
	use p
	read x
	do results(x)
	close p

	write "**********************************",!
	write "UTF-8 WITH NO BOM NON-FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek8nobom with 100 lines showing first and last lines:
	;x=    0 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 47
	;x=   99 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 4700
	set p="useek8nobom"
	open p
	use $p write !,"** write line 100 at end to test relative SEEK=-47 after a write",!!
	use p:seek="9999999"
	use p:seek="-47"
	read x
	do results(x)
	set y=$piece(x,"- ",2)
	use p:seek="9999999"
	write " 100 - "_y,!
	use p:seek="-47"
	read x
	do results(x)
	use $p write !,"** write line 101 at end, write line 102 in background with 2 sec delay, then do a read with follow to read 102",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write " 101 - "_y,!
	; write another line in the background and read with follow
	set ^a=3
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being 752",!!
	use p:seek="376"
	use p:seek="-94"
	use p:seek="+470"
	read x
	; offset will be 799 after read
	do results(x)
	write !,"** close with nodestroy, reopen restored and read 20 lines to test data and $ZKEY",!!
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	for i=1:1:20 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:nofix
	for i=1:1:20 use p read x do results(x)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-9999999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write lines 103 and 104 at the end then seek=""-94"" to beginning of 103",!!
	use p:seek="9999999"
	write " 103 - "_y,!
	write " 104 - "_y,!
	use p:seek="-94"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-47"" to the beginning of 103, again",!!
	; truncate the last line and seek="-47" to the beginning of 103, again
	use p:truncate
	use p:seek="-47"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	close p
	; open with a seek to 752
	write !,"** open with a seek to 752 again",!!
	open p:seek="752"
	use p
	read x
	do results(x)
	close p
	; do some OPEN testing with SEEK
	; on open, append is applied first regardless of order, all others are applied as entered
	write !,"** open append:seek=""-282"" to read 5th from last line",!
	open p:(append:seek="-282")
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-47"" to read same line again",!
	open p:seek="-47"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+47"" to skip a line",!
	open p:seek="+47"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen append:seek=""-47"" to output last line",!
	open p:(append:seek="-47")
	use p
	read x
	do results(x)
	close p

	write "**********************************",!
	write "UTF-16 WITH BOM NON-FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek16withbom with 100 lines showing first and last lines:
	; the first character on each line is different
	;x= ԞՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 42
	;x= ցՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 4002
	set p="useek16withbom"
	open p:(ICHSET="UTF-16":OCHSET="UTF-16BE")
	use $p write !,"** write line 100 at end to test relative SEEK=-52 after a write",!!
	use p:seek="9999999"
	use p:seek="-40"
	read x
	do results(x)
	; write another line at the end so last operation is a write
	use p:seek="9999999"
	write "100 - "_x,!
	use p:seek="-52"
	read x
	do results(x)
	use $p write !,"** write line 101 at end, write line 102 in background with 2 sec delay, then do a read with follow to read 102",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	set y=$piece(x,"- ",2)
	write "101 - "_y,!
	; write another line in the background and read with follow
	set ^a=4
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being 3242",!!
	use p:seek="3082"
	use p:seek="-160"
	use p:seek="+320"
	read x
	; offset will be 3282 after read
	do results(x)
	write !,"** close with nodestroy, reopen restored and read 20 lines to test data and $ZKEY",!!
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	for i=1:1:20 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:nofix
	for i=1:1:20 use p read x do results(x)
	; try to seek before the beginning to verify it points to first byte (offset 0)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-9999999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write lines 103 and 104 at the end then seek=""-104"" to beginning of 103",!!
	use p:seek="9999999"
	write "103 - "_y,!
	write "104 - "_y,!
	use p:seek="-104"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-52"" to the beginning of 103, again",!!
	; truncate the last line and seek="-52" to the beginning of 103, again
	use p:truncate
	use p:seek="-52"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	close p
	; open with a seek to 3242
	write !,"** open with a seek to 3242 again",!!
	open p:(ICHSET="UTF-16":seek="3242")
	use p
	read x
	do results(x)
	close p
	; do some OPEN testing with SEEK
	; on open, append is applied first regardless of order, all others are applied as entered
	write !,"** open ICHSET=""UTF-16"":OCHSET=""UTF-16BE"":append:seek=""-288"" to read 5th from last line",!
	open p:(ICHSET="UTF-16":OCHSET="UTF-16BE":append:seek="-288")
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-40"" to read same line again",!
	open p:seek="-40"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+40"" to skip a line",!
	open p:seek="+40"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen append:seek=""-52"" to output last line",!
	open p:(append:seek="-52")
	use p
	read x
	do results(x)
	close p

	; do some switching between character sets to show changes occur correctly when doing reopens
	; with differing character sets after close nodestroy.

	write !,"** open ICHSET=""UTF-16"":OCHSET=""UTF-16BE"" and read first line",!
	open p:(ICHSET="UTF-16":OCHSET="UTF-16BE")
	do zshowout
	use p
	read x
	do results(x)
	; save x to write in UTF-8 mode later
	set savex=x
	close p:nodestroy
	write !,"** close nodestroy then reopen CHSET=""M"" to read and expect an error",!
	open p:(CHSET="M")
	do zshowout
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen ICHSET=""UTF-16"":OCHSET=""UTF-16BE"":append:seek=""-52"" to read last line",!
	open p:(ICHSET="UTF-16":OCHSET="UTF-16BE":append:seek="-52")
	do zshowout
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen CHSET=""M"":append to write a line in M chset to end of file",!
	open p:(CHSET="M":append)
	do zshowout
	use p
	write "This is some text in M character set at the end of the file",!
	use $p
	write !,"** seek to the beginning of the line and read in M chset",!
	use p:seek="4210"
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen CHSET=""UTF-8"" and try to read first line and expect an error",!
	open p:(CHSET="UTF-8")
	do zshowout
	use p
	read x
	close p:nodestroy
	write !,"** close nodestroy then reopen append and write savex in UTF-8 mode to end of file",!
	open p:append
	do zshowout
	use p
	write savex,!
	use $p
	write !,"** seek to the beginning of the line and read in UTF-8 chset",!
	use p:seek="4270"
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen ICHSET=""UTF-16"":OCHSET=""UTF-16BE"":seek=""4270"" to read line expecting an error",!
	open p:(ICHSET="UTF-16":OCHSET="UTF-16BE":seek="4270")
	do zshowout
	use p
	read x
	use $p
	write !,"** rewind file and read first line again in UTF-16 chset",!
	use p:rewind
	read x
	do results(x)
	write !,"** seek to original end of file and truncate",!
	write !,"** read to show original file size after truncate and zeof is 1",!
	use p:(seek="4210":truncate)
	read x set zk=$zkey,zeof=$zeof use $p write " $zeof= ",zeof," $zkey= ",zk,!
	close p

	write "**********************************",!
	write "UTF-16 WITH NO BOM NON-FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek16nobom with 100 lines showing first and last lines:
	; the first character on each line is different
	;x= ԞՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 40
	;x= ցՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 4000
	set p="useek16nobom"
	open p:(ICHSET="UTF-16":OCHSET="UTF-16BE")
	use $p write !,"** write line 100 at end to test relative SEEK=-52 after a write",!!
	use p:seek="9999999"
	use p:seek="-40"
	read x
	do results(x)
	; write another line at the end so last operation is a write
	use p:seek="9999999"
	write "100 - "_x,!
	use p:seek="-52"
	read x
	do results(x)
	use $p write !,"** write line 101 at end, write line 102 in background with 2 sec delay, then do a read with follow to read 102",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	set y=$piece(x,"- ",2)
	write "101 - "_y,!
	; write another line in the background and read with follow
	set ^a=5
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being 3240",!!
	use p:seek="3080"
	use p:seek="-160"
	use p:seek="+320"
	read x
	; offset will be 3280 after read
	do results(x)
	write !,"** close with nodestroy, reopen restored and read 20 lines to test data and $ZKEY",!!
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	for i=1:1:20 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:nofix
	for i=1:1:20 use p read x do results(x)
	; try to seek before the beginning to verify it points to first byte (offset 0)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-9999999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write lines 103 and 104 at the end then seek=""-104"" to beginning of 103",!!
	use p:seek="9999999"
	write "103 - "_y,!
	write "104 - "_y,!
	use p:seek="-104"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-52"" to the beginning of 103, again",!!
	; truncate the last line and seek="-52" to the beginning of 103, again
	use p:truncate
	use p:seek="-52"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	close p
	; open with a seek to 3240
	write !,"** open with a seek to 3240 again",!!
	open p:(ICHSET="UTF-16":seek="3240")
	use p
	read x
	do results(x)
	close p
	; do some OPEN testing with SEEK
	; on open, append is applied first regardless of order, all others are applied as entered
	write !,"** open ICHSET=""UTF-16"":OCHSET=""UTF-16BE"":append:seek=""-288"" to read 5th from last line",!
	open p:(ICHSET="UTF-16":OCHSET="UTF-16BE":append:seek="-288")
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-40"" to read same line again",!
	open p:seek="-40"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+40"" to skip a line",!
	open p:seek="+40"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen append:seek=""-52"" to output last line",!
	open p:(append:seek="-52")
	use p
	read x
	do results(x)
	close p

	write "**********************************",!
	write "UTF-8 WITH NO BOM FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek8fixnobom with 100 lines showing first and last lines:
	;x=    0 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 1,0
	;x=   99 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 100,0
	;x len = 31
	;file size = 4600
	set p="useek8fixnobom"
	open p:(fixed:recordsize=46)
	use p:width=31
	; randomly read from the beginning of the file to show BOM is read correctly with or without it
	if $random(2) read x
	use $p write !,"** write line 100 at end to test relative SEEK=-1 after a write",!!
	use p:seek="9999999"
	use p:seek="-1"
	read x
	do results(x)
	; write another line at the end so last operation is a write
	set y=$piece(x,"- ",2)
	use p:seek="9999999"
	write " 100 - "_y,!
	use p:seek="-1"
	read x
	do results(x)
	use $p write !,"** write line 101 at end, write line 102 in background with 2 sec delay, then do a read with follow to read 102",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write " 101 - "_y,!
	; write another line in the background and read with follow
	set ^a=6
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being record 49",!!
	use p:seek="45"
	use p:seek="-5"
	use p:seek="+9"
	read x
	; offset will be 50 after read
	do results(x)
	write !,"** read a partial record to test seek=""-1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""+1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="+1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""52""",!!
	use p
	read x#10
	do results(x)
	use p:seek="52"
	read x
	do results(x)
	write !,"** read a partial record, close nodestroy, reopen restored and read rest of record and 19 more to test data and $ZKEY",!!
	use p
	read x#10
	do results(x)
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	use p
	read x
	do results(x)
	for i=1:1:19 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; Reopen with same deviceparameters
	open p:(fixed:recordsize=46)
	use p:width=31
	for i=1:1:20 use p read x do results(x)
	; try to seek before the beginning to verify it points to first byte (offset 0)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write lines 103 and 104 at the end then seek=""-2"" to beginning of 103",!!
	use p:seek="9999999"
	; write lines 103 and 104 at the end then seek="-2" to beginning of 103
	write " 103 - "_y,!
	write " 104 - "_y,!
	use p:seek="-2"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-1"" to the beginning of 103, again",!!
	; truncate the last line and seek="-1" to the beginning of 103, again
	use p:truncate
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	; for fixed utf must close with "nodestroy" to do a seek on open
	do dxdy(p,1)
	close p:nodestroy
	; open with a seek to 49
	write !,"** open with a seek to 49 again",!!
	open p:seek="49"
	do dxdy(p,3)
	use p
	read x
	do results(x)
	close p
	; alternately, the first operation can be a read of the first record followed by a use p:seek
	; open with a seek to 49
	write !,"** open, read first record and then seek to 49 again",!!
	open p:(fixed:recordsize=46)
	use p:width=31
	read x
	do results(x)
	use p:seek="49"
	read x
	do results(x)
	; do some OPEN testing with SEEK
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-1"" to read same record again",!
	open p:seek="-1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+1"" to skip a record",!
	open p:seek="+1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write "close nodestroy then reopen append:seek=""-1"" to read last record",!
	open p:(append:seek="-1")
	use p
	read x
	do results(x)
	close p

	write "**********************************",!
	write "UTF-16 WITH NO BOM FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek16fixnobom with 100 lines showing first and last lines:
	; the first character on each line is different
	;x= ԞՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 1,0
	;x= ցՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 100,0
	;x len = 19
	;file size = 3800
	set p="useek16fixnobom"
	open p:(fixed:recordsize=38:ICHSET="UTF-16":OCHSET="UTF-16BE")
	use p:width=19
	; randomly read from the beginning of the file to show BOM is read correctly with or without it
	if $random(2) read x
	use $p write !,"** write line with first char 1 at end to test relative SEEK=-1 after a write",!!
	use p:seek="9999"
	use p:seek="-1"
	read x
	do results(x)
	; write another line at the end so last operation is a write
	use p:seek="9999"
	write $tr(x,"ց","1")
	use p:seek="-1"
	read x
	do results(x)
	use $p write !,"** write line 2 at end, write line 3 in background with 2 sec delay, then do a read with follow to read 3",!!
	use p:seek="9999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write $tr(x,"1","2")
	; write another line in the background and read with follow
	set ^a=7
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being record 49",!!
	use p:seek="45"
	use p:seek="-5"
	use p:seek="+9"
	read x
	; offset will be 50 after read
	do results(x)
	write !,"** read a partial record to test seek=""-1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""+1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="+1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""52""",!!
	use p
	read x#10
	do results(x)
	use p:seek="52"
	read x
	do results(x)
	write !,"** read a partial record, close nodestroy, reopen restored and read rest of record and 19 more to test data and $ZKEY",!!
	use p
	read x#10
	do results(x)
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	use p
	read x
	do results(x)
	for i=1:1:19 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:wrap
	for i=1:1:20 use p read x do results(x)
	; try to seek before the beginning to verify it points to first byte (offset 0)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write record 103 and 104 at the end then seek=""-2"" to beginning of 103",!!
	use p:seek="999"
	; replace first char
	set x1=$extract(x,2,50)
	w "4"_x1
	w "5"_x1
	use p:seek="-2"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-1"" to the beginning of 103, again",!!
	; truncate the last line and seek="-1" to the beginning of 103, again
	use p:truncate
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	; for fixed utf must close with "nodestroy" to do a seek on open
	do dxdy(p,1)
	close p:nodestroy
	; open with a seek to 49
	write !,"** close p:nodestroy to open with a seek to 49 again",!!
	open p:seek="49"
	do dxdy(p,3)
	use p
	read x
	do results(x)
	close p
	; alternately, the first operation can be a read of the first record followed by a use p:seek
	; open with a seek to 49
	write !,"** open, read first record and then seek to 49 again",!!
	open p:(fixed:recordsize=38:ICHSET="UTF-16":OCHSET="UTF-16BE")
	use p:width=19
	read x
	do results(x)
	use p:seek="49"
	read x
	do results(x)
	; do some OPEN testing with SEEK
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-1"" to read same record again",!
	open p:seek="-1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+1"" to skip a record",!
	open p:seek="+1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write "close nodestroy then reopen append:seek=""-1"" to read last record",!
	open p:(append:seek="-1")
	use p
	read x
	do results(x)
	close p

	write "**********************************",!
	write "UTF-8 WITH BOM FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek8fixwithbom with 100 lines showing first and last lines:
	;x=    0 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 1,0
	;x=   99 - ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ $zkey= 100,0
	;x len = 31
	;file size = 4603
	set p="useek8fixwithbom"
	open p:(fixed:recordsize=46)
	use p:width=31
	; randomly read from the beginning of the file to show BOM is read correctly with or without it
	if $random(2) read x
	use $p write !,"** write line 100 at end to test relative SEEK=-1 after a write",!!
	use p:seek="9999999"
	use p:seek="-1"
	read x
	do results(x)
	; write another line at the end so last operation is a write
	set y=$piece(x,"- ",2)
	use p:seek="9999999"
	write " 100 - "_y,!
	use p:seek="-1"
	read x
	do results(x)
	use $p write !,"** write line 101 at end, write line 102 in background with 2 sec delay, then do a read with follow to read 102",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write " 101 - "_y,!
	; write another line in the background and read with follow
	set ^a=8
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being record 49",!!
	use p:seek="45"
	use p:seek="-5"
	use p:seek="+9"
	read x
	; offset will be 50 after read
	do results(x)
	write !,"** read a partial record to test seek=""-1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""+1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="+1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""52""",!!
	use p
	read x#10
	do results(x)
	use p:seek="52"
	read x
	do results(x)
	write !,"** read a partial record, close nodestroy, reopen restored and read rest of record and 19 more to test data and $ZKEY",!!
	use p
	read x#10
	do results(x)
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	use p
	read x
	do results(x)
	for i=1:1:19 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:wrap
	for i=1:1:20 use p read x do results(x)
	; try to seek before the beginning to verify it points to first byte (offset 0)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write lines 103 and 104 at the end then seek=""-2"" to beginning of 103",!!
	use p:seek="9999999"
	; write lines 103 and 104 at the end then seek="-2" to beginning of 103
	write " 103 - "_y,!
	write " 104 - "_y,!
	use p:seek="-2"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-1"" to the beginning of 103, again",!!
	; truncate the last line and seek="-1" to the beginning of 103, again
	use p:truncate
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	; for fixed utf must close with "nodestroy" to do a seek on open
	do dxdy(p,1)
	close p:nodestroy
	; open with a seek to 49
	write !,"** open with a seek to 49 again",!!
	open p:seek="49"
	do dxdy(p,3)
	use p
	read x
	do results(x)
	close p
	; alternately, the first operation can be a read of the first record followed by a use p:seek
	; open with a seek to 49
	write !,"** open, read first record and then seek to 49 again",!!
	open p:(fixed:recordsize=46)
	use p:width=31
	read x
	do results(x)
	use p:seek="49"
	read x
	do results(x)
	; do some OPEN testing with SEEK
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-1"" to read same record again",!
	open p:seek="-1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+1"" to skip a record",!
	open p:seek="+1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write "close nodestroy then reopen append:seek=""-1"" to read last record",!
	open p:(append:seek="-1")
	use p
	read x
	do results(x)
	close p

	write "**********************************",!
	write "UTF-16 WITH BOM FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!

	; beginning contents of useek16fixwithbom with 100 lines showing first and last lines:
	; the first character on each line is different
	;x= ԞՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 1,0
	;x= ցՇՈՉՊՋՌՍՎՏՇՈՉՊՋՌՍՎՏ $zkey= 100,0
	;x len = 19
	;file size = 3802
	set p="useek16fixwithbom"
	open p:(fixed:recordsize=38:ICHSET="UTF-16":OCHSET="UTF-16BE")
	use p:width=19
	; randomly read from the beginning of the file to show BOM is read correctly with or without it
	if $random(2) read x
	use $p write !,"** write line with first char 1 at end to test relative SEEK=-1 after a write",!!
	use p:seek="9999"
	use p:seek="-1"
	read x
	do results(x)
	; write another line at the end so last operation is a write
	use p:seek="9999"
	write $tr(x,"ց","1")
	use p:seek="-1"
	read x
	do results(x)
	use $p write !,"** write line 2 at end, write line 3 in background with 2 sec delay, then do a read with follow to read 3",!!
	use p:seek="9999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write $tr(x,"1","2")
	; write another line in the background and read with follow
	set ^a=9
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being record 49",!!
	use p:seek="45"
	use p:seek="-5"
	use p:seek="+9"
	read x
	; offset will be 50 after read
	do results(x)
	write !,"** read a partial record to test seek=""-1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""+1""",!!
	use p
	read x#10
	do results(x)
	use p:seek="+1"
	read x
	do results(x)
	write !,"** read a partial record to test seek=""52""",!!
	use p
	read x#10
	do results(x)
	use p:seek="52"
	read x
	do results(x)
	write !,"** read a partial record, close nodestroy, reopen restored and read rest of record and 19 more to test data and $ZKEY",!!
	use p
	read x#10
	do results(x)
	do dxdy(p,1)
	close p:nodestroy
	open p
	do dxdy(p,2)
	use p
	read x
	do results(x)
	for i=1:1:19 use p read x do results(x)
	write !,"** close with nodestroy, reopen non-restored and read 20 lines to test data and $ZKEY",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:wrap
	for i=1:1:20 use p read x do results(x)
	; try to seek before the beginning to verify it points to first byte (offset 0)
	write !,"** try to seek before the beginning to verify offset is beginning of file",!!
	use p:seek="-999"
	read x
	do results(x)
	; do a rewind to show same result
	write !,"** do a use p:rewind to verify same result",!!
	use p:rewind
	read x
	do results(x)
	write !,"** write record 103 and 104 at the end then seek=""-2"" to beginning of 103",!!
	use p:seek="999"
	; write records 103 and 104 at the end then seek="-2" to beginning of 103
	; replace first char
	set x1=$extract(x,2,50)
	w "4"_x1
	w "5"_x1
	use p:seek="-2"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-1"" to the beginning of 103, again",!!
	; truncate the last line and seek="-1" to the beginning of 103, again
	use p:truncate
	use p:seek="-1"
	read x
	do results(x)
	write !,"** read with nofollow to get the EOF",!!
	; read with nofollow to get the EOF
	use p:nofollow
	read x
	do results(x)
	; for fixed utf must close with "nodestroy" to do a seek on open
	do dxdy(p,1)
	close p:nodestroy
	; open with a seek to 49
	write !,"** close p:nodestroy to open with a seek to 49 again",!!
	open p:seek="49"
	do dxdy(p,3)
	use p
	read x
	do results(x)
	close p
	; alternately, the first operation can be a read of the first record followed by a use p:seek
	; open with a seek to 49
	write !,"** open, read first record and then seek to 49 again",!!
	open p:(fixed:recordsize=38:ICHSET="UTF-16":OCHSET="UTF-16BE")
	use p:width=19
	read x
	do results(x)
	use p:seek="49"
	read x
	do results(x)
	; do some OPEN testing with SEEK
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-1"" to read same record again",!
	open p:seek="-1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+1"" to skip a record",!
	open p:seek="+1"
	use p
	read x
	do results(x)
	close p:nodestroy
	write "close nodestroy then reopen append:seek=""-1"" to read last record",!
	open p:(append:seek="-1")
	use p
	read x
	do results(x)
	close p
	quit

wait(avalue)
	for  hang 1 quit:$data(^a)&(avalue=^a)
	quit

results(x)
	new d,zk
	set d=$device,zk=$zkey
	use $p
	write "x= ",x," $device= ",d," $zkey= ",zk,!
	quit

dxdy(p,m)
	new %io,dx,dy
	set %io=$io
	use p
	set dx=$x,dy=$y
	use $p
	if 1=m write "Before CLOSE p:NODESTROY",!
	if 2=m write "After OPEN with restored state",!
	if 3=m write "After OPEN with restored state then SEEK",!
	write "$x= ",dx," $y= ",dy,!!
	use %io
	quit

zshowout
	new show
	write !,"zshow ""d"" output for useek16withbom:",!
	zshow "d":show
	write show("D",4),!!
	quit

utest1
	; do a seek on empty output file to show no failure
	set bomlen=$zcmdline
	use $principal:outseek="+"_(47+bomlen)
	; seek to 5th input line
	use $principal:inseek="+"_(188+bomlen)
	; read 3 lines and write to output
	for i=1:1:3 do
	. read x
	. write x,!
	; seek back 5 lines to line 3 on input and read it
	use $principal:inseek="-235"
	read x
	; seek back 2 lines on output and write line just read
	use $principal:outseek="-94"
	write x,!
	quit

utest2
	; show inseek and outseek on principal redirected from a /dev/null or a null file is ignored with no error
	use $principal:inseek="+235"
	use $principal:outseek="+235"
	quit

urewind1
	; do a rewind on empty output file to show no failure
	set bomlen=$zcmdline
	use $principal:rewind
	; seek to 5th input line
	use $principal:inseek="+"_(188+bomlen)
	; read 3 lines and write to output
	for i=1:1:3 do
	. read x
	. write x,!
	; seek back 5 lines to line 3 on input and read it
	use $principal:inseek="-235"
	read x
	; rewind output and write line just read
	use $principal:outrewind
	write x,!
	use $principal:inrewind
	read x
	; write to second line of output
	write x,!
	quit

urewind2
	; show inrewind and outrewind on principal redirected from a /dev/null or a null file is ignored with no error
	use $principal:inrewind
	use $principal:outrewind
	quit

utruncate1
	set bomlen=$zcmdline
	; read 4 lines and write to output
	for i=1:1:4 do
	. read x
	. write x,!
	; seek back 2 lines on output and truncate
	use $principal:(outseek="-94":truncate)
	; rewind input and read and write 2 lines
	use $principal:inrewind
	for i=1:1:2 do
	. read x
	. write x,!
	quit

utruncate2
	; show truncate on principal redirected from a /dev/null or a null file is ignored with no error
	use $principal:truncate
	quit
