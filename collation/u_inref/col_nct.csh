#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
#settings for straight collation
setenv gtm_test_spanreg 0	# setting nct is not supported with spanning regions as of now
source $gtm_tst/com/cre_coll_sl_straight.csh 1
##########################################
# create a db with straight collation and nct and fill it
##########################################
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps 2 125 1000
$gtm_tst/$tst/u_inref/enable_nct.csh
## This call "do ^testnct" is disabled for replication due to a known bug C9B03-001658
## move this call immediately before "set ^prefix=^" , once the bug is fixed
if (! $?test_replic) then
	$gtm_exe/mumps -run %XCMD 'do ^testnct'
else
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps 2 125 1000"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/enable_nct.csh"
	$gtm_tst/com/RF_START.csh
endif
$GTM << EOF
set ^prefix="^"
do in2^mixfill("set",15)
do in2^numfill("set",1,2)
halt
EOF
$gtm_tst/com/dbcheck.csh -extr
##########################################
source $gtm_tst/com/bakrestore_test_replic.csh
#
$gtm_tst/$tst/u_inref/check_straight_nct.csh
echo "END of TEST1 NCT test"
#
echo "$MUPIP extract -format=bin extr.bin"
$MUPIP extract -format=bin extr.bin
if ($status) then
	echo "Extract failed"
	exit 1
endif
#
# create a db with straight collation without nct and load it from the previous extract
#
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh "mumps" 2 125 500
echo "$MUPIP load -format=bin extr.bin"
$MUPIP load -format=bin extr.bin >&! tmp.log
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep -v "Label" tmp.log
$gtm_tst/$tst/u_inref/check_straight.csh
$gtm_tst/com/dbcheck.csh
echo "END of TEST2 NCT test"
#
#
# create a db with straight collation with nct and load it from the previous extract
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh "mumps" 2 125 500
$gtm_tst/$tst/u_inref/enable_nct.csh
echo "$MUPIP load -format=bin extr.bin"
$MUPIP load -format=bin extr.bin >&! tmp.log
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep -v "Label" tmp.log
$gtm_tst/$tst/u_inref/check_straight_nct.csh
$gtm_tst/com/dbcheck.csh
echo "END of TEST3 NCT test"
#
##########################################
# create a db with reverse collation and nct and fill it
##########################################
#settings for reverse collation
source $gtm_tst/com/cre_coll_sl_reverse.csh  1
#
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "ID4"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps 2 125 1000 -col=1
$gtm_tst/$tst/u_inref/enable_nct.csh
## This call "do ^testnct" is disabled for replication due to a known bug C9B03-001658
## move this call immediately before "set ^prefix=^" , once the bug is fixed
if (! $?test_replic) then
	$gtm_exe/mumps -run %XCMD 'do ^testnct'
else
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps 2 125 1000"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/$tst/u_inref/enable_nct.csh"
	$gtm_tst/com/RF_START.csh
endif
$GTM << EOF
set ^prefix="^"
do in2^mixfill("set",15)
do in2^numfill("set",1,2)
halt
EOF
$gtm_tst/com/dbcheck.csh -extr
##########################################
unsetenv test_replic
$gtm_tst/$tst/u_inref/check_reverse_nct.csh
echo "END of TEST4 NCT test"
#
\rm extr.bin
echo "$MUPIP extract -format=bin extr.bin"
$MUPIP extract -format=bin extr.bin
#
# create a db with reverse collation without nct and load it from the previous extract
#
setenv gtm_test_sprgde_id "ID5"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh "mumps" 2 125 500  -col=1
echo "$MUPIP load -format=bin extr.bin"
$MUPIP load -format=bin extr.bin >&! tmp.log
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep -v "Label" tmp.log
$gtm_tst/$tst/u_inref/check_reverse.csh
$gtm_tst/com/dbcheck.csh
echo "END of TEST5 NCT test"

# create a db with reverse collation with nct and load it from the previous extract

setenv gtm_test_sprgde_id "ID6"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh "mumps" 2 125 500 -col=1
$gtm_tst/$tst/u_inref/enable_nct.csh
echo "$MUPIP load -format=bin extr.bin"
$MUPIP load -format=bin extr.bin >&! tmp.log
if ($status) then
	echo "Load failed"
	exit 1
endif
$grep -v "Label" tmp.log
$gtm_tst/$tst/u_inref/check_reverse_nct.csh
$gtm_tst/com/dbcheck.csh
echo "END of TEST6 NCT test"
