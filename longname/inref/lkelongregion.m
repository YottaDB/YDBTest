lkelongregion	; test locks with long regions
	; the gde file is created using gde_long2.com
	; lock a global in each region
	set separator="#####################################################################"
	set unix=$ZVERSION'["VMS"
	if unix set ^pid2=$JOB
	else  set ^pid2=$$FUNC^%DH($JOB,8)
	write "PID=",^pid2,!
	write separator,!,"Lock some globals...",!
	set name="A"
	lock ^A
	for i=2:1:31 do
	. set num=i#10
	. set name=name_num
	. set gbl="^"_name
	. lock +@gbl
	if unix do
	. set cmdshowall="$LKE show -all"
	else  do
	. set cmdshowall="LKE show /all"
	write separator,!,cmdshowall,!
	zsystem cmdshowall
	for reg="A","A2345678","A234567890123456","A23456789012345678901234567890","A234567890123456789012345678901" do
	. if unix do
	.. set cmdshow="$LKE show -reg="_reg
	. else  do
	.. set cmdshow="LKE show /reg="_reg
	. write separator,!,cmdshow,!
	. zsystem cmdshow
	write separator,!,"LKE clear some of the locks...",!
	for reg="A2345678","A234567890123456","A234567890123456789012345678901","BNONEXISTENTREGION","BNONEXISTENTREGIONTHISTIMEAVERYVERYLOGNREGION6789012345678901234567890" do
	. if unix do
	.. set cmdclear="$LKE clear -nointeractive -reg="_reg
	. else  do
	.. set cmdclear="LKE clear /nointeractive /reg="_reg
	. write cmdclear,!
	. zsystem cmdclear
	write separator,!,cmdshowall,!
	zsystem cmdshowall
	write separator,!,"clear all locks...",!
	if unix do
	. set cmdclearall="$LKE clear -all -nointeractive"
	else  do
	. set cmdclearall="LKE clear /all /nointeractive"
	write separator,!,cmdclearall,!
	zsystem cmdclearall
	write separator,!,cmdshowall,!
	zsystem cmdshowall
	quit
