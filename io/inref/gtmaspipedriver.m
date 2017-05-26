;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtmaspipedriver
	; The purpose of this test is to demonstrate the use of a GTM process started by a PIPE device as a subprocess
	; and the subprocess's interaction with the parent.  The first test shows that the subprocess can detect that
	; the parent has closed the READ/WRITE PIPE by testing for $ZEOF being true after a timed READ.  This should
	; be done even if the parent is not doing any WRITEs to the subprocess over the PIPE.  This might be the
	; case,for instance, where the subprocess only sends status via WRITEs to the parent.  The subprocess should
	; still do timed READs from the PIPE to detect that the parent has CLOSEd the PIPE and the subprocess should
	; exit.  This requires the parent OPEN the PIPE in READ/WRITE mode.
	;
	; In the first test the parent is WRITEing 5 lines and READing back from the PIPE device.  The subprocess being
	; passed a 0 as the "type" will detect the ZEOF after reading 5 lines, write the "normal exit with zeof" message
	; to the file passed in "fname" and quit.
	;
	; In the second test the parent is again WRITEing 5 lines and READing back from the PIPE device.  The
	; subprocess being passed a 1 as the "type" will ignore the ZEOF after reading 5 lines, and attempt to write
	; to the PIPE device which is closed until a "Broken pipe" error is generated which is caught by the etrap,
	; goes to ERR and outputs information to the file passed in "fname" and quits.  This enables the parent to
	; successfully complete the CLOSE of the subprocess.  This is not the preferred interface defined above earlier,
	; but is shown to demonstrate the "Broken pipe" error on WRITE to a closed PIPE device.

	set p="pp"
	; test when the pipe subprocess "gtmaspipeproc" reads the EOF and quits
	do readloop(p,"gtmaspipeproc1.outx",0)
	; test when the pipe subprocess "gtmaspipeproc" tries to write back to the pipe after it is closed
	; this generates a SYSTEM-E-ENO32 Broken pipe error which is caught and the subprocess quits
	do readloop(p,"gtmaspipeproc2.outx",1)
	quit

readloop(p,fname,type)
	set openparm="p:(comm=""$gtm_exe/mumps -r gtmaspipeproc^gtmaspipedriver "_type_" "_fname_""")::""pipe"""
	open @openparm
	; send 5 inputs and read them from the pipe then close the pipe device
	for i=1:1:5 do
	. use p
	. write "iteration = ",i,!
	. read x
	. use $p w x,!
	close p:timeout=5
	; $zclose should be 0 if close of subprocess succeeded
	write "$zclose = ",$zclose,!
	set findfile=$zsearch(fname)
	if $length(findfile) do
	. write !,"Status from:"_fname,!
	. open fname:readonly
	. for  use fname read x quit:$zeof  use $p write x,!
	use $p
	write !
	quit

gtmaspipeproc
	set z=$piece($zcmdline," ",1)
	set info=$piece($zcmdline," ",2)
	set $etrap="goto ERR"
	for i=1:1:10 quit:$zeof  do
	. read x:1
	. if ($test&'$zeof) write "received: ",x,!
	; if trying to generate the Broken pipe keep writing to the pipe in a loop for slow platforms to actually close
	; the write side of the pipe
	if z  for i=1:1:30 do
	. write "force error",!
	. hang 1
	set zeof=$zeof
	open info:newversion
	use info
	write "normal exit with zeof ="_zeof,!
	close info
	quit

ERR
	set k=$zeof
	open info:newversion
	use info
	write "ERR:",!
	zshow "d"
	write "$zstatus = ",$zstatus,!
	write "$zeof = ",k,!
	zgoto $estack-1
	quit
