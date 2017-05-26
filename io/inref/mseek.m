;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mseek
	; exercise sequential device seek for non-fixed and fixed M modes supporting io/sdseek.csh test
	new x,p
	write "**********************************",!
	write "NON-FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!
	set p="mvariable"
	set $ztrap="goto errorAndCont^errorAndCont"
	write !,"** open a zero length file followed by a use:REWIND to show a WRITE can be done",!
	open p:newversion
	use p:rewind
	write "This output written after a use:REWIND on a zero length file",!
	use p:rewind
	read y
	; in the next 2 lines use inrewind and outrewind to show equivalence with rewind for non-split device
	use p:inrewind
	read z
	use p:outrewind
	read x
	if (x'=y)!(y'=z) write "FAILED - REWIND/INREWIND/OUTREWIND equivalency test for non-split device",!
	do results(x)
	write !,"** open a zero length file with SEEK=10 just to show nothing changes",!
	close p
	open p:(newversion:seek="10")
	write "** also do a use with SEEK=-5 on the zero length file",!
	write "** then do a read to show value of $zkey and $display",!!
	use p:seek="-5"
	read x
	do results(x)
	use p
	; create file with 1000 lines
	for i=1:1:1000 write $justify(i_" - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",59),!
	close p
	; generate OPEN error message for early termination of seek value
	open p:seek="5b"
	; correct open
	open p
	; second character must be a digit
	use p:seek="- 5"
	; seek value too big to convert to LONG
	use p:seek="9999999999999999999999999999999999"
	; generate USE error message for early termination of seek value
	use p:seek="5k"
	; generate USE error message for entering a null string seek value
	use p:seek=""
	; seek to end of file to write another line
	use $p write !,"** write line 1001 at end to test relative SEEK=-60 after a write",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write
	write $justify("1001 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",59),!
	use p:seek="-60"
	read x
	do results(x)
	use $p write !,"** write line 1002 at end, write line 1003 in background with 5 sec delay, then do a read with follow to read 1003",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write $justify("1002 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",59),!
	; write another line in the background and read with follow
	zsystem "(sleep 5; echo ""1003 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"" >> mvariable&)>/dev/null"
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being 1800",!!
	; in the next 2 lines use inseek and outseek to show equivalence with seek for non-split device
	use p:inseek="600"
	use p:outseek="-120"
	use p:seek="+1320"
	read x
	; offset will be 1860 after read
	do results(x)
	; save $x and $y, set each to a test value before close no destroy
	; output $x and $y before close no destroy to verify they are restored after the reopen
	write !,"set values of $x=44 and $y=55 before close with nodestroy:",!!
	set savedx=$x,savedy=$y
	use p
	set $x=44,$y=55
	do dxdy(p)
	use $p
	write "** close with nodestroy, reopen restored and read a line to make sure $ZKEY is correct",!!
	close p:nodestroy
	open p
	write "value of $x and $y after reopen restored:",!!
	use p
	do dxdy(p)
	; restore $x and $y
	set $x=savedx,$y=savedy
	read x
	do results(x)
	; save $x and $y, set each to a test value before close no destroy
	; output $x and $y before close no destroy to verify they are not restored after the reopen
	write !,"set values of $x=44 and $y=55 before close with nodestroy:",!!
	use p
	set $x=44,$y=55
	do dxdy(p)
	use $p
	write "** close with nodestroy, reopen non-restored and read a line to make sure $ZKEY is correct",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:nofix
	write "value of $x and $y after reopen non-restored:",!!
	use p
	do dxdy(p)
	read x
	do results(x)
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
	write !,"** write lines 1004 and 1005 at the end then seek=""-120"" to beginning of 1004",!!
	use p:seek="9999999"
	; write lines 1004 and 1005 at the end then seek="-120" to beginning of 1004
	write $justify("1004 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",59),!
	write $justify("1005 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",59),!
	use p:seek="-120"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-60"" to the beginning of 1004, again",!!
	; truncate the last line and seek="-60" to the beginning of 1004, again
	use p:truncate
	use p:seek="-60"
	read x
	do results(x)
	close p
	write !,"** Open with SEEK to 240",!!
	close p
	open p:seek="240"
	use p
	read x
	; save the $zkey and open again with it's value
	set savezkey=$zkey
	do results(x)
	close p
	write !,"** Open with SEEK to saved value of zkey - ",savezkey,!!
	open p:seek=savezkey
	use p
	read x
	do results(x)
	close p
	; do some OPEN testing with SEEK
	; on open, append is applied first regardless of order, all others are applied as entered
	write !,"** open append:seek=""-360"" to read 5th from last line",!
	open p:(append:seek="-360")
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""-60"" to read same line again",!
	open p:seek="-60"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen seek=""+60"" to skip a line",!
	open p:seek="+60"
	use p
	read x
	do results(x)
	close p:nodestroy
	write !,"** close nodestroy then reopen append:seek=""-60"" to output last line",!
	open p:(append:seek="-60")
	use p
	read x
	do results(x)
	use $p
	write !,"** seek to EOF and read with nofollow to get the EOF",!!
	use p:(seek="9999999":nofollow)
	; read with nofollow to get the EOF
	read x
	do results(x)
	close p

	write "**********************************",!
	write "FIXED SEEK FOLLOW AND NOFOLLOW",!
	write "**********************************",!
	set p="mfixed"
	set $ztrap="goto errorAndCont^errorAndCont"
	open p:(newversion:fixed:recordsize=60)
	use p
	; create file with 1000 records of length 60 bytes each
	; number from 0 to correspond to record offset
	for i=0:1:999 write $justify(i_" - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",60)
	close p
	; seek to end of file to write another line
	use $p write !,"** write line 1000 at end to test relative SEEK=-1 after a write",!!
	open p:(fixed:recordsize=60)
	use p:seek="9999999"
	; write another record at the end so last operation is a write
	write $justify("1000 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",60)
	use p:seek="-1"
	read x
	do results(x)
	use $p write !,"** write line 1001 at end, write line 1002 in background with 5 sec delay, then do a read with follow to read 1002",!!
	use p:seek="9999999"
	; write another line at the end so last operation is a write and we will read with follow at EOF
	write $justify("1001 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",60)
	; write another line in the background and read with follow
	zsystem "(sleep 5; echo "" 1002 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"" | strip_cr >> mfixed&)>/dev/null"
	use p:follow
	read x
	do results(x)
	; do all 3 types of seeks in a row to make sure we land in the right place
	write !,"** do all 3 seek types in a row with the final offset to read being 780",!!
	use p:seek="500"
	use p:seek="-120"
	use p:seek="+400"
	read x
	; offset will be 781 after read
	do results(x)
	; do a partial read of a record to show record offset
	write !,"** read x#20 to show record offset in bytes in record 781",!!
	use p
	read x#20
	do results(x)
	write !,"** close with nodestroy, reopen restored and read the rest of the record x#40 to make sure $ZKEY is correct",!!
	do dxdy(p)
	close p:nodestroy
	open p
	do dxdy(p)
	use p
	read x#40
	do results(x)
	write !,"** close with nodestroy, reopen non-restored and read the record to make sure $ZKEY is correct",!!
	close p:nodestroy
	; add a deviceparameter that doesn't change anything, but makes reopen start at the beginning of the file
	open p:fixed
	use p
	read x
	do results(x)
	write !,"** seek to the beginning of record 781 and read x#20 again",!!
	use p:seek="781"
	read x#20
	do results(x)
	; seek to the beginning of record 781 and read record
	write !,"** seek to beginning of record 781 and read the entire record",!!
	use p:seek="781"
	read x
	do results(x)
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
	write !,"** write lines 1003 and 1004 at the end then seek=""-2"" to beginning of 1003",!!
	use p:seek="9999999"
	; write lines 1003 and 1004 at the end then seek="-2" to beginning of 1003
	write $justify("1003 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",60)
	write $justify("1004 - abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz",60)
	use p:seek="-2"
	read x
	do results(x)
	write !,"** truncate the last line and seek=""-1"" to the beginning of 1003, again",!!
	; truncate the last line and seek="-1" to the beginning of 1004, again
	use p:truncate
	use p:seek="-1"
	read x
	do results(x)
	close p
	write !,"** Open with recordsize set to 60 and SEEK to record offset 5",!!
	open p:(fixed:recordsize=60:seek="5")
	use p
	read x
	do results(x)
	close p
	write !,"** Open with default recordsize, set width to 60 in USE and seek to offset 5",!!
	open p:fixed
	use p:(width=60:seek="5")
	read x
	; save the $zkey and open again with it's value
	set savezkey=$piece($zkey,",",1)
	do results(x)
	close p
	write !,"** Open with SEEK to saved value of zkey - ",savezkey,!!
	open p:(fixed:recordsize=60:seek=savezkey)
	use p
	read x
	do results(x)

	close p
	; do some OPEN testing with SEEK
	; on open, append is applied first regardless of order, all others are applied as entered
	write !,"** open fixed:recordsize=60:append:seek=""-6"" to read 5th from last line",!
	open p:(fixed:recordsize=60:append:seek="-6")
	use p
	read x
	do results(x)
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
	write !,"** close nodestroy then reopen append:seek=""-1"" to output last line",!
	open p:(append:seek="-1")
	use p
	read x
	do results(x)
	use $p

	write !,"** seek to EOF and read with nofollow to get the EOF",!!
	use p:(seek="9999999":nofollow)
	; read with nofollow to get the EOF
	read x
	do results(x)
	close p
	quit

