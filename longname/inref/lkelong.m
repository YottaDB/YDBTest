lkelong;  Test locks on local and global names of various length (  ~ 31)
	; also test lke clear
	set separator="#####################################################################"
	SET $ZT="set $ZT="""" g ERROR"
	new i
	kill ^pid1
	;
	write separator,!
	set unix=$zv'["VMS"
	if unix set ^pid1=$JOB
	else  set ^pid1=$$FUNC^%DH($JOB,8)
	write "PID=",^pid1,!
	set maxlen=$ztrnlnm("maxlen")
	set num=""
	if unix do
	. set cmdshowall="$LKE show -all"
	. set cmdshowalldefault="$LKE show -all -region=DEFAULT"
	else  do
	. set cmdshowall="$LKE show /all"
	. set cmdshowalldefault="$LKE show /all /region=$DEFAULT"
	;
	l (^a,^b,^ab34567890123456789012345678901,ab34567890123456789012345678901)
	for i=4:1:maxlen do
	. set n=i#10
	. set num=num_n
	. set lvar="loc"_num
	. set gvar="^gbl"_num
	. l:(i#2) +(@lvar,@gvar)
	. Zallocate:'(i#2) (@lvar,@gvar):60
	;
	; try to lock the variables that are already locked
	l +(@lvar,@gvar)
	;try to lock the variables that have more than maxlen characters
	;set num=num_(maxlen+1)
	set lvarm="loc"_num_"wowthisisonelongvariablehere"
	set gvarm="^gbl"_num_"wowthisisonelongvariablehere"
	write "Try to lock ",lvarm," and ",gvarm,!
	l +(@lvarm,@gvarm)
	; show all the locks
	write !,"Show all the locks",!
	write separator,!
	write cmdshowall,! zsystem cmdshowall
	write "zshow L",!
	zshow "L"
	; show the specified locks
	write separator,!
	write "Show locks ^A2345678 ",lvar," and ",gvar,!
	if unix do
	. set cmd0="$LKE show -lock=^A2345678 -region=A2345678"
	. set cmd1="$LKE show -lock="_lvar_" -region=DEFAULT"
	. set cmd2="$LKE show -lock="_gvar_" -region=DEFAULT"
	else  do
	. set cmd0="$LKE show /lock=""^A2345678"" /region=A2345678"
	. set cmd1="$LKE show /lock="""_lvar_""" /region=$DEFAULT"
	. set cmd2="$LKE show /lock="""_gvar_""" /region=$DEFAULT"
	write cmd0,! zsystem cmd0
	write cmd1,! zsystem cmd1
	write cmd2,! zsystem cmd2
	write separator,!
	write "ZSHOW L",!
	ZSHOW "L":@gvar
	zwrite @gvar
	;
	write separator,!
	; clear the specified locks
	write "Clear locks ^a,^b,",lvar,",",gvar," and ^xxx",!
	if unix do
	.  set cmd1="$LKE clear -nointeractive -lock=^a"
	.  set cmd2="$LKE clear -nointeractive -lock=^b -region=DEFAULT"
	.  set cmd3="$LKE clear -nointeractive -lock="_lvar_" -region=DEFAULT"
	.  set cmd4="$LKE clear -nointeractive -lock="_gvar_" -region=DEFAULT"
	.  set cmd5="$LKE clear -nointeractive -lock=^xxx -region=DEFAULT"
	else  do
	.  set cmd1="$LKE clear /nointeractive /lock=""^a"""
	.  set cmd2="$LKE clear /nointeractive /lock=""^b"" /region=$DEFAULT"
	.  set cmd3="$LKE clear /nointeractive /lock="""_lvar_""" /region=$DEFAULT"
	.  set cmd4="$LKE clear /nointeractive /lock="""_gvar_""" /region=$DEFAULT"
	.  set cmd5="$LKE clear /nointeractive /lock=""^xxx"" /region=$DEFAULT"
	write cmd1,! zsystem cmd1
	write cmd2,! zsystem cmd2
	write cmd3,! zsystem cmd3
	write cmd4,! zsystem cmd4
	write cmd4,! zsystem cmd4
	write cmd5,! zsystem cmd5
	;
	write separator,!
	; show all the locks again
	write "show all the locks again",!
	write cmdshowalldefault,!
	zsystem cmdshowalldefault
	write "zshow L",!
	zshow "L":@gvar
	zwrite @gvar
	;
	write separator,!
	write "release locks one by one",!
	set num=""
	for i=4:3:maxlen do
	. set n=i#10
	. set num=num_n
	. set lvar="loc"_num
	. set gvar="^gbl"_num
	. write "---- ",lvar," ",gvar," ----",!
	. l:(i#2) -(@lvar,@gvar)
	. Zdeallocate:'(i#2) (@lvar,@gvar)
	. zshow "L"
	zshow "L":@gvar
	zwrite @gvar
	write separator,!
	; clear all the locks
	write "clear all the locks",!
	if unix do
	. set cmd1="$LKE clear -nointeractive -all"
	else  do
	. set cmd1="$LKE clear /nointeractive /all"
	write separator,!
	write cmd1,! zsystem cmd1
	write separator,!
	write cmdshowalldefault,! zsystem cmdshowalldefault
	write "zshow L",!
	zshow "L":@(gvar_"X")
	if ""'=$GET(@(gvar_"X")) write "TEST-E-ERROR did not expect to see any locks at this point",!
	write separator,!
	quit
ERROR	;
	ZSHOW "*"
	quit
