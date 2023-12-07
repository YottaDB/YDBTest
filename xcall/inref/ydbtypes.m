;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
; All rights reserved.
;
;	This source code contains the intellectual property
;	of its copyright holder(s), and is made available
;	under a license.  If you do not know the terms of
; the license, please stop and do not read further.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

run
 set int=-2147483647  ;-2^31-1: most negative int32 value
 set uint=4294967295  ;2^32-1: largest uint32 value
 set long=int
 set ulong=uint
 set int64=-9223372036854775807   ;-2^63: most negative int64 value
 set uint64=18446744073709551615  ;2^64-1: largest uint64 value
 set float=1234.56
 set double=17976931348623200000000000000000000000000000000  ;use full 15-digit double number accuracy
 set string1="a man"
 set string2="a plan"
 set string3="a canal"
 set string4="panama"
 set c=","

 write !,"### Loading call-out table"

 do &ydbtypes.noop()  ;Check whether call-out table loads

 write !,"### Test ydb_xxx_t types",!

 write "# Test input (I) parameters",!
 write "  Input:  ",int,c,int,c,uint,c,uint,c,long,c,long,c,ulong,c,ulong,c,int64,c,uint64,c,$fnumber(float,"",2),c,$fnumber(double/1E46,"",14)_"e+46",c,string1,c,string2,c,string3,c,string4,!
 do &ydbtypes.yinputs(int,int,uint,uint,long,long,ulong,ulong,int64,uint64,float,double,string1,string2,string3,string4)

 write "# Test output (O) parameters:",!
 set intO=1,uintO=2,longO=3,ulongO=4,int64O=5,uint64O=6,floatO=7,doubleO=8
 set string1O="test1",string2O="test2",string3O="test3",string4O="test4"
 write "  Input:  ",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!
 do &ydbtypes.youtputs(.intO,.uintO,.longO,.ulongO,.int64O,.uint64O,.floatO,.doubleO,.string1O,.string2O,.string3O,.string4O)
 write "  Receive:",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!

 write "# Test input/output (IO) parameters:",!
 set intO=int,uintO=uint,longO=long,ulongO=ulong,int64O=int64,uint64O=uint64,floatO=float,doubleO=double
 set string1O=string1,string2O=string2,string3O=string3,string4O=string4
 write "  Input:  ",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!
 do &ydbtypes.yio(.intO,.uintO,.longO,.ulongO,.int64O,.uint64O,.floatO,.doubleO,.string1O,.string2O,.string3O,.string4O)
 write "  Receive:",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!


 write !,"### Test standard C types",!

 write "# Test input (I) parameters",!
 write "  Input:  ",int,c,int,c,uint,c,uint,c,long,c,long,c,ulong,c,ulong,c,int64,c,uint64,c,$fnumber(float,"",2),c,$fnumber(double/1E46,"",14)_"e+46",c,string1,c,string2,c,string3,c,string4,!
 do &ydbtypes.cinputs(int,int,uint,uint,long,long,ulong,ulong,int64,uint64,float,double,string1,string2,string3,string4)

 write "# Test output (O) parameters:",!
 set intO=1,uintO=2,longO=3,ulongO=4,int64O=5,uint64O=6,floatO=7,doubleO=8
 set string1O="test1",string2O="test2",string3O="test3",string4O="test4"
 write "  Input:  ",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!
 do &ydbtypes.coutputs(.intO,.uintO,.longO,.ulongO,.int64O,.uint64O,.floatO,.doubleO,.string1O,.string2O,.string3O,.string4O)
 write "  Receive:",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!

 write "# Test input/output (IO) parameters:",!
 set intO=int,uintO=uint,longO=long,ulongO=ulong,int64O=int64,uint64O=uint64,floatO=float,doubleO=double
 set string1O=string1,string2O=string2,string3O=string3,string4O=string4
 write "  Input:  ",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!
 do &ydbtypes.cio(.intO,.uintO,.longO,.ulongO,.int64O,.uint64O,.floatO,.doubleO,.string1O,.string2O,.string3O,.string4O)
 write "  Receive:",intO,c,uintO,c,longO,c,ulongO,c,int64O,c,uint64O,c,$fnumber(floatO,"",2),c,$fnumber(doubleO/1E46,"",14)_"e+46",c,string1O,c,string2O,c,string3O,c,string4O,!

 ;gtm_platform_size is set by test system
 if $ztrnlnm("gtm_platform_size")'="32" do
 .write !,"### Test 64-bit ydb_xxx_t types",!
 .write "  Input:  ",int64,c,uint64,!
 .do &ydbtypes.yinputs64(int64,uint64)
 .write !,"### Test 64-bit standard C types",!
 .write "  Input:  ",int64,c,uint64,!
 .do &ydbtypes.cinputs64(int64,uint64)

 quit
