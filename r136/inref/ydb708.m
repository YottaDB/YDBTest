;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Helper M program used by r136/u_inref/ydb708.csh
;
ydb708	;
	do test1
	do test2
	do test3
	do test4
	quit

test1	;
	write "# Test that PIPE OPEN COMMAND device parameter 128KiB long does not error if not a string literal",!
	set xstr=""
	set max=12925	; this is the right number where "max+1" would cause $zlength(xstr) to be more than 128KiB
			; and cause PIPE reads to not work anymore. Not sure what the limitation is (I suspect it is a
			; PIPE device READ issue and not a OPEN command issue with COMMAND device parameter which is what
			; the focus of this test is on). In any case, 128KiB seems a really high limit that I consider
			; this as a good enough test.
	for i=1:1:max set ystr="echo "_i_";" set xstr=xstr_ystr
	write "Length of COMMAND device parameter for PIPE OPEN command = ",$zlength(xstr),!
	open "pipe":(shell="/bin/sh":command=xstr:readonly:stream:nowrap)::"pipe"
	use "pipe":(width=65535:nowrap)
	for i=1:1:max read test1(i)
	close "pipe"
	for i=1:1:max write:test1(i)'=i "FAIL from "_$text(+0)," : i = ",i," : test1(",i,")=",test1(i),!
	write:i=(max) "PASS from "_$text(+0),!
	quit

test2	;
	write "# Test that PIPE OPEN COMMAND device parameter can be 255 bytes long if a string literal",!
	open "pipe":(shell="/bin/sh":command="echo 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890":readonly)::"pipe"
	use "pipe":(width=65535:nowrap)
	read test2
	close "pipe"
	zwrite test2
	quit

test3	;
	write "# Test that PIPE OPEN COMMAND device parameter cannot be 256 bytes long or higher if a string literal",!
	set xstr="open ""pipe"":(shell=""/bin/sh"":command=""echo "
	set zstr=""":readonly)::""pipe"""
	set ystr=""
	for i=8:1:16 do
	. write "## Trying string literal length = ",2**i," bytes. Expect DEVPARTOOBIG error. No SIG-11, assert failure etc.",!
	. set ystr=""
	. for j=1:1:2**i set ystr=ystr_(i#10)
	. do test3xecute
	quit

test4	;
	write "# Test that PIPE OPEN COMMAND device parameter > 128KiB and < 1MiB long does not error if not a string literal",!
	for i=1:1:19 do
	. write "## Testing COMMAND device parameter non-literal string length = ",2**i," bytes. Expect no error, SIG-11 or assert failure",!
	. set $zpiece(str,"X",2**i)=""
	. open "pipe":(shell="/bin/sh":command="echo "_str:readonly)::"pipe"
	. close "pipe"
	quit

test3xecute	;
	set $etrap="zwrite $zstatus set $ecode="""""
	xecute xstr_ystr_zstr
	quit

