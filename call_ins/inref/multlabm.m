multlabm; check for longlabel
Greaterthan31charlabelshouldnot(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
     Write !!,"called from label Greaterthan31charlabelshouldnot from routine multlabm.m",!!
     Write "Correct behavior",!!
     write "do ^verifyargs(32)"  do ^verifyargs(32)
     Q
Greaterthan31charlabelshouldnotbecalled(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
     Write !!,"called from label Greaterthan31charlabelshouldnotbecalled from routine multlabm.m",!!
     Write "TEST-E-Error wrong behavior, We should not be here with ",$length("Greaterthan31charlabelshouldnotbecalled")," length label",!!
     Q
