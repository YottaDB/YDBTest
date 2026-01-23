#!/usr/local/bin/tcsh -f
###########################################################
#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
###########################################################

# Sets up environments variables to allow direct running of tests of scripts in YDBTest/com -- for easier debugging
# Documentation for this script is in ../README.md under "Modular Testing"

# Unset some env vars that may otherwise cause confusion
source $gtm_test_com_individual/gtmtest_setup.csh

# Ensure gtm_tmp is unique for every different YDB version and machine architecture
setenv gtm_tmp /tmp/yottadb/${verno}_`uname -m`
mkdir -p $gtm_tmp

set __save_ver=`alias ver`   # save/restore `ver` alias because gtm_env.csh overwrites it

if ! ( -f $gtm_tools/gtm_env.csh ) echo "Can't find $gtm_tools/gtm_env.csh. Did you build it with YDBDevOps?" `false` || goto fail
if ! ( -d $gtm_tst/com ) echo "Can't find directory \$gtm_tst/com. Have you copied it using 'tsync' alias?" `false` || goto fail
source $gtm_tools/gtm_env.csh || goto restore_ver_fail
source $gtm_tst/com/set_specific.csh || goto fail
source $gtm_tst/com/set_icu_version.csh || goto fail
setenv gtm_ver $gtm_root/$verno
setenv tst_ver $gtm_verno   # may be overridden by: settest -v
setenv gtm_ver_noecho
setenv gtm_pct_list $gtm_ver/pct
setenv gtm_pct $gtm_ver/pct
setenv gtm_inc_list $gtm_ver/inc
setenv gtm_vrt $gtm_ver
setenv gtm_test_server_serial_no 00
setenv gtm_test_port_range 00

if ( ! $?test_background ) setenv test_no_background   # run test in the foreground

setenv tst_stdout 1   # default to limited verbosity unless user overrides it with -stdout argument

setenv TMP_FILE_PREFIX  "/tmp/__${USER}_test_suite_$$"
setenv test_list  ${TMP_FILE_PREFIX}_test_list
setenv test_list_1  ${TMP_FILE_PREFIX}_test_list_1
setenv exclude_file  ${TMP_FILE_PREFIX}_exclude
setenv submit_tests  ${TMP_FILE_PREFIX}_submit_tests
setenv submit_tests_temp  ${TMP_FILE_PREFIX}_submit_tests_temp
setenv tmpfile  ${TMP_FILE_PREFIX}_tmpfile
setenv run_all  ${TMP_FILE_PREFIX}_run_all

# Settings from defaults_common_csh
setenv gtm_test_st_list   # clear any vestiges of a previous settest run
source $gtm_test_com_individual/defaults.csh $gtm_test_com_individual/defaults_common_csh || goto fail
# Process caller's command line arguments
source $gtm_test_com_individual/arguments.csh $argv || goto fail
# Source the actual test version's defaults (imports default_csh and default_options_csh)
# per gtmtest, remove rm commands, which delete argument settings, (cleanup already done by defaults_common_csh above)

$grep -v "rm " $gtm_test_com_individual/defaults_csh | source $gtm_test_com_individual/defaults.csh - || goto fail

# Settings from gtmtest.csh
if ( -e $gtm_tools/check_utf8_support.csh ) setenv gtm_test_unicode_support `$gtm_tools/check_utf8_support.csh`
setenv is_tst_dir_ssd `$gtm_test_com_individual/is_curdir_ssd.csh $tst_dir`   # is $tst_dir on an SSD?
setenv tst_dir_fstype `$gtm_test_com_individual/get_filesystem_type.csh $tst_dir`   # filesystem of $tst_dir
setenv tmp_dir_fstype `$gtm_test_com_individual/get_filesystem_type.csh /tmp`
setenv is_tst_dir_cmp_fs `$gtm_test_com_individual/is_curdir_compressed_fs.csh $tst_dir`   # $tst_dir on compressed filesystem?
set encrypt_supported = `$gtm_tst/com/is_encrypt_support.csh $tst_ver $tst_image`
source $gtm_tst/com/set_fips_support.csh || goto fail
setenv gtm_test_noggusers 1
setenv gtm_test_noggtoolsdir 1
setenv gtm_test_noIGS 1
setenv gtm_test_temporary_disable 1
setenv gtm_server_location NONGG   # non is ok since cms_tools are obsolete
setenv gtm_remote_location NONGG   # non is ok since cms_tools are obsolete
setenv gtm_test_autorelink_support 1
setenv gtmtest_noxendian 1
set gtm_test_server_serial_no = 00
set test_dirn = `date +%y%m%d_%H%M%S`
setenv gtm_tst_out `mktemp -d $tst_dir/tst_${tst_ver}_${gtm_exe:t}_${gtm_test_server_serial_no}_${test_dirn}_XXX`  # unique
chmod 755 $gtm_tst_out   # ensures directory is accessible by other userids in the same group (e.g. gtmtest1)
setenv gtm_tst_out `echo $gtm_tst_out | sed -e "s|$tst_dir/||"`   # gtm_tst_out shouldn't have $tst_dir/ on the front

