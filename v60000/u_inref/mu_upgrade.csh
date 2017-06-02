#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!musr/local/bin/tcsh -f

cat >&! yes.txt <<EOF
yes
EOF

source $gtm_tst/com/resolve_conflict_MM_and_unicode.csh
# 32 bit versions (pre V53001) are removed on some hosts due to a bug in GDE.
# On hosts which also do not have icu 3.6 installed, versions V52001-V53004 cannot run in UTF8 mode.
# Which means there isn't any version in UTF8 mode that matches the below. So forcing M mode.
if ( $HOST:ar =~ {scylla,charybdis,bolt}) then
	$switch_chset M >&! disable_utf8.txt
endif
echo "# Randomly choose a prior version to create the database with master-map size as 128M"
set prior_ver=`$gtm_tst/com/random_ver.csh -gte V50000 -lte V53003`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
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
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo "# Switch to current version"
\rm -f *.o >& rm2.out	# remove .o files created by current version (in case the format is different)
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$GDE exit
$gtm_exe/mumps -run %XCMD "f i=1:1:10 s ^x(i)=i"
$MUPIP upgrade mumps.dat < yes.txt >&! upgrade.out
$gtm_tst/com/grepfile.csh "GTM-S-MUPGRDSUCC" upgrade.out 1
$gtm_tst/com/dbcheck.csh
