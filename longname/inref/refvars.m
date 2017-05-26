;	routine checks for call-by-reference mechanism in long names.
refvars;
;	check exact 31 char length
	set longlonglonglonglonglonvarlent8=10
	set lentvar8longlonglonglonglonglon=20
	set longlong=99	;this is to ensure no false value gets set due to truncation
	set lentvar8=11
	do CHANGE(longlonglonglonglonglonvarlent8,.lentvar8longlonglonglonglonglon)
	if 20=lentvar8longlonglonglonglonglon do
	. write "TEST-E-INCORRECT! longname variable lentvar8longlonglonglonglonglon not referenced",!
	. write "lentvar8longlonglonglonglonglon = ",lentvar8longlonglonglonglonglon,!
	else  do
	. if 400=lentvar8longlonglonglonglonglon do
	.. write "Call by reference is correct for lentvar8longlonglonglonglonglon",!
	. else  do
	.. write "TEST-E-INCORRECT! variable lentvar8longlonglonglonglonglon referenced with incorrect value",!
	.. write "lentvar8longlonglonglonglonglon = ",lentvar8longlonglonglonglonglon,!
	if 10'=longlonglonglonglonglonvarlent8 do
	. write "TEST-E-INCORRECT! variable longlonglonglonglonglonvarlent8 passed by value incorrect",!
	. write "longlonglonglonglonglonvarlent8 = ",longlonglonglonglonglonvarlent8,!
;
;	check some arbitrary length >8char
	set aimtocheckrandomly="TestmeRight"
	set wanttotestofanyln=689
	set aimtoche="TestmeWrong" ;this is to ensure no false value gets set due to truncation
	set wanttote=999
	set ^arbitrarylengthglobal="usmadefor" ;add some global variables too to the param list.
	set ^numericglobalchk=150
	set ^arbitrar="iamwrongbaby" ;again to ensure no false value gets set due to truncation
	set ^numericg=700
	do ARBITRARYLENGTH(.aimtocheckrandomly,wanttotestofanyln,^arbitrarylengthglobal,^numericglobalchk)
	if ("TestmeRightLongname"=aimtocheckrandomly)&(689=wanttotestofanyln)&("usmadeforcars"=^arbitrarylengthglobal)&(201=^numericglobalchk) do
	. write "Call by reference is correct for Strings & numerals",!
	else  do
	. write "TEST-E-INCORRECT! longname variable error for string number combination",!
	. write "aimtocheckrandomly = ",aimtocheckrandomly," , ","wanttotestofanyln = ",wanttotestofanyln," , ","^arbitrarylengthglobal = ",^arbitrarylengthglobal," , ","^numericglobalchk = ",^numericglobalchk,!
	quit
;       check formal list truncation scenario for >8char vars.
        set akhiba=102
        set akhibar=809
        set akhibara=710
        set akhibaraa=890
        set akhibaraisanelectrictown=900
	do LABELFIVE(.akhiba,.akhibar,.akhibara,.akhibaraa,.akhibaraisanelectrictown)
	if (akhiba'=103)&(akhibar'=811)&(akhibara'=713)&(akhibaraa'=894)&(akhibaraisanelectrictown'=905) do
	. write "Call by reference is correct for formal list Non-Truncations",!
	else  do
	. write "TEST-E-ERROR in formal list truncations on call-by-reference",!

CHANGE(xxxxxxxxxxxxxxxxxxxxxxxxxxxxx31,yyyyyyyyyyyyyyyyyyyyyyyyyyyyy31)
	set yyyyyyyyyyyyyyyyyyyyyyyyyyyyy31=yyyyyyyyyyyyyyyyyyyyyyyyyyyyy31*yyyyyyyyyyyyyyyyyyyyyyyyyyyyy31
	set xxxxxxxxxxxxxxxxxxxxxxxxxxxxx31=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx31*xxxxxxxxxxxxxxxxxxxxxxxxxxxxx31
	set yyyyyyyy=578 ;this is to ensure no false value gets set due to truncation
	set xxxxxxxx=450
	quit
ARBITRARYLENGTH(aaaaaaaaaaaa14,bbbbbbbbbb12,gggggggggggggggggg20,ttttttttttttttt17)
	set aaaaaaaaaaaa14=aaaaaaaaaaaa14_"Longname"
	set bbbbbbbbbb12=bbbbbbbbbb12*123
	set ^arbitrarylengthglobal=gggggggggggggggggg20_"cars"
	set ^numericglobalchk=ttttttttttttttt17+51
	set aaaaaaaa="Totallywrong" ;this is to ensure no false value gets set due to truncation
	set bbbbbbbb=703
	set gggggggg="badugly"
	set tttttttt=708
	quit
LABELFIVE(parame,parameter,parameter1,parameter2,parameter1a)
	set parame=parame+1
        set parameter=parameter+2
        set parameter1=parameter1+3
        set parameter2=parameter2+4
        set parameter1a=parameter1a+5
	quit
