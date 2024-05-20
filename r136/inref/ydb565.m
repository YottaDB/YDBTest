;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Helper M program used by r136/u_inref/ydb565.csh for the call-outs/external-call portion of the test
;
ydb565	;
	set $ztrap="goto incrtrap^incrtrap"
	write "# Test that if O parameter of type ydb_buffer_t * using the default external call package,",!
	write "# if no preallocation specified, a default-package ZCNOPREALLOUTPAR error is issued",!
	set o=""
	do preallocO(o)

	write "# Test that if O parameter of type ydb_buffer_t * using a custom external call package,",!
	write "# if no preallocation specified, a custom-package ZCNOPREALLOUTPAR error is issued",!
	set o=""
	do preallocCustomO(o)

	write "# Test that if IO parameter of type ydb_buffer_t * has no preallocation specified, no ZCNOPREALLOUTPAR error is issued",!
	set io="a"
	do preallocIO(io)
	zwrite io

	write "# Test that if RETURN value of type ydb_buffer_t * is NULL, M raises an error and doesn't change string",!
	set ret="ab"
	set ret=$&test1
	zwrite ret

	write "# Test that if O parameter of type ydb_buffer_t * has NULL value, M raises an error and doesn't change string",!
	set o="ab"
	do &test2(.o)
	zwrite o

	write "# Test that if IO parameter of type ydb_buffer_t * has NULL value, M raises an error and doesn't change string",!
	set io="abc"
	do &test3(.io)
	zwrite io

	write "# Test that if O parameter of type ydb_buffer_t * has NULL value is not passed by reference, M string returned is NOT the empty string",!
	set o="abcd"
	do &test2(o)
	zwrite o

	write "# Test that if IO parameter of type ydb_buffer_t * has NULL value is not passed by reference, M string returned is NOT the empty string",!
	set io="abcde"
	do &test3(io)
	zwrite io

	write "# Test that for O ydb_buffer_t * parameter, if output length is greater than 1MiB, a MAXSTRLEN error is issued",!
	set o="abc"
	do maxstrlenO(.o)

	write "# Test that for IO ydb_buffer_t * parameter, if output length is greater than 1MiB, a MAXSTRLEN error is issued",!
	set io="abc"
	do maxstrlenIO(.io)

	write "# Test that for RETURN ydb_buffer_t * parameter, if return length is greater than 1MiB, a MAXSTRLEN error is issued",!
	set ret="abc"
	do maxstrlenRET(.ret)

	write "# Test that if RETURN type ydb_buffer_t * has buf_addr NULL after call-out, M raises an error and doesn't change string",!
	set ret="abcd"
	set ret=$&test7
	zwrite ret

	write "# Test that if O parameter of type ydb_buffer_t * has buf_addr NULL after call-out, M raises an error and doesn't change string",!
	set o="abcd"
	do &test8(.o)
	zwrite o

	write "# Test that if IO parameter of type ydb_buffer_t * has buf_addr NULL after call-out, M raises an error and doesn't change string",!
	set io="abcd"
	do &test9(.io)
	zwrite io

	write "# Test that if RETURN type ydb_buffer_t * has len_used 0 after call-out, M string returned is the empty string",!
	set ret="abcde"
	set ret=$&test10
	zwrite ret

	write "# Test that if O parameter of type ydb_buffer_t * has len_used 0 after call-out, M string returned is the empty string",!
	set o="abcde"
	do &test11(.o)
	zwrite o

	write "# Test that if IO parameter of type ydb_buffer_t * has len_used 0 after call-out, M string returned is the empty string",!
	set io="abcde"
	do &test12(.io)
	zwrite io

	write "# Test that for O ydb_buffer_t * parameter, if return length is greater than pre-alloc length, a EXCEEDSPREALLOC error is issued.",!
	set o="abcdef"
	do exceedsPrealloc(.o)

	write "# Test one complete case where ydb_buffer_t * is used in I, IO, O and Return parameters",!
	set i="ab",io="cd",o="ef"
	set ret=$&test14(i,.io,.o)
	zwrite i,io,o,ret
	quit

preallocO(o);
	do &preallocO(o)
	quit

preallocCustomO(o);
	do &package1.preallocO(o)
	quit

preallocIO(io);
	do &preallocIO(io)
	quit

maxstrlenO(o);
	do &test4(.o)
	quit

maxstrlenIO(io);
	do &test5(.io)
	quit

maxstrlenRET(ret);
	set ret=$&test6()
	quit

exceedsPrealloc(o)
	do &test13(.o)
	quit

