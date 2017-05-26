c002843 ;
	; C9H04-002843 READ * returns incorrect values for ch > 127 and < 256 in SD and SOCKET devices
	; SD was only wrong for UNIX
	;
	set dev="TestFile.dat"
	open dev:new
	use dev
	for i=0:1:255 write $c(i)
	close dev
	open dev:readonly
	use dev:rewind
	for i=0:1:255 read *a(i)
	close dev
	use $p
	set fail=0
	for i=0:1:255 if a(i)'=i write "Read failed : Expected=",i," : Actual=",a(i),!  set fail=1
	if fail=0 write "Test PASSED",!
	else      write "Test FAILED",!
	quit
