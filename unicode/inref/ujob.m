ujob;
unijob3(arg)
	; save the pid
	do savepid^unicodeJob(arg)	
	SET $ZT="g ERROR^ujob"
	lock ^parlock($j)
	write "unijob3:Arg=",arg,!
	set ^utf8("unijob3","ｘｙｚ｛｜｝～")="There will be an error but no error file created"
	set newvar=undefvar("ｘｙｚ｛｜｝～")
	quit
unijob4(arg)
	; save the pid
	do savepid^unicodeJob(arg)	
	SET $ZT="g ERROR^ujob"
	lock ^parlock($j)
	write "unijob4:Arg=",arg,!
	set ^utf8("unijob4","豈羅爛來祿屢讀數")="There will be an undef error, and will be seen in mje file"
	set newvar=undefvar("豈羅爛來祿屢讀數")
	quit
unijob5(arg)
	; save the pid
	do savepid^unicodeJob(arg)	
	SET $ZT="g ERROR^ujob"
	lock ^parlock($j)
	write "unijob5:Arg=",arg,!
	set ^utf8("unijob5","兩驪練殮領遼戮李")="Will do a read"
	read unicode:100
	write "unicode string:length=",$zlength(unicode),":str = ",unicode,!
	set ^utf8("unijob5","兩驪練殮領遼戮李")=unicode
	if unicode'="αβγ我ＡＢＧ玻璃而傷"  write "TEST-E-Failed to read by job ID=",$j,!
	quit
ERROR   ;	
	SET $ZT=""
        write "$zstatus=",$zstatus,!
        write "$zgbldir=",$zgbldir,!
	quit
