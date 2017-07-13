#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This subtest verifies that the MUPIP dongrade -version=V5 works correctly

cat >&! yes.txt <<EOF
yes
EOF

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# create DB with V6 db version. This can not be downgraded.
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mumps -run '%XCMD' 'set ^x=2'

$MUPIP downgrade mumps.dat -version=V5 < yes.txt

# Move the gld and database file to backup folder
mkdir bakup
mv mumps.* bakup/

echo "# Randomly choose a prior V5 version to create the database first."
set prior_ver = `$gtm_tst/com/random_ver.csh -type V5`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/ydb_temporary_disable.csh

echo "$prior_ver" > priorver.txt
echo "Randomly chosen prior V5 version is : GTM_TEST_DEBUGINFO [$prior_ver]"
set linestr = "----------------------------------------------------------------------"
set newline = ""
echo $linestr
echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image

echo "Creating database using prior V5 version"
\rm -f *.o >& rm1.out	# remove .o files created by current version (in case the format is different)
# Disable mupip-set-version to V4 as that will disturb Fully Upgraded flag and in turn affect the static reference file
setenv gtm_test_mupip_set_version "disable"
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_V5.out

echo "# Switch to current version"
\rm -f *.o >& rm2.out	# remove .o files created by current version (in case the format is different)
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$GDE exit

if ("$test_encryption" == "ENCRYPT") then
	if (-f $gtm_dbkeys) then
		$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
	endif
endif

echo $newline
echo "Change the MAC RECORD SIZE to that of BLOCK SIZE and create spanning node"
echo $linestr
$DSE change -fileheader -RECORD_MAX_SIZE=1024
$gtm_exe/mumps -run %XCMD 'set ^x=$j(" ",1024);'  #This will create spanning node
echo $newline
echo "Downgrade should fail as spanning node is present"
echo $linestr
$MUPIP downgrade mumps.dat -version=V5 < yes.txt
echo $newline
echo "Kill Spanning Node"
echo $linestr
$gtm_exe/mumps -run %XCMD 'kill ^x'
echo $newline
echo "Downgrade should fail as spanning node absent flag is not set yet"
echo $linestr
$MUPIP downgrade mumps.dat -version=V5 < yes.txt
$MUPIP integ -reg "*" -noonline
echo $newline
echo "Downgrade should fail as record size is not supported in V5 database"
echo $linestr
$MUPIP downgrade mumps.dat -version=V5  < yes.txt
$DSE change -fileheader -RECORD_MAX_SIZE=1008
echo $newline
echo "Downgrade should be successful"
echo $linestr
$MUPIP downgrade mumps.dat -version=V5  < yes.txt
echo $newline
echo "Set the max_key_size to value which is not supported in V5 database"
echo $linestr
$DSE change -fileheader -KEY_MAX_SIZE=300
echo $newline
echo "downgrade should fail as it max_key_size is not supported in V5 database"
echo $linestr
$MUPIP downgrade mumps.dat -version=V5  < yes.txt
echo $newline
echo "Change key size to value which is supported in V5"
echo $linestr
$DSE change -fileheader -KEY_MAX_SIZE=64
echo $newline
echo "Downgrade should fail as MAXIMUM KEY SIZE ASSURED field is FALSE in DB header"
echo $linestr
$MUPIP downgrade mumps.dat -version=V5  < yes.txt
$MUPIP integ -reg "*" -noonline
echo $newline
echo "Downgrade should success as MAXIMUM KEY SIZE ASSURED is set appropriately by above INTEG"
echo $linestr
$MUPIP downgrade mumps.dat -version=V5  < yes.txt
$gtm_tst/com/dbcheck.csh
