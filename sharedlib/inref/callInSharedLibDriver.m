sharedlib1(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
	set $ZT="set $ZT="""" g ERROR^callInSharedLibDriver"
	Write !!,"At ",$zpos,!!
	set savezro=$zro
	set $zro="./shl_call_ins$gt_ld_shl_suffix ."
	write "List Object Files before shared lib call",!!  zsystem "\ls *.o"  write !!
	;
	write "Now call sharedlib1^shlib which is in shared library",!
	do sharedlib1^shlib(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
	;
	write "List Object Files after shared lib call",!!  zsystem "\ls *.o"  write !!
	write "Verify result of sharedlib1^shlib call to shared library",!
	write "do in1^lfill(""ver"",5,1)",!  do in1^lfill("ver",5,1) 
	Q
	;
sharedlib2lablengthislong678901(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
	set $ZT="set $ZT="""" g ERROR^callInSharedLibDriver"
	Write !!,"At ",$zpos,!!
	set savezro=$zro
	set $zro="./shl_call_ins$gt_ld_shl_suffix ."
	write "List Object Files before shared lib call",!!  zsystem "\ls *.o"  write !!
	;
	write "Now call sharedlib2lablengthislong678901^shlib which is in shared library",!
	set retshOneMBstr=$$sharedlib2lablengthislong678901^shlib(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
	;
	write "List Object Files after shared lib call",!!  zsystem "\ls *.o"  write !!
	write "Verify result of sharedlib2lablengthislong678901^shlib call to shared library",!
	write "do ver^lotsvar",!  do ver^lotsvar
	if retshOneMBstr'=$$^longstr(1000000) write "Verify fail for retshOneMBstr",!
	if shOneKstr'=$$^longstr(1000) write "Verify fail for shOneKstr",!
	Q
extmath;
	set $ZT="set $ZT="""" g ERROR^callInSharedLibDriver"
	Write !!,"At ",$zpos,!!
	set savezro=$zro
	set $zro="./shl_call_ins$gt_ld_shl_suffix ."
	write "List Object Files before shared lib call",!!  zsystem "\ls *.o"  write !!
	;
	write "Now call math^shlib which is in shared library",!
	do math^shlib
	;
	write "List Object Files after shared lib call",!!  zsystem "\ls *.o"  write !!
	quit
ERROR	ZSHOW "*"
	q