results(x)
	new d,zk
	set d=$device,zk=$zkey
	use $p
	write "x= ",x," $device= ",d," $zkey= ",zk,!
	quit

dxdy(p)
	new %io,dx,dy
	set %io=$io
	use p
	set dx=$x,dy=$y
	use $p
	write "$x= ",dx," $y= ",dy,!!
	use %io
	quit

test1
	; do a seek on empty output file to show no failure
	use $principal:outseek="+60"
	; seek to 5th input line
	use $principal:inseek="+240"
	; read 3 lines and write to output
	for i=1:1:3 do
	. read x
	. write x,!
	; seek back 5 lines to line 3 on input and read it
	use $principal:inseek="-300"
	read x
	; seek back 2 lines on output and write line just read
	use $principal:outseek="-120"
	write x,!
        quit

test2
	; show inseek and outseek on principal redirected from a /dev/null or a null file is ignored with no error
	use $principal:inseek="+240"
	use $principal:outseek="+240"
	quit

rewind1
	; do a rewind on empty output file to show no failure
	use $principal:rewind
	; seek to 5th input line
	use $principal:inseek="+240"
	; read 3 lines and write to output
	for i=1:1:3 do
	. read x
	. write x,!
	; seek back 5 lines to line 3 on input and read it
	use $principal:inseek="-300"
	read x
	; rewind output and write line just read
	use $principal:outrewind
	write x,!
	; rewind input and read line
	use $principal:inrewind
	read x
	; write to second line of output
	write x,!
        quit

rewind2
	; show inrewind and outrewind on principal redirected from a /dev/null or a null file is ignored with no error
	use $principal:inrewind
	use $principal:outrewind
	quit

truncate1
	; do a truncate on empty output file to show no failure
	use $principal:truncate
	; seek to 5th input line
	use $principal:inseek="+240"
	; read 4 lines and write to output
	for i=1:1:4 do
	. read x
	. write x,!
	; seek back 2 lines on output side and truncate it
	use $principal:(outseek="-120":truncate)
	; rewind input and read 2 lines and write to output
	use $principal:inrewind
	for i=1:1:2 do
	. read x
	. write x,!
        quit

truncate2
	; show truncate on $principal redirected to a /dev/null or a null file is ignored with no error
	use $principal:truncate
	quit

