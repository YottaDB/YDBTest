mbadvarname;	;
	new unix,xstr
	SET $ZTRAP="GOTO errcont^errcont" 
	write !,$t(+0)," test Started",!,!
	;
	set fnbase="GTMBadVariableNameTest"
	;
	set varname(1)="%12345678%9012345678901A"
	set varname(2)="%ABCDEFG%HIJKLM"
	set varname(3)="%ABCDEFG%123456"
	set varname(4)="%%"
	set varname(5)="123456789012345678901A"
	set unix=$zversion'["VMS"
	if unix   set xstr="set varname(6)=""12345678901234567890""_$ZChar(0,1,2,3)"
	if 'unix  set xstr="set varname(6)=""12345678901234567890""_$Char(0,1,2,3)"
	xecute xstr
	if unix   set xstr="set varname(7)=""123456789012345678901234567""_$ZChar(127,128,254,255)"
	if 'unix  set xstr="set varname(7)=""123456789012345678901234567""_$Char(127,128,254,255)"
	xecute xstr
	if unix   set xstr="set varname(8)=$ZChar(127,128,254,255)_""123456789012345678901234567"""
	if 'unix  set xstr="set varname(8)=$Char(127,128,254,255)_""123456789012345678901234567"""
	xecute xstr
	if unix   set xstr="set varname(9)="""" for cnt=1:1:31 set varname(9)=varname(9)_$ZChar(127+(cnt*4))"
	if 'unix  set xstr="set varname(9)="""" for cnt=1:1:31 set varname(9)=varname(9)_$Char(127+(cnt*4))"
	xecute xstr
	set max=$order(varname(""),-1)
	;
	for testno=1:1:max do
	. set fn=fnbase_testno_".m"
	. open fn:(NewVersion:OCHSET="M")
	. use fn
	. write "badbarname;       ",!
	. write "       write ""I am in a bad varname"",!",!  
	. write "       set tstno=testno",!
	. write "       set ",varname(testno),"=1",!
	. write "       quit",!
	. close fn
	. use $PRINCIPAL
	. set prg="badvarname^"_fnbase_testno
	. write "do ",prg,!
	. do @prg
	. ;
	;
	zwr
	write !,$t(+0)," test ended successfully",!
	quit
