////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
// All rights reserved.
//
//	This source code contains the intellectual property
//	of its copyright holder(s), and is made available
//	under a license.  If you do not know the terms of
// the license, please stop and do not read further.
//
////////////////////////////////////////////////////////////////////////////////
ydbtypes.so

// Test only ydb_xxx_t types and standard C types.
// Older gtm_xxx_t and xc_xxx_t types are tested in other subtests.

noop: void noop()

yinputs: void inputs_tester(I:ydb_int_t, I:ydb_int_t*, I:ydb_uint_t, I:ydb_uint_t*, I:ydb_long_t, I:ydb_long_t*, I:ydb_ulong_t, I:ydb_ulong_t*, I:ydb_int64_t*, I:ydb_uint64_t*, I:ydb_float_t*, I:ydb_double_t*, I:ydb_char_t*, I:ydb_string_t*, I:ydb_buffer_t*, I:ydb_char_t**)
youtputs: void outputs_tester(O:ydb_int_t*, O:ydb_uint_t*, O:ydb_long_t*, O:ydb_ulong_t*, O:ydb_int64_t*, O:ydb_uint64_t*, O:ydb_float_t*, O:ydb_double_t*, O:ydb_char_t*[100], O:ydb_string_t*[100], O:ydb_buffer_t*[100], O:ydb_char_t**[1000])
yio: void io_tester(IO:ydb_int_t*, IO:ydb_uint_t*, IO:ydb_long_t*, IO:ydb_ulong_t*, IO:ydb_int64_t*, IO:ydb_uint64_t*, IO:ydb_float_t*, IO:ydb_double_t*, IO:ydb_char_t*, IO:ydb_string_t*, IO:ydb_buffer_t*, IO:ydb_char_t**)

cinputs: void inputs_tester(I:int, I:int*, I:uint, I:uint*, I:long, I:long*, I:ulong, I:ulong*, I:int64*, I:uint64*, I:float*, I:double*, I:char*, I:string*, I:ydb_buffer_t*, I:char**)
coutputs: void outputs_tester(O:int*, O:uint*, O:long*, O:ulong*, O:int64*, O:uint64*, O:float*, O:double*, O:char*[100], O:string*[100], O:ydb_buffer_t*[100], O:char**[1000])
cio: void io_tester(IO:int*, IO:uint*, IO:long*, IO:ulong*, IO:int64*, IO:uint64*, IO:float*, IO:double*, IO:char*, IO:string*, IO:ydb_buffer_t*, IO:char**)

// The following are tested only on 64-bit platforms
yinputs64: void inputs64_tester(I:ydb_int64_t, I:ydb_uint64_t)
cinputs64: void inputs64_tester(I:int64, I:uint64)
