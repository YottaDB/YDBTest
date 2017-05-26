; testtypes.m
; The following tests are call_ins from C routines using all the gtm types from
; gtmxc_types.h.  For the I: types pointer and non-pointer arguments are valid.  For the IO:
; and O: types only pointer arguments are valid.  The first 8 are I: tests where the C routine
; sends values for each of the variable arguments to M as both pointers and non-pointers for
; all valid types, but they are read only to M.  In each case the arguments are the same but a
; different type of return argument from M is specified.  The next 8 are IO: tests which accepts
; only the pointer types to M. The M function will send back a different value for each of the
; passed arguments as well as a different type of return argument.
; The final 8 are O: tests where the input from C is irrelevant.  We set it locally in C prior to
; each call to M, however, to make sure M modifies the arguments properly
;
test1(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test1 I: ",arg1,!
     w "test1 I: ",arg2,!
     w "test1 I: ",arg3,!
     w "test1 I: ",arg4,!
     w "test1 I: ",arg5,!
     w "test1 I: ",arg6,!
     w "test1 I: ",arg7,!
     w "test1 I: ",arg8,!
     w "test1 I: ",arg9,!
     w "test1 I: ",arg10,!
     w "test1 I: ",arg11,!
     w "test1 I: ",arg12,!
     w "test1 I: ",arg13,!
     w "test1 I: ",arg14,!
     w "Returning from M: 2147483647",!! 
     Q 2147483647
test2(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test2 I: ",arg1,!
     w "test2 I: ",arg2,!
     w "test2 I: ",arg3,!
     w "test2 I: ",arg4,!
     w "test2 I: ",arg5,!
     w "test2 I: ",arg6,!
     w "test2 I: ",arg7,!
     w "test2 I: ",arg8,!
     w "test2 I: ",arg9,!
     w "test2 I: ",arg10,!
     w "test2 I: ",arg11,!
     w "test2 I: ",arg12,!
     w "test2 I: ",arg13,!
     w "test2 I: ",arg14,!
     w "Returning from M: 4294967295",!! 
     Q 4294967295
test3(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test3 I: ",arg1,!
     w "test3 I: ",arg2,!
     w "test3 I: ",arg3,!
     w "test3 I: ",arg4,!
     w "test3 I: ",arg5,!
     w "test3 I: ",arg6,!
     w "test3 I: ",arg7,!
     w "test3 I: ",arg8,!
     w "test3 I: ",arg9,!
     w "test3 I: ",arg10,!
     w "test3 I: ",arg11,!
     w "test3 I: ",arg12,!
     w "test3 I: ",arg13,!
     w "test3 I: ",arg14,!
     w "Returning from M: 2147483647",!! 
     Q 2147483647
test4(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test4 I: ",arg1,!
     w "test4 I: ",arg2,!
     w "test4 I: ",arg3,!
     w "test4 I: ",arg4,!
     w "test4 I: ",arg5,!
     w "test4 I: ",arg6,!
     w "test4 I: ",arg7,!
     w "test4 I: ",arg8,!
     w "test4 I: ",arg9,!
     w "test4 I: ",arg10,!
     w "test4 I: ",arg11,!
     w "test4 I: ",arg12,!
     w "test4 I: ",arg13,!
     w "test4 I: ",arg14,!
     w "Returning from M: 4294967295",!! 
     Q 4294967295
test5(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test5 I: ",arg1,!
     w "test5 I: ",arg2,!
     w "test5 I: ",arg3,!
     w "test5 I: ",arg4,!
     w "test5 I: ",arg5,!
     w "test5 I: ",arg6,!
     w "test5 I: ",arg7,!
     w "test5 I: ",arg8,!
     w "test5 I: ",arg9,!
     w "test5 I: ",arg10,!
     w "test5 I: ",arg11,!
     w "test5 I: ",arg12,!
     w "test5 I: ",arg13,!
     w "test5 I: ",arg14,!
     w "Returning from M:  2345.2345",!! 
     Q 2345.2345
test6(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test6 I: ",arg1,!
     w "test6 I: ",arg2,!
     w "test6 I: ",arg3,!
     w "test6 I: ",arg4,!
     w "test6 I: ",arg5,!
     w "test6 I: ",arg6,!
     w "test6 I: ",arg7,!
     w "test6 I: ",arg8,!
     w "test6 I: ",arg9,!
     w "test6 I: ",arg10,!
     w "test6 I: ",arg11,!
     w "test6 I: ",arg12,!
     w "test6 I: ",arg13,!
     w "test6 I: ",arg14,!
     w "Returning from M: 2345.2345",!! 
     Q 2345.2345
test7(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test7 I: ",arg1,!
     w "test7 I: ",arg2,!
     w "test7 I: ",arg3,!
     w "test7 I: ",arg4,!
     w "test7 I: ",arg5,!
     w "test7 I: ",arg6,!
     w "test7 I: ",arg7,!
     w "test7 I: ",arg8,!
     w "test7 I: ",arg9,!
     w "test7 I: ",arg10,!
     w "test7 I: ",arg11,!
     w "test7 I: ",arg12,!
     w "test7 I: ",arg13,!
     w "test7 I: ",arg14,!
     w "Returning from M: This is the return value from test7",!! 
     Q "This is the return value from test7"
test8(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test8 I: ",arg1,!
     w "test8 I: ",arg2,!
     w "test8 I: ",arg3,!
     w "test8 I: ",arg4,!
     w "test8 I: ",arg5,!
     w "test8 I: ",arg6,!
     w "test8 I: ",arg7,!
     w "test8 I: ",arg8,!
     w "test8 I: ",arg9,!
     w "test8 I: ",arg10,!
     w "test8 I: ",arg11,!
     w "test8 I: ",arg12,!
     w "test8 I: ",arg13,!
     w "test8 I: ",arg14,!
     w "Returning from M: This is the return value from test8",!! 
     Q "This is the return value from test8"
test9(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test9 IO: ",arg1,!
     w "test9 IO: ",arg2,!
     w "test9 IO: ",arg3,!
     w "test9 IO: ",arg4,!
     w "test9 IO: ",arg5,!
     w "test9 IO: ",arg6,!
     w "test9 IO: ",arg7,!
     w "test9 IO: ",arg8,!
     w "test9 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test9 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test9 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test9 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test9 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test9 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test9 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test9 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 2147483647",!! 
     Q 2147483647
test10(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test10 IO: ",arg1,!
     w "test10 IO: ",arg2,!
     w "test10 IO: ",arg3,!
     w "test10 IO: ",arg4,!
     w "test10 IO: ",arg5,!
     w "test10 IO: ",arg6,!
     w "test10 IO: ",arg7,!
     w "test10 IO: ",arg8,!
     w "test10 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test10 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test10 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test10 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test10 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test10 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test10 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test10 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 4294967295",!! 
     Q 4294967295
test11(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test11 IO: ",arg1,!
     w "test11 IO: ",arg2,!
     w "test11 IO: ",arg3,!
     w "test11 IO: ",arg4,!
     w "test11 IO: ",arg5,!
     w "test11 IO: ",arg6,!
     w "test11 IO: ",arg7,!
     w "test11 IO: ",arg8,!
     w "test11 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test11 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test11 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test11 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test11 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test11 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test11 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test11 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 2147483647",!! 
     Q 2147483647
test12(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test12 IO: ",arg1,!
     w "test12 IO: ",arg2,!
     w "test12 IO: ",arg3,!
     w "test12 IO: ",arg4,!
     w "test12 IO: ",arg5,!
     w "test12 IO: ",arg6,!
     w "test12 IO: ",arg7,!
     w "test12 IO: ",arg8,!
     w "test12 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test12 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test12 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test12 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test12 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test12 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test12 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test12 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 4294967295",!! 
     Q 4294967295
test13(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test13 IO: ",arg1,!
     w "test13 IO: ",arg2,!
     w "test13 IO: ",arg3,!
     w "test13 IO: ",arg4,!
     w "test13 IO: ",arg5,!
     w "test13 IO: ",arg6,!
     w "test13 IO: ",arg7,!
     w "test13 IO: ",arg8,!
     w "test13 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test13 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test13 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test13 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test13 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test13 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test13 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test13 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M:  2345.2345",!! 
     Q 2345.2345
test14(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test14 IO: ",arg1,!
     w "test14 IO: ",arg2,!
     w "test14 IO: ",arg3,!
     w "test14 IO: ",arg4,!
     w "test14 IO: ",arg5,!
     w "test14 IO: ",arg6,!
     w "test14 IO: ",arg7,!
     w "test14 IO: ",arg8,!
     w "test14 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test14 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test14 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test14 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test14 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test14 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test14 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test14 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 2345.2345",!! 
     Q 2345.2345
test15(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test15 IO: ",arg1,!
     w "test15 IO: ",arg2,!
     w "test15 IO: ",arg3,!
     w "test15 IO: ",arg4,!
     w "test15 IO: ",arg5,!
     w "test15 IO: ",arg6,!
     w "test15 IO: ",arg7,!
     w "test15 IO: ",arg8,!
     w "test15 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test15 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test15 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test15 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test15 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test15 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test15 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test15 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: This is the return value from test15",!! 
     Q "This is the return value from test15"
test16(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test16 IO: ",arg1,!
     w "test16 IO: ",arg2,!
     w "test16 IO: ",arg3,!
     w "test16 IO: ",arg4,!
     w "test16 IO: ",arg5,!
     w "test16 IO: ",arg6,!
     w "test16 IO: ",arg7,!
     w "test16 IO: ",arg8,!
     w "test16 IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test16 IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test16 IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test16 IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test16 IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test16 IO: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test16 IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test16 IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: This is the return value from test16",!! 
     Q "This is the return value from test16"
test17(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test17 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test17 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test17 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test17 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test17 O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test17 O: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test17 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test17 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 2147483647",!! 
     Q 2147483647
test18(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test18 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test18 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test18 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test18 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test18 O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test18 O: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test18 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test18 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 4294967295",!! 
     Q 4294967295
test19(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test19 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test19 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test19 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test19 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test19 O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test19 O: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test19 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test19 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 2147483647",!! 
     Q 2147483647
test20(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test20 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test20 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test20 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test20 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test20 O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test20 O: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test20 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test20 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: 4294967295",!! 
     Q 4294967295
test21(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test21 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test21 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test21 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test21 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test21 O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test21 O: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test21 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test21 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: -1234.567",!! 
     Q -1234.567
test22(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test22 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test22 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test22 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test22 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test22 O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test22 O: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test22 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test22 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: -1234567.891",!! 
     Q -1234567.891
test23(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test23 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test23 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test23 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test23 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test23 O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test23 O: setting arg6 = 1234567.891",!
     s arg6=1234567.891
     w "test23 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test23 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: The is the return value from test23",!! 
     Q "The is the return value from test23"
test24(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test24 O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test24 O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test24 O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test24 O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test24 O: setting arg5 = 1244.567",!
     s arg5=1244.567
     w "test24 O: setting arg6 = 1244567.891",!
     s arg6=1244567.891
     w "test24 O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test24 O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     w "Returning from M: The is the return value from test24",!! 
     Q "The is the return value from test24"