# Settings from submit.csh
limit coredumpsize unlimited
if ( ! -e $gtm_exe/mumps ) echo "No 'mumps' executable found at gtm_exe '$gtm_exe'. Is it built?" `false` || goto fail
source $gtm_tst/com/set_gtm_machtype.csh || goto fail
setenv test_pid_file /tmp/__${USER}_test_suite_$$.pid
echo $tst_dir/$gtm_tst_out >>! $test_pid_file
setenv gtm_test_debuglogs_dir $ggdata/tests/debuglogs/$gtm_tst_out
mkdir -p $gtm_test_debuglogs_dir
setenv gtm_test_local_debugdir $tst_dir/$gtm_tst_out/debugfiles/
mkdir -p $gtm_test_local_debugdir
touch $gtm_test_local_debugdir/excluded_subtests.list
touch $gtm_test_local_debugdir/test_subtest.info

source $gtm_tst/com/set_java_supported.csh >>! $gtm_test_local_debugdir/set_java_supported.log || goto fail

# Create symlink to test results directory
setenv tst   # default avoids "tst: Undefined variable" errors
setenv subtest   # default avoids "subtest: Undefined variable" errors
setenv subtests   # default avoids "subtests: Undefined variable" errors
if ( -e $test_list ) then
	setenv tst `cat $test_list | grep "\-t .*" | tail -1 | cut "-d " -f2`   # extract the last test specified in arguments
	setenv subtest `echo $gtm_test_st_list | grep -o '[^,]*$'`   # extract last subtest from comma-separated list
	setenv subtests "$gtm_test_st_list:as/,/ /"
	echo "Selecting test '$tst', subtest '$subtest' for 'runtest' to invoke. Results will go into \$r"
endif
setenv testname "${tst}_0"

# Settings from submit.awk
setenv SHELL /usr/local/bin/tcsh  # otherwise tests that use ZSYSTEM might fail (according to equivalent line in submit.awk)
setenv tst_general_dir $tst_dir/$gtm_tst_out/$testname
setenv tst_working_dir $tst_dir/$gtm_tst_out/$testname/tmp   # working dir that gtmtest runs the test in
mkdir -p $tst_working_dir
mkdir -p $tst_working_dir/$subtest
ln -fns $tst_general_dir $r
setenv tst_num 0
unsetenv test_replic   # if you have trouble with this variable, see submit.awk which forces it to 1 or MULTISITE
unsetenv test_gtm_gtcm_one

# Settings from submit_test.csh
setenv gtmgbldir mumps.gld
setenv DO_FAIL_OVER "source $gtm_tst/com/fail_over.csh"
setenv GTM "$gtm_exe/mumps -direct"
setenv YDB "$gtm_exe/mumps -direct"
setenv MUPIP "$gtm_exe/mupip"
setenv LKE "$gtm_exe/lke"
setenv DSE "$gtm_exe/dse"
setenv GDE "$gtm_exe/mumps -run GDE"
setenv GDE_SAFE "$gtm_tst/com/pre_V54002_safe_gde.csh"
setenv tst_tslog_filter
source $gtm_tst/com/set_gtmroutines.csh "M" || goto fail
setenv echoline 'echo ###################################################################'  # output generator
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_crash 0
setenv gtm_test_jobcnt 5
setenv gtm_test_repl_norepl 0
setenv gtm_test_jobid 0
setenv gtm_test_dbfillid 0
setenv gtm_test_is_gtcm 0
setenv gtm_test_is_unicode_aware "FALSE"   # for individual tests to reset when they use existing com files for UTF8 operations
setenv ydb_allow64GB_jnlpool `free -g | $tst_awk -f $gtm_tst/com/jnlpool_64GB_OK.awk`
setenv ydb_test_4g_db_blks 0   # Defined so we don't need to use "$?ydb_test_4g_db_blks" in all later usages
setenv gtmcompile ""
setenv gtmcompile "$gtmcompile -noline_entry"
setenv gtmcompile "$gtmcompile -dynamic_literals"
setenv gtmcompile "$gtmcompile -embed_source"
setenv gtm_test_qdbrundown_parms ""
if ! ($?gtm_test_qdbrundown) setenv gtm_test_qdbrundown 0
if ($gtm_test_qdbrundown) setenv gtm_test_qdbrundown_parms "-qdbrundown"
setenv test_jnldir $tst_general_dir/tmp
setenv test_bakdir $tst_general_dir/tmp/bak
setenv switch_chset "source $gtm_tst/com/switch_chset.csh"
setenv test_collation "NON_COLLATION"	# The default
setenv test_collation_value "default"
setenv test_collation_no 0
source $gtm_tst/com/collation_setup.csh || goto fail
setenv gtm_test_fake_enospc 0   # Don't fake ENOSPC (disk out-of-space) error (gtmtest sets this randomly)

# Set path as submit_test.csh does
if ( ! $?original_path ) setenv original_path "$path"   # set only the first time we run this
set path = ($original_path $gtm_tst/$tst/inref $gtm_tst/$tst/u_inref $gtm_tst/com .)

# Double-check that all dependencies have been set up
# Have to capture check_setup_dependencies.csh output because it outputs '0' on stdout, even on success
set setup_status = `source $gtm_test_com_individual/check_setup_dependencies.csh $gtm_test_com_individual`
if ( "$setup_status" != "0" ) then
	echo "TEST-E-SETUP. Some setup dependency is missing. The check failed with $setup_status"
	goto fail
endif
goto success

fail:
unalias vers versi versio   # remove unnecessary aliases defined by gtm_env.csh
alias ver "$__save_ver"   # restore ver alias
unset __save_ver
exit 1  # fail

success:
unalias vers versi versio   # remove unnecessary aliases defined by gtm_env.csh
alias ver "$__save_ver"   # restore ver alias
unset __save_ver
