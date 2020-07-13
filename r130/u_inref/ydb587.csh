#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#============================
# Basic
# ===========================
echo '# Test that ensures that $dollar_truth variable is set when ydb is run'
echo "==== Start Of Basic Test ===="
setenv ydb_dollartest 1
echo "Setting ydb_dollartest to 1"
echo "Value of ydb_dollartest now is $ydb_dollartest"
$ydb_dist/yottadb -r testwrt^ydb587

setenv ydb_dollartest 0
echo "Setting ydb_dollartest to 0"
echo "Value of ydb_dollartest now is $ydb_dollartest"
$ydb_dist/yottadb -r testwrt^ydb587

unsetenv ydb_dollartest
echo "Unsetting ydb_dollartest"
$ydb_dist/yottadb -r testwrt^ydb587
echo "==== End Of Basic Test ====\n\n"

##==========================
## Testing triggers file
##==========================
echo "==== Start Of Trigger Test ===="
$gtm_tst/com/dbcreate.csh mumps 3

setenv gtmgbldir alt.gld
$GDE << GDE_EOF
add -name x -region=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a.dat
change -segment DEFAULT -file=alt.dat
exit
GDE_EOF

$MUPIP create -region=DEFAULT
if ($gtm_test_qdbrundown) then
	$MUPIP set -region DEFAULT -qdbrundown >>&! set_qdbrundown.out
endif

# Test for Trigger
setenv ydb_dollartest 1
echo "Setting ydb_dollartest 1"
$ydb_dist/yottadb -r altreg^ydb587
$ydb_dist/yottadb -r setval^ydb587

echo "Setting ydb_dollartest 0"
setenv ydb_dollartest 0
$ydb_dist/yottadb -r setval^ydb587

echo "Unsetting ydb_dollartest"
unsetenv ydb_dollartest
$ydb_dist/yottadb -r setval^ydb587
echo "==== End Of Trigger Test ====\n\n"

#=============================
# Test for SimpleAPI
#============================
echo "==== Start Of Simple API Test ===="
echo "Setting ydb_dollartest 1"
setenv ydb_dollartest 1
setenv ydb_ci `pwd`/tab.ci

cat >> tab.ci << xx
tst:		void tst^tst()
xx

cat >> tst.m << \xxx
tst
	write "Value of $TEST is ",$TEST,!
	quit
\xxx

# Compile and link ydb587.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb587.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb587 $gt_ld_options_common ydb587.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
ydb587

echo "Setting ydb_dollartest 0"
setenv ydb_dollartest 0
ydb587

echo "Unsetting ydb_dollartest"
unsetenv ydb_dollartest
ydb587
echo "==== End Of Simple API Test ===="

