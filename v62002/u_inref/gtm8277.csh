#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test does not play well with switching encryption between versions
if ("ENCRYPT" == "$test_encryption" ) then
	setenv test_encryption NON_ENCRYPT
endif

# Randomver excludes V54000 - V54001 in UTF-8 mode, switch to M mode
$switch_chset "M" >&! switch_chset.out

# Choose a prior version with LABEL 1 triggers
$gtm_tst/com/random_ver.csh -gte V54000 -lte V54001 > priorver.txt
set priorver = `cat priorver.txt`
if ("$priorver" =~ "*-E-*") then
	echo "No such prior version : $priorver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $priorver

# Switch to the prior version and load the trigger file
source $gtm_tst/com/switch_gtm_version.csh $priorver $tst_image
$gtm_tst/com/dbcreate.csh mumps 1 125 1024 2048

cat > trigger.trg <<EOF
+^a -commands=S,K -xecute="write \$reference,!"
EOF
$gtm_dist/mupip trigger -triggerfile=trigger.trg >&! trigger.trigout

# Switch to the current version and attempt an upgrade. Let the error checking
# pick up on the failure to upgrade
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$GDE exit >&! gdeupgrade.log
$MUPIP trigger -upgrade >&! upgrade.log

$gtm_tst/com/dbcheck.csh
