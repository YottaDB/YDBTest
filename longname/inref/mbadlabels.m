mbadlabels;	;
	new unix,xstr
	SET $ZTRAP="GOTO errcont^errcont" 
	write !,$t(+0)," test Started",!,!
	;
	set fnbase="GTMBadLabelTest"
	;
	set labname(1)="%12345678%9012345678901A"
	set labname(2)="%ABCDEFG%HIJKLM"
	set labname(3)="%ABCDEFG%123456"
	set labname(4)="%%"
	set labname(5)="123456789012345678901A"
	set unix=$zversion'["VMS"
	if unix   set xstr="set labname(6)=""12345678901234567890""_$ZChar(0,1,2,3)"
	if 'unix  set xstr="set labname(6)=""12345678901234567890""_$Char(0,1,2,3)"
	xecute xstr
	if unix   set xstr="set labname(7)=""123456789012345678901234567""_$ZChar(127,128,254,255)"
	if 'unix  set xstr="set labname(7)=""123456789012345678901234567""_$Char(127,128,254,255)"
	xecute xstr
	if unix   set xstr="set labname(8)=$ZChar(127,128,254,255)_""123456789012345678901234567"""
	if 'unix  set xstr="set labname(8)=$Char(127,128,254,255)_""123456789012345678901234567"""
	xecute xstr
	if unix   set xstr="set labname(9)="""" for cnt=1:1:31 set labname(9)=labname(9)_$ZChar(127+(cnt*4))"
	if 'unix  set xstr="set labname(9)="""" for cnt=1:1:31 set labname(9)=labname(9)_$Char(127+(cnt*4))"
	xecute xstr
	set max=$order(labname(""),-1)
	;
	for testno=1:1:max do
	. set fn=fnbase_testno_".m"
	. open fn:(NewVersion)
	. use fn
	. write labname(testno),";       ",!
	. write "       write ""I am in a bad label"",!",!  
	. write "       set tstno=testno",!
	. write "       set zposresult(tstno)=$zpos",!
	. write "       quit",!
	. close fn
	. use $PRINCIPAL
	. set prg=labname(testno)_"^"_fnbase_testno
	. write "do ",prg,!
	. set xstr="do "_prg
	. xecute xstr
	. ;
	;
	zwr
	write !,$t(+0)," test ended successfully",!
	quit
