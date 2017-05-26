;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper routine for io/gtm8369 to test APPEND for files greater than 4G
create  ;
	; create a 5G file with 1024 0's on each line
	set z=""
        for x=1:1:128 s z=$g(z)_"00000000"
        set io="file.big"
        open io:(newversion:chset="M")
        use io
        for x=1:1:5000000 w z,!
	set zk=$zkey
        close io
	write "Size of created file.big is "_zk,!
        quit

append
	; try open with append, first preceded with a newline then without a newline
        set io="file.big"
        open io:append
        use io
	set zk0=$zkey
	use $P
	write "Initial size of file.big in append test is "_zk0,!
	use io
	; precede with newline
        write !
	set zk1=$zkey
        write "Output when preceded by newline"_",$ZKEY = ",zk1,!
        close io
        open io:append
        use io
	set zk2=$zkey
        write "Output when not preceded by newline"_",$ZKEY = ",zk2,!
	; output lines based on the saved values of $ZKEY which is the byte offset at the beginning of each line
	use io:seek=zk1
	read line1
	use io:seek=zk2
	read line2
	; use $ZKEY to do a relative SEEK and reread this line
	set zk3=$ZKEY
	use io:seek=zk2-zk3
	read line3
	use $P
	write line1,!
	write line2,!
	write "* rewrite the same line after doing a relative seek backwards *",!
	write line3,!
	; for a test of truncate on a large file, write another line, back up and truncate it
	write "The file size prior to the truncate test is ",zk3,!
	use io
	write "this line will get truncated",!
	set zk4=$ZKEY
	use $P
	write "The file size after the line to truncate has been added is ",zk4,!
	; back up and read/output to show the line is in the file
	use io:seek=zk3-zk4
	read line4
	use $P
	write line4,!
	; back up and truncate the line and output $ZKEY which will be the same as zk3
	use io:(seek=zk3-zk4:truncate)
	set zk5=$ZKEY
	close io
	; try an open with append and truncate to show it is a no-op as it was in V61000 for files < 4G.
        open io:(append:truncate)
        use io
	set zk6=$ZKEY
        close io
	write "The size of the file after truncating a line is ",zk5,!
	write "The final size of the file after append:truncate is ",zk6,!
        quit
