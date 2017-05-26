#!/usr/local/bin/tcsh -f
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
# Test that filter works correctly if a trigger is defined on the primary but not supported
# on the secondary
#

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh

$echoline
echo "Test that replication works through a receiver external filter with a trigger when secondary doesn't support them"
$echoline
echo

# We just need 2 instances
$MULTISITE_REPLIC_PREPARE 2
# We want the secondary to not support triggers, hence upper limit is V54003.
# We set the lowest version at V52000 to get some variation, but there are M functions in the
# filter code not supported below this version.
set remote_prior_ver=`$gtm_tst/com/random_ver.csh -gte V52000 -lte V53004`
if ("$remote_prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $remote_prior_ver"
	exit -1
endif
echo $remote_prior_ver >! priorver.txt     # for the reference file
setenv gtm_tst_ext_filter_rcvr "/usr/library/$remote_prior_ver/pro/mumps -run ^nosectrig"
# Tweak the config file so that the INST2 runs with remove version chosen
cp msr_instance_config.txt msr_instance_config.bak
$tst_awk '{if("INST2" == $1){if("VERSION:" == $2){sub("'$tst_ver'","'$remote_prior_ver'")};if($2 ~ "IMAGE"){sub("dbg","pro")}};print}' msr_instance_config.bak >&! msr_instance_config.txt
$MULTISITE_REPLIC_ENV
# Setup the LOG file for the source server
setenv SRC_LOG_FILE "$PRI_SIDE/SRC_`date +%H_%M_%S`.log"
$gtm_tst/com/dbcreate.csh mumps 1
$MSR START INST1 INST2
cat << CAT_EOF  > trig.trg
+^a -commands=SET -xecute="set ^b=9999"
CAT_EOF

$echoline
echo "Run a few normal updates and a trigger definition and modification"
$echoline
echo

$GTM <<EOF
s ^abc=1234
tstart
set ^a=3456
set ^b=7890
tcommit
EOF

$MUPIP trigger -triggerfile="trig.trg"

$GTM <<EOF
s ^a=1234
EOF

#
$gtm_tst/com/dbcheck.csh -extract
