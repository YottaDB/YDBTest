; check for longlabel
Morethan8charlabel(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,var3)
     Write !!,"called from label Morethan8charlabel from routine morethan8charciargs.m",!!
     Write "Correct behavior",!!
     Write var3,!
     write "do ^verifyargs(31)"  do ^verifyargs(31)
     Q
Morethan(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32)
     Write !!,"Passed params from C: called from Morethan label",!
     Write "From File morethan8charciargs.m",!
     Write "This should not be called explicitly, still we are here",!
     Write "TEST-E-Error wrong behavior",!!
     Q
;Below P was intended to be '%'. But it is a valid lexical token for MACRO and cannot be used for VMS.
;Once S/W is fixed it can be used as valid char for UNIX.
;##DISABLED_TEST##REENABLE##
;## %31CharLabel0000000000000000000 ....
;##END_DISABLE##
P31CharLabel0000000000000000000(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,var4)
     Write !!,"called from label P31CharLabel0000000000000000000 from routine morethan8charciargs.m",!!
     Write "Correct behavior",!!
     Write var4,!
     write "do ^verifyargs(31)"  do ^verifyargs(31)
     Q
12345678(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,var4)
     Write !!,"called from label 12345678 from routine morethan8charciargs.m",!!
     Write "Correct behavior",!!
     Write var4,!
     write "do ^verifyargs(31)"  do ^verifyargs(31)
     Q
