;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2007-2014 Fidelity National Information         ;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;                                                               ;
; Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; testtypes.m
; Refer to the comment at the top of ydbxc_test_types.c to describe the sequence of tests below.
;
test0()
     w "Returning from M: void",!!
     Q

testA(testNum,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "test",testNum," I: ",arg1,!
     w "test",testNum," I: ",arg2,!
     w "test",testNum," I: ",arg3,!
     w "test",testNum," I: ",arg4,!
     w "test",testNum," I: ",arg5,!
     w "test",testNum," I: ",arg6,!
     w "test",testNum," I: ",arg7,!
     w "test",testNum," I: ",arg8,!
     w "test",testNum," I: ",arg9,!
     w "test",testNum," I: ",arg10,!
     w "test",testNum," I: ",arg11,!
     w "test",testNum," I: ",arg12,!
     w "test",testNum," I: ",arg13,!
     w "test",testNum," I: ",arg14,!
     Q
test1(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(1,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: 2147483647",!!
     Q 2147483647
test2(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(2,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: 4294967295",!!
     Q 4294967295
test3(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(3,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: 2147483647",!!
     Q 2147483647
test4(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(4,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: 4294967295",!!
     Q 4294967295
test5(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(5,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M:  2345.2345",!!
     Q 2345.2345
test6(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(6,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: 2345.2345",!!
     Q 2345.2345
test7(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(7,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: This is the return value from test7",!!
     Q "This is the return value from test7"
test8(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(8,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: This is the return value from test8",!!
     Q "This is the return value from test8"
test108(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     do testA(108,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
     w "Returning from M: This is the return value from test108",!!
     Q "This is the return value from test108"

testB(testNum,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test",testNum," IO: ",arg1,!
     w "test",testNum," IO: ",arg2,!
     w "test",testNum," IO: ",arg3,!
     w "test",testNum," IO: ",arg4,!
     w "test",testNum," IO: ",arg5,!
     w "test",testNum," IO: ",arg6,!
     w "test",testNum," IO: ",arg7,!
     w "test",testNum," IO: ",arg8,!
     w "test",testNum," IO: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test",testNum," IO: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test",testNum," IO: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test",testNum," IO: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test",testNum," IO: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test",testNum," IO: setting arg6 = 17976931348623",!
     s arg6=17976931348623
     w "test",testNum," IO: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test",testNum," IO: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     Q
test9(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(9,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 2147483647",!!
     Q 2147483647
test10(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(10,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 4294967295",!!
     Q 4294967295
test11(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(11,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 2147483647",!!
     Q 2147483647
test12(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(12,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 4294967295",!!
     Q 4294967295
test13(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(13,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M:  2345.2345",!!
     Q 2345.2345
test14(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(14,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 2345.2345",!!
     Q 2345.2345
test15(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(15,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: This is the return value from test15",!!
     Q "This is the return value from test15"
test16(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(16,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: This is the return value from test16",!!
     Q "This is the return value from test16"
test116(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testB(116,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: This is the return value from test116",!!
     Q "This is the return value from test116"

testC(testNum,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     w "test",testNum," O: setting arg1 = -2147483647",!
     s arg1=-2147483647
     w "test",testNum," O: setting arg2 = 4294967295",!
     s arg2=4294967295
     w "test",testNum," O: setting arg3 = -2147483647",!
     s arg3=-2147483647
     w "test",testNum," O: setting arg4 = 4294967295",!
     s arg4=4294967295
     w "test",testNum," O: setting arg5 = 1234.567",!
     s arg5=1234.567
     w "test",testNum," O: setting arg6 = 17976931348623",!
     s arg6=17976931348623
     w "test",testNum," O: setting arg7 = This is arg7",!
     s arg7="This is arg7"
     w "test",testNum," O: setting arg8 = This is arg8",!
     s arg8="This is arg8"
     Q
test17(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(17,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 2147483647",!!
     Q 2147483647
test18(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(18,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 4294967295",!!
     Q 4294967295
test19(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(19,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 2147483647",!!
     Q 2147483647
test20(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(20,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: 4294967295",!!
     Q 4294967295
test21(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(21,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: -1234.567",!!
     Q -1234.567
test22(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(22,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: -17976931348623",!!
     Q -17976931348623
test23(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(23,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: The is the return value from test23",!!
     Q "This is the return value from test23"
test24(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(24,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: The is the return value from test24",!!
     Q "This is the return value from test24"
test124(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)
     do testC(124,.arg1,.arg2,.arg3,.arg4,.arg5,.arg6,.arg7,.arg8)
     w "Returning from M: The is the return value from test124",!!
     Q "This is the return value from test124"
