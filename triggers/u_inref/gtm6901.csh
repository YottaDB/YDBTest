#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Disable spanning regions for test specific region handling
setenv gtm_test_spanreg 0

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

$gtm_exe/mumps -run altreg^gtm6901

setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh caseA "*.dat *.gld" mv

echo "# CASE B: Test cases for removing the reloading-trigger logic (in trigger_source_read_andor_verify.c) as part of a ZPRINT ^x#"
setenv gtmgbldir a.gld
$GDE change -segment DEFAULT -file=a.dat >&! gde_a.out
$MUPIP create
if ($gtm_test_qdbrundown) then
	$MUPIP set -region DEFAULT -qdbrundown >>&! set_qdbrundown.out
endif

setenv gtmgbldir b.gld
$GDE change -segment DEFAULT -file=b.dat >&! gde_b.out
$MUPIP create
if ($gtm_test_qdbrundown) then
	$MUPIP set -region DEFAULT -qdbrundown >>&! set_qdbrundown.out
endif

# Running trigreload.m twice should not result in assert failure. The below was fixed.
# Assert failed in /usr/library/V990/src/get_src_line.c line 143 for expression (0 < srcsize)
echo "# Test 1 : zprint should not assert fail when the same trigger is loaded twice"
echo "# Test 2 : zprint should print previously loaded M-source for a trigger even if it is deleted concurrently"
echo "# Run trigreload.m to load same triggers using two different global directories"
$gtm_exe/mumps -run trigreload

echo "# Run testreload^trigreload and expect it to"
echo "#  a) print error messages and not assert fail"
echo "#  b) print previously loaded M-source when ^x# is concurrently deleted"
$gtm_exe/mumps -run testreload^trigreload

$gtm_tst/com/backup_dbjnl.csh caseB "*.dat *.gld" mv

echo "# CASE C: having a fresh a.dat after installing triggers in a multi-region db"
echo "          should not throw GVGETFAIL error due to residual information in DEFAULT region"

echo "# Create a multi-region database"
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps 2

echo "# Save a.dat to be restored later"
cp a.dat a.dat_save

echo "# Install trigger ^A with name triga"
$gtm_exe/mumps -run %XCMD 'w $ztrigger("item","+^A -command=Set -xecute=""write 123,!"" -name=triga")'
$gtm_exe/mumps -run %XCMD 'w $ztrigger("select","triga")'

echo "# Restored the saved (fresh) a.dat"
cp a.dat_save a.dat

echo '# write $ztrigger("select","triga") should not core with GVGETFAIL error, but simply not print anything'
$gtm_exe/mumps -run %XCMD 'w $ztrigger("select","triga")'

$gtm_tst/com/dbcheck.csh
