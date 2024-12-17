#!/usr/local/bin/tcsh -fx
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "######################################################################################"
echo '# Test that I/O parameters for external calls can be pre-allocated'
echo "######################################################################################"

echo "# Compile external C routines"
set file = 'ydb1056'
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_shl_linker ${gt_ld_option_output}lib${file}${gt_ld_shl_suffix} $gt_ld_shl_options $file.o $gt_ld_syslibs

echo "# Run [dbcreate.csh]"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "# Export environment variables for M->C FFI"
setenv ydb_xc_c $gtm_tst/$tst/inref/ydb1056.xc
setenv LD_LIBRARY_PATH .

echo "# ydb_buffer_t"
echo "# Verify the C program can both read and write IO ydb_buffer_t* arguments."
$gtm_dist/mumps -run %XCMD 'SET x="example-input"  DO &c.iorepeatb(.x)  WRITE "c.iorepeatb: ",$ZLENGTH(x)," ",x,!'

echo "# Verify the C program can write to IO ydb_buffer_t* arguments even if the input string is empty."
$gtm_dist/mumps -run %XCMD 'SET x=""  DO &c.iorepeatb(.x)  WRITE "c.iorepeatb: ",$ZLENGTH(x)," ",x,!'

echo "# Verify the C program can distinguish skipped actuals from 0-length IO ydb_buffer_t* arguments."
$gtm_dist/mumps -run %XCMD 'DO &c.iorepeatb(,0)'
$gtm_dist/mumps -run %XCMD 'DO &c.iorepeatb("")'

echo "# Verify the C program can distinguish skipped actuals from uninitialized O ydb_buffer_t* arguments."
$gtm_dist/mumps -run %XCMD 'DO &c.orepeatb(,0)'
$gtm_dist/mumps -run %XCMD 'DO &c.orepeatb(.empty)'

echo "# ydb_string_t"
echo "# Verify the C program can both read and write IO ydb_string_t* arguments."
$gtm_dist/mumps -run %XCMD 'SET x="example-input"  DO &c.iorepeats(.x)  WRITE "c.iorepeats: ",$ZLENGTH(x)," ",x,!'

echo "# Verify the C program can write to IO ydb_string_t* arguments even if the input string is empty."
$gtm_dist/mumps -run %XCMD 'SET x=""  DO &c.iorepeats(.x)  WRITE "c.iorepeats: ",$ZLENGTH(x)," ",x,!'

echo "# Verify the C program can distinguish skipped actuals from 0-length IO ydb_string_t* arguments."
$gtm_dist/mumps -run %XCMD 'DO &c.iorepeats(,0)'
$gtm_dist/mumps -run %XCMD 'DO &c.iorepeats("")'

echo "# Verify the C program can distinguish skipped actuals from O ydb_string_t* arguments."
$gtm_dist/mumps -run %XCMD 'DO &c.orepeats(,0)'
$gtm_dist/mumps -run %XCMD 'DO &c.orepeats(.empty)'


echo "# ydb_char_t"
echo "# Verify the C program can both read and write IO ydb_char_t* arguments."
$gtm_dist/mumps -run %XCMD 'SET x="example-input"  DO &c.iorepeatc(.x)  WRITE "c.iorepeatc: ",$ZLENGTH(x)," ",x,!'

echo "# Verify the C program can write to IO ydb_char_t* arguments even if the input string is empty."
$gtm_dist/mumps -run %XCMD 'SET x=""  DO &c.iorepeatc(.x)  WRITE "c.iorepeatc: ",$ZLENGTH(x)," ",x,!'

echo "# Verify skipped actuals are passed as 0-length null-terminated strings for IO ydb_char_t* arguments."
$gtm_dist/mumps -run %XCMD 'DO &c.iorepeatc(,0)'
$gtm_dist/mumps -run %XCMD 'DO &c.iorepeatc("")'

echo "# Verify skipped actuals are passed as 0-length null-terminated strings for O ydb_char_t* arguments."
$gtm_dist/mumps -run %XCMD 'DO &c.orepeatc(,0)'
$gtm_dist/mumps -run %XCMD 'DO &c.orepeatc(.empty)'


echo "# Verify that ydb_char_t** does not allow pre-allocation as an O param."
setenv ydb_xc_type type_char_double_star_o.xc
printf "libydb1056.so\n%s" "fooCharDoubleStarO: void foo_char_double_star(O:ydb_char_t **[15])" > $ydb_xc_type
$gtm_dist/mumps -run %XCMD 'SET x=1  DO &type.fooO(.x)'

echo "# Verify that ydb_char_t** does not allow pre-allocation as an IO param."
setenv ydb_xc_type type_char_double_star_io.xc
printf "libydb1056.so\n%s" "fooCharDoubleStarIO: void foo_char_double_star(IO:ydb_char_t **[15])" > $ydb_xc_type
$gtm_dist/mumps -run %XCMD 'SET x=1  DO &type.fooIO(.x)'


echo "# Verify that each pointer to a numeric type gives an error when pre-allocated."
set types = (int double float uint long ulong int64 uint64)
foreach type ($types)
	echo "# O : ydb_${type}_t *"
	setenv ydb_xc_type type_${type}_o.xc
	printf "libydb1056.so\n%s" "foo${type}O: void foo_$type(O:ydb_${type}_t *[15])" > $ydb_xc_type
	$gtm_dist/mumps -run %XCMD "SET x=1  DO &type.foo${type}O(.x)"

	echo "# IO : ydb_${type}_t *"
	setenv ydb_xc_type type_${type}_io.xc
	printf "libydb1056.so\n%s" "foo${type}IO: void foo_$type(IO:ydb_${type}_t *[15])" > $ydb_xc_type
	$gtm_dist/mumps -run %XCMD "SET x=1  DO &type.foo${type}IO(.x)"
end

echo "# Shutdown the server and verify database integrity."
$gtm_tst/com/dbcheck.csh >& dbcheck.out
