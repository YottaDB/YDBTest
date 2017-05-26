dollarx
	; write a large line and then read it back in a 50 char chunks at a time showing $X after each read
	write !,"mode = ",$zchset,!
	write !,"DISK TEST",!!
	set a="dfile.out"
	open a:newfile
	use a
	if "M"=$zchset set string=":23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
	; if not M mode then add a multi-byte char at the end to verify $X in this case
	if "M"'=$zchset set string=":2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678"_$CHAR(1351)
	for i=0:1:9 write i,string
	use $p		
	use a:(width=100:nowrap:rewind)
	for i=0:1:9 do
	. read in(i)
	. set x(i)=$X
	use $p
	for i=0:1:9 write in(i)," $X = ",x(i),!
	close a
	; now do the same for a fifo
	write !,"FIFO TEST",!!
	set fif="fifo1"
	open fif:(fifo:newversion)
	zsystem "cat ./dfile.out > fifo1"
	use fif:(width=100:nowrap)
	for i=0:1:9 do
	. read in2(i)
	. set x2(i)=$X
	use $p
	for i=0:1:9 write in2(i)," $X = ",x2(i),!
	close a
	; now do the same for a pipe
	write !,"PIPE TEST",!!
	set p="pipe1"
	open p:(command="cat ./dfile.out":readonly)::"pipe"
	use p:(width=100:nowrap)
	for i=0:1:9 do
	. read in3(i)
	. set x3(i)=$X
	use $p
	for i=0:1:9 write in3(i)," $X = ",x3(i),!
	close a
	quit
