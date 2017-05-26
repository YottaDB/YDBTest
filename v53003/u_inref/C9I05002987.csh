#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2008, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# C9I05002987 MUPIP REORG -UPGRADE should not be required for V5 created databases

echo "# Randomly choose a prior V5 version to create the database first."
set prior_ver = `$gtm_tst/com/random_ver.csh -type V5`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
echo "$prior_ver" > priorver.txt
echo "Randomly chosen prior V5 version is : GTM_TEST_DEBUGINFO [$prior_ver]"
set linestr = "----------------------------------------------------------------------"
set newline = ""
echo $linestr
echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image

echo "Creating database using prior V5 version"
rm *.o	# remove .o files created by current version (in case the format is different)
# Disable mupip-set-version to V4 as that will disturb Fully Upgraded flag and in turn affect the static reference file
setenv gtm_test_mupip_set_version "disable"
$gtm_tst/com/dbcreate.csh mumps

echo "# Switch to current version"
rm *.o	# remove .o files created by prior version (in case the format is different)
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

if ("$test_encryption" == "ENCRYPT") then
	if (-f $gtm_dbkeys) then
		$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
	else
		unsetenv gtm_passwd
		unsetenv gtmcrypt_config
	endif
endif

# For some 64-bit platforms, the gld format could be different between prior_ver and curver
# So recreate gld file unconditionally.
mv mumps.gld priorver.gld
$GDE exit

echo "# Accessing the database using the current version."
echo "# Checking that DSE DUMP -FILE -ALL reports that FULLY UPGRADED is set to TRUE"

$DSE dump -file -all |& $grep -E "^Region|Database is Fully Upgraded"

$gtm_tst/com/dbcheck.csh

