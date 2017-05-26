sharedlib1(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
	Write !!,"At ",$zpos,!!
	Write !!,"$zro=",$zro,!
     	write "do ^verifyargs(32)"  do ^verifyargs(32)
	write "do in1^lfill(""set"",5,1)",!  do in1^lfill("set",5,1) 
	quit 
sharedlib2lablengthislong678901(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
	Write !!,"At ",$zpos,!!
	Write !!,"$zro=",$zro,!
     	write "do ^verifyargs(32)"  do ^verifyargs(32)
	write "do set^lotsvar",!  do set^lotsvar
	set shOneKstr=$$^longstr(1000)
	set shOneMBstr=$$^longstr(1000000)
	quit shOneMBstr
math	;
	Write !!,"At ",$zpos,!!
	Write !!,"$zro=",$zro,!
	Write !,"Do External Calls to math library",!!
	For value=1:2:10 D EXP^mathtst2
	For value=1:1000:5001 D SQRT^mathtst1
	For value=1:1000:5001 D SQRTlONG^mathtst1
	For value=10000:10000:50000 D LOGNAT^mathtst3
	For value=10000:10000:50000 D LOGB10^mathtst3
	For value=10000:10000:50000 D LOGB10L^mathtst3
	Write !,"External Calls to math library Done",!!
	quit
