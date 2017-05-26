;	Master M routine which sets values to vars & then calls other M-routines
paramchk;
;	check for 8char label all possible combinations.Even check 32 parameter limit
	set valuetomylabellists=10
	set mylabellistsvalue=20
	set longvaluetomylabel=30
	set checklabelvaluelong=40
	set listschecklabelvalue=50
	set valueforchecklabellongonethatis=100
	set zigamamesum=60 ;the value  is the sum of first three variables to check inside the routine later
	set ^iamaglobalchar=555
	set ^knowmeglobally=231
	set ^yeahcheckmeglobally=425
	set ^getmevalue=1211 ;the value  is the sum of first three variables to check inside the routine later
	set ^needacommonglobal=432
;
	write "Actual List is 4 Formal List is 4",!
	do MYLABEL^lists(valuetomylabellists,mylabellistsvalue,longvaluetomylabel,zigamamesum)
;
	do MYLABEL^lists(^iamaglobalchar,^knowmeglobally,^yeahcheckmeglobally,^getmevalue) ;this is for globals check
;
	write "Actual list is 2 Formal list is 2",!
	do CHKLABEL^lists(longvaluetomylabel,checklabelvaluelong)
;
	write "Actual list is 1 Formal list is 2,should not give error as no usage of 2ndvar",!
	do LABELNEW^lists(longvaluetomylabel)
	do LABELNEW^lists(^needacommonglobal) ; this is for globals check
;
	write "Actual list is 32 Formal list is 32",! ;here we give actual values just to check them too
	do CHARLAB8^lists(1,2,3,4,5,6,7,8,9,^needacommonglobal,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,longvaluetomylabel)
;
;	Now go in for long labels! check for >8char label all possible combinations.Even check 32 parameter limit.
;	behavior should be same!!
	set valueforiamlonglabellength=10
	set givemevaluetoalabelsay30=20
	set amilongfortoolongsay30value=30
	set nowthisisenoughtosetlong=100
	set ^pleasesetlongglobalshere=561
	set ^areyoulongenough=145
	set ^summmeglobalvariable=706
;
	write "Actual List is 3 Formal list is 3",!
	do IAMLONGLABELLENGTHTOOLONGSAY30^lists(valueforiamlonglabellength,givemevaluetoalabelsay30,amilongfortoolongsay30value)
;
	do IAMLONGLABELLENGTHTOOLONGSAY30^lists(^pleasesetlongglobalshere,^areyoulongenough,^summmeglobalvariable) ;this is for globals check
;
	write "Actual List is 32 Formal list is 32",!
	do LONGLONGLABELLONGLONGLABELLONGM^lists(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,nowthisisenoughtosetlong,21,22,23,24,25,26,27,28,29,30,31,32)
;
	write "Actual List is 2 Formal list is 3,extra var simply newed no error",!
	do CANIGOALENGTHTOOLONGINNATURE30^lists(amilongfortoolongsay30value,givemevaluetoalabelsay30)
;
	do CANIGOALENGTHTOOLONGINNATURE30^lists(^pleasesetlongglobalshere,^summmeglobalvariable) ;this is for globals check
;
	write "Actual List is 32 Formal list is 32 in a long filenamed M Routine",!
	do IAMLONGLABELLENGTHTOOLONGSAY30^iamamroutineoflongfilename28(valueforiamlonglabellength,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)
;
;	now check whether parameters are actually newed inside a function
	set retainmexx=456
	set metootoretain=555
	set canyoustorepls=retainmexx
	set bottlemetoo=metootoretain
	set somelongvar1=333
	set var2somelongvar=456
	do NEWEDCHK^lists(somelongvar1,var2somelongvar)
	if retainmexx'=canyoustorepls write "TEST-E-ERROR value of retainmexx should not have changed",!
	else  write "correct behavior parameters are newed inside function",!
	if metootoretain'=bottlemetoo write "TEST-E-ERROR value of canyoustorepls should not have changed",!
	else  write "correct behavior parameters are newed inside function",!
	do NEWEDCHK^lists(var2somelongvar)
	if retainmexx'=canyoustorepls write "TEST-E-ERROR value of retainmexx should not have changed",!
	else  write "correct behavior parameters are newed inside function",!
	if metootoretain'=bottlemetoo write "TEST-E-ERROR value of canyoustorepls should not have changed",!
	else  write "correct behavior parameters are newed inside function",!
	do NEWEDCHK^lists()
	if retainmexx'=canyoustorepls write "TEST-E-ERROR value of retainmexx should not have changed",!
	else  write "correct behavior parameters are newed inside function",!
	if metootoretain'=bottlemetoo write "TEST-E-ERROR value of canyoustorepls should not have changed",!
	else  write "correct behavior parameters are newed inside function",!
	quit
;
;	now check whether formal list parameters are truncated on 8char
	set parame=222
	set parameter=333
	set parameter1=444
	set parameter2=555
	set parameter3=666
;
;	same check for Globals too
	set ^getme=parame
	set ^getmecorr=parameter
	set ^getmecorre=parameter1
	set ^getmecorrect=parameter2
	set ^getmecorrect1=parameter3
;
	do FIVELABELCHECK^lists(parame,parameter,parameter1,parameter2,parameter3)
	do FIVELABELCHECK^lists(^getme,^getmecorr,^getmecorre,^getmecorrect,^getmecorrect1)
;	also double check here,just to ensure call-by-value is complete & safe on globals
	if (222'=^getme)&(333'=^getmecorr)&(444'=^getmecorre)&(555'=^getmecorrect)&(666'=^getmecorrect1) do
	. write "TEST-E-ERROR formal list incorrect truncation on GLOBALS",!
	. zwrite ^getme,^getmecorr,^getmecorre,^getmecorrect,^getmecorrect1
	quit
;
	set amilongfortoolongsay30value=999
	set nowthisisenoughtosetlong=111
	set checklabelvaluelong=222
error ;
	write "Actual List is 2 Formal list is 3,should give undefined local var. error",!!
	do IAMLONGLABELLENGTHTOOLONGSAY30^lists(nowthisisenoughtosetlong,amilongfortoolongsay30value)
	quit
;
error1 ;
	write "check for 32 parameter limit,This case should give error",!!
	do DUMMYLONGLONGLONGLONGLONGLONG^lists(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33)
	quit
;
error2 ;
	write "Actual list is 1 Formal list is 2,should give undefined local var.error",!!
	do CHKLABEL^lists(checklabelvaluelong)
	quit
;
