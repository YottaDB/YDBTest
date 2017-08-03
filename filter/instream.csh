#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#Let's test switch_over test for filter this time
# This test does not use dual_fail anymore.
#
# Note: If a new test is added to the list of tests submitted, please update the file $warn_tools/multiple_tests.list
#

# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# pick a random version and run both combinations vs. the version being tested
# since the test  uses these environment variables if they are there, remove them so it will create fresh, correct ones
unsetenv tst_jnldir
unsetenv tst_remote_jnldir
unsetenv tst_bakdir
unsetenv tst_remote_bakdir
set save_tst_dir = $tst_dir
unsetenv tst_dir
unsetenv remote_ver
set save_tst_remote_dir = $tst_remote_dir
unsetenv tst_remote_dir
unsetenv bucket
unsetenv testresults_log
unsetenv test_distributed
unsetenv test_distributed_srvr
unsetenv test_num_runs

setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

# Do not exceed more than 128 (16 on AIX) MB align size as it otherwise may exhaust the memory (see <central_mem_exhausted_align>).
if ("AIX" == $HOSTOS) then
	@ align_limit = 32768
else
	@ align_limit = 262144
endif
if ($test_align > $align_limit) then
    setenv test_align $align_limit
    setenv tst_jnl_str `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
    echo "# Make sure align size is less than $align_limit" >>&! settings.csh
    echo "setenv test_align $test_align"	      >>&! settings.csh
    echo "setenv tst_jnl_str $tst_jnl_str"            >>&! settings.csh
endif

set minver = "V63000A"
set prior_ver = `$gtm_tst/com/random_ver.csh -gte $minver -rh $tst_remote_host`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver

echo "The prior version picked is GTM_TEST_DEBUGINFO: $prior_ver"
echo "$prior_ver" > priorver.txt

# The test switches between V4 and V5 version and encryption doesn't support that. Force -noencrypt
# Pass norandomsetting to gtmtest while submitting tests. See <gtmdbglvl_nonzero_V4_version>
setenv common_test_options "-t switch_over -o . -ro $SEC_DIR -replic -fg -norandomsettings -s $tst_src -noencrypt -nozip -report off"
if ($USER != "library") setenv common_test_options "$common_test_options -nm"
if ($test_collation == "COLLATION") then
	setenv common_test_options " $common_test_options -col $test_collation_no,$test_collation_def_file"
endif

# Disable gtmcompile, including the -dynamic_literals and -embed_source qualifiers, since prior versions complain.
# See comment in switch_gtm_version.csh
setenv gtm_test_dynamic_literals "NODYNAMIC_LITERALS"
setenv gtm_test_embed_source "FALSE"
unsetenv gtmcompile

if !($?gtm_root) then
	echo '$gtm_root not defined. cannot proceed'
	exit 1
endif
# This sleep is to avoid tst* name conflict between the switch_over test that we submit here and this filter test.
sleep 1
# The older versions should always run with pro image.

if (`expr $prior_ver "<" "V54001"`) then
	# Disable trigger extract comparison for versions that do not support triggers
	setenv gtm_test_extr_no_trig 1
endif

if (`expr $prior_ver "<" "V63000"`) then
	# Disable "-qdbrundown" and gtm_db_counter_sem_incr for versions prior to V63000
	setenv gtm_test_qdbrundown 0
	setenv gtm_db_counter_sem_incr 1
endif

set sub_test_options="$common_test_options"

echo "Trying current_version vs prior_version"
# sourcing switch_gtm_version.csh to avoid "if expression syntax" we sometimes get
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# switch_gtm_version.csh unconditionally sets $gtm_tools to the tools dir of current production version
# The test system (gtmtest.csh) relies on scripts in $gtm_tools
# Any new tools in $tst_ver used in the test system will not be visible in this case.
# So point gtm_tools to the correct path
setenv gtm_tools "${gtm_root}/$tst_ver/tools"

# We need to make sure that the current chset is the same one used in the following tests - gtmtest.csh may change it
if ($?gtm_chset) then
	if ("M" == $gtm_chset) then
		set gtm_chset_mode = "-nounicode"
	else
		set gtm_chset_mode = "-unicode"
	endif
else
	set gtm_chset_mode = "-nounicode"
endif
$gtm_test/$tst_src/com/gtmtest.csh $sub_test_options -v $tst_ver -rv $prior_ver -ri pro $gtm_chset_mode \
	 >>! ${prior_ver}.out1
if ($status) then
   echo "FAILED $tst_ver vs $prior_ver"
   cat $prior_ver.out1
   echo "__________"
endif

echo "Trying prior_version vs current_version"
if (`expr $prior_ver "<" "V60001"`) then
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver "pro"
else
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
endif
setenv gtm_tools "${gtm_root}/$tst_ver/tools"

$gtm_test/$tst_src/com/gtmtest.csh $sub_test_options -rv $tst_ver -v $prior_ver -pro -ri $tst_image \
	$gtm_chset_mode >>&! ${prior_ver}.out2
if ($status) then
   echo "FAILED $tst_ver vs $prior_ver"
   cat  $prior_ver.out2
   echo "__________"
endif

set search_dirs=`$grep Created *.out{1,2} | $tst_awk '{print $2}'`
foreach failure (`find $search_dirs -name diff.log`)
echo "FAILURE: Check $failure"
end
