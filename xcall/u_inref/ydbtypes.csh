#################################################################
#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################
# Test that ydb_xxx_t types and standard C types work in call-outs
# Note: other subtests already test gtm_xxx_t types and functionality like preallocation,
# and retvals.csh tests all return values

if ( $?gtt_cc_shl_options == "0"  ||  $?gt_ld_shl_options == "0" ) then
	echo ""		# attempt to match first line of expected output so warnings appear at begining of diff file
	echo "xcall-F-noenv, Cannot test external calls; either gtt_cc_shl_options or gt_ld_shl_options is undefined."
	echo "xcall-I-noenv, These should be defined in gtm_env_sp.csh"
	exit
endif

# Remove 64-bit lines of retvals.xc if we're on a 32-bit machine
set sed_drop64 = ""
if ($gtm_platform_size == 32) then
  set sed_drop64 = "/64:/d"
endif

echo "### Test all valid ydb types"

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydbtypes.c -o ydbtypes_obj.o
$gt_ld_shl_linker ${gt_ld_option_output}ydbtypes${gt_ld_shl_suffix} $gt_ld_shl_options ydbtypes_obj.o $gt_ld_syslibs

setenv ydb_xc_ydbtypes ydbtypes.xc
sed -e "s|.*ydbtypes\..*|`pwd`/ydbtypes${gt_ld_shl_suffix}|" -e "$sed_drop64" $gtm_tst/$tst/inref/ydbtypes.xc  >! $ydb_xc_ydbtypes

$ydb_dist/yottadb -run ydbtypes


echo
echo
echo "### Now test that invalid input (I) types are disallowed by ydb"
set types = "buffer bufferP unsigned unsignedP"
set types = "$types ydb_status_t ydb_float_t ydb_double_t float double"
foreach type ($types)
  setenv ydb_xc_ydbtypes ydb_type-$type.xc
  echo "`pwd`/ydbtypes${gt_ld_shl_suffix}" >! $ydb_xc_ydbtypes
  echo >> $ydb_xc_ydbtypes "testType: void noop(I:$type:as/P/*/)"
  echo "Check $type:as/P/*/ type is unknown to external call table parser:"
  echo "do &ydbtypes.testType(3)"  | $ydb_dist/yottadb -direct  |& grep -Eo " Unknown type encountered| Unknown construct encountered"
  if ($? != "0") then
    echo " ERROR: $type:as/P/*/ incorrectly accepted by yottadb"
  endif
  echo
end

echo
echo "### Now test that invalid output (O) types are disallowed by ydb"
#Add the types that do not work for O and IO direction
set types = "$types     int       uint       long       ulong       int64       uint64"
set types = "$types ydb_int_t ydb_uint_t ydb_long_t ydb_ulong_t ydb_int64_t ydb_uint64_t"
set types = "$types ydb_pointertofunc_t ydb_pointertofunc_tP"
foreach type ($types)
  setenv ydb_xc_ydbtypes ydb_type-$type.xc
  echo "`pwd`/ydbtypes${gt_ld_shl_suffix}" >! $ydb_xc_ydbtypes
  echo >> $ydb_xc_ydbtypes "testType: void noop(O:$type:as/P/*/)"
  echo "Check $type:as/P/*/ type is unknown to external call table parser:"
  echo "do &ydbtypes.testType(3)"  | $ydb_dist/yottadb -direct  |& grep -Eo " Unknown type encountered| Unknown construct encountered"
  if ($? != "0") then
    echo " ERROR: $type:as/P/*/ incorrectly accepted by yottadb"
  endif
  echo
end

echo
echo "### Now test that invalid input/output (IO) types are disallowed by ydb"
foreach type ($types)
  setenv ydb_xc_ydbtypes ydb_type-$type.xc
  echo "`pwd`/ydbtypes${gt_ld_shl_suffix}" >! $ydb_xc_ydbtypes
  echo >> $ydb_xc_ydbtypes "testType: void noop(IO:$type:as/P/*/)"
  echo "Check $type:as/P/*/ type is unknown to external call table parser:"
  echo "do &ydbtypes.testType(3)"  | $ydb_dist/yottadb -direct  |& grep -Eo " Unknown type encountered| Unknown construct encountered"
  if ($? != "0") then
    echo " ERROR: $type:as/P/*/ incorrectly accepted by yottadb"
  endif
  echo
end

unsetenv ydb_xc_ydbtypes
