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
 write !,"### Test standard C types in .xc file",!  ;but using C functions that return the equivalent ydb_*_t
 ;Test void function
 do &retvals.void()
 write "  received: nothing",!
 set val=$&retvals.int() write "  received: ",val,!
 set val=$&retvals.uint() write "  received: ",val,!
 set val=$&retvals.long() write "  received: ",val,!
 set val=$&retvals.ulong() write "  received: ",val,!
 set val=$&retvals.charPtr() write "  received: ",val,!
 set val=$&retvals.charPtrPtr() write "  received: ",val,!
 set val=$&retvals.stringPtr() write "  received: ",val,!
 set val=$&retvals.intPtr() write "  received: ",val,!
 set val=$&retvals.uintPtr() write "  received: ",val,!
 set val=$&retvals.longPtr() write "  received: ",val,!
 set val=$&retvals.ulongPtr() write "  received: ",val,!
 set val=$&retvals.floatPtr() write "  received: ",val,!
 set val=$&retvals.doublePtr() write "  received: ",val,!

 write !,"### Test ydb_* types",!
 ;Test that status non-zero return raises an error
 set val=$&retvals.statusZero() write "  received: ",val,!
 set errorHandler="set error=$ecode w ""  "",$select(error["",Z150376818,"":""correctly received error: "",1:""received error: ""),error,! set $ecode="""""
 do
 .new $etrap
 .set $etrap=errorHandler
 .set val=$&retvals.statusNegative() write "  received: ",val,!
 do
 .new $etrap
 .set $etrap=errorHandler
 .set val=$&retvals.statusPositive() write "  received: ",val,!

 set val=$&retvals.yint() write "  received: ",val,!
 set val=$&retvals.yuint() write "  received: ",val,!
 set val=$&retvals.ylong() write "  received: ",val,!
 set val=$&retvals.yulong() write "  received: ",val,!

 ;gtm_platform_size is set by test system
 if $ztrnlnm("gtm_platform_size")'="32" do
 .set val=$&retvals.yint64() write "  received: ",val,!
 .set val=$&retvals.yuint64() write "  received: ",val,!

 set val=$&retvals.yintPtr() write "  received: ",val,!
 set val=$&retvals.yuintPtr() write "  received: ",val,!
 set val=$&retvals.ylongPtr() write "  received: ",val,!
 set val=$&retvals.yulongPtr() write "  received: ",val,!
 set val=$&retvals.yint64Ptr() write "  received: ",val,!
 set val=$&retvals.yuint64Ptr() write "  received: ",val,!
 set val=$&retvals.yfloatPtr() write "  received: ",val,!
 set val=$&retvals.ydoublePtr() write "  received: ",val,!

 set val=$&retvals.ycharPtr() write "  received: ",val,!
 set val=$&retvals.ycharPtrPtr() write "  received: ",val,!
 set val=$&retvals.ystringPtr() write "  received: ",val,!
 set val=$&retvals.ybufferPtr() write "  received: ",val,!

 write !,"### Re-test using equivalent gtm_* types",!  ;but using C functions that return the equivalent ydb_*_t
 set val=$&retvals.gstatusZero() write "  received: ",val,!
 do
 .new $etrap
 .set $etrap=errorHandler
 .set val=$&retvals.gstatusNegative() write "  received: ",val,!
 do
 .new $etrap
 .set $etrap=errorHandler
 .set val=$&retvals.gstatusPositive() write "  received: ",val,!

 set val=$&retvals.gint() write "  received: ",val,!
 set val=$&retvals.guint() write "  received: ",val,!
 set val=$&retvals.glong() write "  received: ",val,!
 set val=$&retvals.gulong() write "  received: ",val,!

 set val=$&retvals.gintPtr() write "  received: ",val,!
 set val=$&retvals.guintPtr() write "  received: ",val,!
 set val=$&retvals.glongPtr() write "  received: ",val,!
 set val=$&retvals.gulongPtr() write "  received: ",val,!
 set val=$&retvals.gfloatPtr() write "  received: ",val,!
 set val=$&retvals.gdoublePtr() write "  received: ",val,!

 set val=$&retvals.gcharPtr() write "  received: ",val,!
 set val=$&retvals.gcharPtrPtr() write "  received: ",val,!
 set val=$&retvals.gstringPtr() write "  received: ",val,!
 ;Should the following be the only ydb_* type that is not valid as a gtm_* type
 ;set val=$&retvals.gbufferPtr() write "  received: ",val,!

;Skip all Java tests, in favour of the existing java test
;See thread at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/398#note_1698692806
; write !,"### Test gtm_j* types",!
; set val=$&retvals.gjboolean() write "  received: ",val,!
; set val=$&retvals.gjint() write "  received: ",val,!
; set val=$&retvals.gjlong() write "  received: ",val,!
 ;The following are incorrectly parsed as legal in the external call table.
 ;They do not work because callg's calling convention cannot return float types
 ;and the string types make no sense to return as non-pointer types
; set val=$&retvals.gjfloat() write "  received: ",val,!
; set val=$&retvals.gjdouble() write "  received: ",val,!
; set val=$&retvals.gjstring() write "  received: ",val,!
; set val=$&retvals.gjbyteArray() write "  received: ",val,!
; set val=$&retvals.gjbigDecimal() write "  received: ",val,!

;The following are not implemented. Should they be, to enable all return types to Java?
; write !,"### Re-test using equivalent gtm_j* types",!
; set val=$&retvals.gjboolean() write "  received: ",val,!
; set val=$&retvals.gjint() write "  received: ",val,!
; set val=$&retvals.gjlong() write "  received: ",val,!
; set val=$&retvals.gjfloat() write "  received: ",val,!
; set val=$&retvals.gjdouble() write "  received: ",val,!
; set val=$&retvals.gjstring() write "  received: ",val,!
; set val=$&retvals.gjbyteArray() write "  received: ",val,!
; set val=$&retvals.gjbigDecimal() write "  received: ",val,!

 quit
