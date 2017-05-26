; check for longlabel
long(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
     Write !!,"Passed params from C: called from label long from routine ciargs",!!
     write "do ^verifyargs(32)"  do ^verifyargs(32)
     Q
Morethan(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,var1)
     Write !!,"called from label Morethan from routine ciargs",!!
     write "do ^verifyargs(31)"  do ^verifyargs(31)
     Write var1,!
     Q
Morethan8char(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,var2)
     Write !!,"called from label Morethan8char from routine ciargs",!!
     write "do ^verifyargs(31)"  do ^verifyargs(31)
     Write var2,!
     Q
toolong(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32,arg33)
     Use 0
     Write !!,"Arguments list passed is Too long!:",!!
     write "do ^verifyargs(33)"  do ^verifyargs(33)
     Write "Got all arguments passed....",!
     Q
args(arg1,arg2,arg3,arg4,arg5,arg6,arg7)
     ;
     Write !!,"Passed params (args^ciargs):",!!
     write "do ^verifyargs(7)"  do ^verifyargs(7)
     Q
     ;
moreactl(arg1,arg2,arg3,arg4,arg5)
     ;
     Use 0
     Write !!,"Arguments passed: (moreactl^ciargs):",!!
     write "do ZWR",!  ZWR
     write "Done from ",$zpos,!
     Q
lessactl(arg1,arg2,arg3,arg4,arg5)
     ;
     Use 0
     Write !!,"Arguments passed: (lessactl^ciargs):",!!
     write "do ZWR",!  ZWR
     write "Done from ",$zpos,!
     Q
