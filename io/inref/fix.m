;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fix
	write !,"Writing 10 lines each 80 chars in length and expect to output same but preceeded by line numbers",!!
	set p="test"
	open p:(comm="cat -u":fixed:recordsize=80)::"pipe"
	zshow "d"
	for i=1:1:10 do
	. use p
	. write "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	. for  read x(i):0 quit:x(i)'=""
	. use $p
	. write i," - ",x(i),!
	use p
	write /eof
	for  read x:0 quit:$zeof
	set a=$zeof
 	use $p
	write "zeof = ",a,!
	use $p
  	close p

	write !,"Writing 10 lines each but separate each write into 2 with 40 chars each",!
	write " and expect to output 80 chars per line",!,!
	set p="test"
	open p:(comm="cat -u":fixed:recordsize=80)::"pipe"
	zshow "d"
	for i=1:1:10 do
	. use p
	. write "1234567890123456789012345678901234567890"
	. write "1234567890123456789012345678901234567890"
	. for  read x(i):0 quit:x(i)'=""
	. use $p
	. write i," - ",x(i),!
	use $p
  	close p

	write !,"Writing 10 lines each with each one containing 83 characters",!
	write " and expect to output 80 chars on one line followed by 3 on the next line",!,!
	;we have to do 2 reads for each write or the pipe will fill up
	set p="test"
	open p:(comm="cat -u":fixed:recordsize=80)::"pipe"
	zshow "d"
	for i=1:1:10 do
	. use p
	. write "12345678901234567890123456789012345678901234567890123456789012345678901234567890abc"
	. for  read x(i):0 quit:x(i)'=""
	. for  read y(i):0 quit:y(i)'=""
	. use $p
	. write i," - ",x(i),!
	. write i," - ",y(i),!
	use $p
  	close p

	write !,"This test has a recordsize of 60, but is not fixed format",!
	write "Writing 10 lines each with each one containing 63 characters",!
	write " and expect to output 60 chars on one line followed by a newline then by 3 on the next line",!,!
	;we have to do 3 reads for each write or the pipe will fill up with more iterations
	set p="test"
	open p:(comm="cat -u":recordsize=60)::"pipe"
	zshow "d"
	for i=1:1:10 do
	. use p
	. write "123456789012345678901234567890123456789012345678901234567890abc",!
	. for  read x(i):0 quit:x(i)'=""
	. read y(i)
	. for  read z(i):0 quit:z(i)'=""
	. use $p
	. write i," - ",x(i),!
	. write i," - ",y(i),!
	. write i," - ",z(i),!
	use $p
  	close p

	write !,"Writing 10 lines each with each one containing 13 characters and with nowrap",!
	write " and expect to output the first 10 chars on each line",!,!
	set p="test"
	open p:(comm="cat -u":fixed:recordsize=10:nowrap)::"pipe"
	zshow "d"
	for i=1:1:10 do
	. use p
	. write "1234567890abc"
	. for  read x(i):0 quit:x(i)'=""
	. use $p
	. write i," - ",x(i),!
	; add a short write and a write /eof followed by a read to verify operation
	use $p
	write !,"Write a shorter line of 8 characters to verify that a write /eof",!
	write "will flush the output in fixed mode and that the 8 characters plus 2 pad characters will be read",!
	use p
	write "12345678"
	set xpos(1)=$x
	write /eof
	set xpos(2)=$x
	read x(11)
	; do an extra read to verify that the command received an end of file and terminated
	read x(12)
	set z=$zeof
	set d=$device
	use $p
	write "$x after writing 12345678 = ",xpos(1),!
	write "$x after write /eof = ",xpos(2),!
	write "Short read after write /eof: ",x(11),!
	write "String length plus pad characters = ",$length(x(11)),!
	write "Show end of file seen after an extra read",!
	write "zeof= ",z,!
	write "device= ",d,!
	write "Show pipe device still open after write /eof",!
	zshow "d"
  	close p
	quit
