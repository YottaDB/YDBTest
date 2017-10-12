#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###########################################################################

echo ""
echo "Test mumps ftok conflict"
echo "========================"

# Select a GT.M version with a database version which can be used by current.

set prior_ver = `$gtm_tst/com/random_ver.csh -gte V51000 -lte V54002B`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/ydb_temporary_disable.csh
echo "$prior_ver" > priorver.txt
\rm -f *.o >& rm1.out	# remove .o files created by current version (in case the format is different)

echo "Randomly chosen prior version is : GTM_TEST_DEBUGINFO [$prior_ver]"
echo "------------------------------------------------------------------"
echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image

echo "# Create database"

$gtm_tst/com/dbcreate.csh mumps 1 >&! priorver_dbcreate.out
mkdir old
cd old

echo "# Create global directory for old version"
$GDE_SAFE change -segment DEFAULT -file=../mumps.dat >&! priorvergde.out

echo "# Create global directory for current version"
mkdir ../new ; cd ../new
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
if ($gtm_test_qdbrundown) then
	echo "template -region -qdbrundown"		>>&! curver.gde
	echo "change -region DEFAULT -qdbrundown"	>>&! curver.gde
endif
echo "change -segment DEFAULT -file=../mumps.dat"	>>&! curver.gde

if (-e ../db_mapping_file) then
	# The old version has the db_mapping_file scheme, while the new version needs gtmcrypt.cfg scheme
	# Since the test alternates between the versions and also switch directories, created the files in the respective directories
	ln -s ../db_mapping_file ../old/db_mapping_file
	cp ../gtmcrypt.cfg .
	cd ../ ; $gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys tmp_gtmcrypt.cfg ; cd new
	cat ../tmp_gtmcrypt.cfg >>&! gtmcrypt.cfg
endif
$GDE @curver.gde >&! curvergde.out
if ($gtm_test_qdbrundown) then
	$MUPIP set -region DEFAULT -qdbrundown >&! set_qdbrundown.out
endif

echo "# Update database with old version and wait"
cd ../old
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
$gtm_exe/mumps -run dohang1^gtm6811 > updater.log &

@ sleepcount = 0
while ( ! -f running.txt && $sleepcount < 120)
    sleep 1
    @ sleepcount++
end
if ($sleepcount == 120) then
    echo '%GTM-E-TIMEOUT, Process not started in allotted time'
    exit 1
endif

echo "# Old mumps running"
echo "# Switch to current version"
cd ../new
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

echo "# Attempt to connect with current version"
$gtm_exe/mumps -run dowrite^gtm6811

echo "# Attempt a mupip rundown with current version"
$gtm_exe/mupip rundown -region DEFAULT >& rundown.log
$gtm_tst/com/check_error_exist.csh rundown.log VERMISMATCH MUNOTALLSEC

echo "# Switch to prior version"
cd ../old
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image

echo "# Stop old mumps"
$gtm_exe/mumps -run dostop^gtm6811

wait

echo "# Old mumps stopped"
echo "# Switch to current version"
cd ../new
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

echo "# Update database with new version and wait"
$gtm_exe/mumps -run dohang2^gtm6811 > updater.log &

@ sleepcount = 0
while ( ! -f running.txt && $sleepcount < 120)
    sleep 1
    @ sleepcount++
end
if ($sleepcount == 120) then
    echo '%GTM-E-TIMEOUT, Process not started in allotted time'
    exit 1
endif

echo "# New mumps running"
echo "# Switch to prior version"
cd ../old
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image

echo "# Attempt to connect with prior version"
$gtm_exe/mumps -run dowrite^gtm6811 >& connect.logx

# Different prior versions have different errors. Just make sure we got one.
$grep -qE 'GTM-E-(VERMISMATCH|DBIDMISMATCH|REQRUNDOWN)' connect.logx && echo Found expected error || echo Did not find expected error

echo "# Switch to current version"
cd ../new
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

echo "# Stop new mumps"
$gtm_exe/mumps -run dostop^gtm6811

wait

echo "# New mumps stopped"
$gtm_tst/com/dbcheck.csh
cd ..
