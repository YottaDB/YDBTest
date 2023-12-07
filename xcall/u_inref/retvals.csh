#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
# This source code contains the intellectual property
# of its copyright holder(s), and is made available
# under a license.  If you do not know the terms of
# the license, please stop and do not read further.
#
#################################################################
# Test various return values from external call-outs
# Note: basic.csh / make_fcn.csh already test the following retvals:
#   void, gtm_long_t, gtm_ulong_t, gtm_status_t, gtm_int_t, gtm_uint_t

if ( $?gtt_cc_shl_options == "0"  ||  $?gt_ld_shl_options == "0" ) then
	echo ""		# attempt to match first line of expected output so warnings appear at begining of diff file
	echo "xcall-F-noenv, Cannot test external calls; either gtt_cc_shl_options or gt_ld_shl_options is undefined."
	echo "xcall-I-noenv, These should be defined in gtm_env_sp.csh"
	exit
endif

# Remove 64-bit lines of retvals.xc if we're on a 32-bit machine
set sed_drop64 = ""
if ($gtm_platform_size == 32) then
  set sed_drop64 = "/int64:/d"
endif

echo "### Test all valid return types"

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/retvals.c -o retvals_obj.o
$gt_ld_shl_linker ${gt_ld_option_output}retvals${gt_ld_shl_suffix} $gt_ld_shl_options retvals_obj.o $gt_ld_syslibs

setenv ydb_xc_retvals retvals.xc
sed -e "s|.*retvals\..*|`pwd`/retvals${gt_ld_shl_suffix}|" -e "$sed_drop64" $gtm_tst/$tst/inref/retvals.xc  >! $ydb_xc_retvals

$ydb_dist/yottadb -run retvals


echo
echo "### Now test that invalid types are disallowed by ydb"

set types = "string buffer unsigned unsignedP"
set types = "$types     char       float       double"
set types = "$types ydb_char_t ydb_float_t ydb_double_t"
set types = "$types gtm_char_t gtm_float_t gtm_double_t gtm_buffer_tP"
# it does not makes sense to return ydb_pointertofunc_t(*)
set types = "$types ydb_pointertofunc_t ydb_pointertofunc_tP"

#Skip Java type tests in favor of java test
#See thread at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/398#note_1698692806
#set types = "$types ydb_jboolean_t ydb_jint_t ydb_jlong_t"
#set types = "$types ydb_jfloat_t  ydb_jdouble_t  ydb_jstring_t  ydb_jbyte_array_t  ydb_jbig_decimal_t"
#set types = "$types ydb_jfloat_tP ydb_jdouble_tP ydb_jstring_tP ydb_jbyte_array_tP ydb_jbig_decimal_tP"

foreach type ($types)
  setenv ydb_xc_retvals retval-$type.xc
  echo "`pwd`/retvals${gt_ld_shl_suffix}" >! $ydb_xc_retvals
  echo >> $ydb_xc_retvals "testType: $type:as/P/*/ ret_void()"
  echo "Check $type:as/P/*/ type is unknown to external call table parser:"
  echo "do &retvals.testType()"  | $ydb_dist/yottadb -direct  |& grep -o " Unknown return type"
  if ($? != "0") then
    echo " ERROR: $type:as/P/*/ incorrectly accepted by yottadb"
  endif
  echo
end

unsetenv ydb_xc_retvals
