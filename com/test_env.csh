#!/usr/local/bin/tcsh -f
###########################################################
#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
###########################################################

# This file sets up the environment so that YottaDB's gtmtest.csh can be invoked.
# It can be sourced by your ~/.cshrc after section "User-specific locations"
# If you need local-only changes to this file, add them as overrides in your .cshrc after sourcing this file

if ! ( -e /usr/local/bin/tcsh ) echo "Warning: to run gtmtest you must do: sudo ln -s /usr/bin/tcsh /usr/local/bin/tcsh"

if ! ( $?gtm_test_com_individual ) setenv gtm_test_com_individual $work_dir/YDBTest/com   # user's version of gtmtest scripts

if ! ( $?gtm_curpro ) setenv gtm_curpro $verno   # version to use to create test database files
setenv ydb_dist $gtm_root/$verno/$tst_image
setenv HOSTOS `uname -s`
source "$gtm_test_com_individual/ver.csh" --quiet $verno "$ydb_dist:q"   # set database version

setenv gtm_com $gtm_root/com
setenv ggdata $tst_dir   # but in com/defaults_csh, why it is set to $HOME?  GG stands for GT.M Groups
setenv gtm_testver T${build_id}
setenv gtmgbldir mumps.gld
setenv gtm_icu_version `ldconfig -p | grep -m1 -F libicuio.so. | cut -d" " -f1 | sed 's/.*libicuio.so.\([a-z]*\)\([0-9\.]*\)/\2.\1/;s/\.$//;'`
setenv tst_src T${build_id}   # may be set to "" to add no Txxx no subdirectory to gtm_tst
setenv gtm_tst $gtm_test/$tst_src   # source of test scripts to test with

# The following are apparently needed by the test system, according to YDBDevOps:devtools/ydb_cshrc.csh
setenv gtm_test_do_eotf 0   # set whether to do eotf (encryption on the fly). gtmtest doesn't always set it
setenv gtm_test_noggsetup 1   # GG stands for GT.M Groups.
# Next variable is preset by YDB servers in /etc/csh.cshrc ( which calls $gtm_test/tstdirs.csh).
# But can't test its existence with $? so use env | grep as follows:
env | grep -q gtm_tstdir_$HOST= || setenv gtm_tstdir_$HOST "$gtm_test $gtm_test  "
setenv ydb_test_exclude_V5_tests 1   # switch off old tests because they didn't work on Ubuntu 20.04
setenv ydb_test_exclude_sem_counter 1   # most people are not set up to run the manually_start/sem_counter subtest
#limit descriptors 4096   # required to run on Debian 10 and Ubuntu 18.10
if ( $shlvl == 2 ) limit stacksize 32768 kbytes   # Required for clang builds; do only @shlvl 2 or v63000/gtm8394 will fail
setenv gtm_test_tls FALSE   # Without a default for this, gtmtest creates errors when -norandomsettings is selected


# Some tests won't tolerate any unusual prompts
unsetenv ydb_prompt
unsetenv gtm_prompt

mkdir -p $tst_dir
mkdir -p $gtm_root
mkdir -p $gtm_test

# Ensure these are defined. See .cshrc template for useful developer settings for $gtmtest_args
if ! ( $?gtmtest_args ) setenv gtmtest_args
if ! ( $?settest_args ) setenv settest_args "$gtmtest_args"


# Testing aliases
alias tsync '$gtm_test_com_individual/tsync.csh --info=stats0,flist0 \!*'   # sync YDBTest code from current dir to run dir
# note: tcsh is spawned for gtmtest to capture ^C and still run lasttest.csh
alias gtmtest    'tsync; tcsh -fc "$gtm_test_com_individual/gtmtest.csh $gtmtest_args \!*:q"; source $gtm_test_com_individual/lasttest.csh'
alias test_env   'source $gtm_test_com_individual/test_env.csh'   # refresh gtmtest environment setup
alias ver        'source $gtm_test_com_individual/ver.csh \!*'   # change version of database invoked by gtmtest
# settest/runtest and related aliases to set-up environment and collate results into $r
alias settest    'tsync; source $gtm_test_com_individual/settest.csh $settest_args \!*'
alias runscript  'tsync; tcsh -fc "cd $tst_working_dir/$subtest; source \\\$owd/\!*"'
alias runsubtest 'tsync; tcsh -fc "cd $tst_working_dir/$subtest; source $gtm_test_com_individual/submit_subtest.csh"'
alias runtest    'tsync; tcsh -fc "cd $tst_working_dir; source $gtm_test_com_individual/submit_test.csh"; source $gtm_test_com_individual/lasttest.csh'
alias difftest   'set _subtest="\!*:q"; if ( "$_subtest" == "" ) set _subtest="$subtest"; `git config diff.tool || echo diff` `git rev-parse --show-toplevel`/$tst/outref/$_subtest.txt $r/$_subtest/$_subtest.log'
alias debug      'source $gtm_test_com_individual/cshdebug.csh -k \!*'
# Remove test results older than 1 day (-mtime +1), but keep at least the most recent 1 tests (head -1)
# Don't define the following as a multi-line alias. It messes up postcmd like used in cshdebug.csh
alias cleantests 'set _latest_test=`find $gtm_test/ -maxdepth 1 -name "tst_*" -type d -exec ls -dt1 "{}" + | head -1`; find $gtm_test/ -maxdepth 1 -path "$_latest_test" -prune -o -name "tst_*" -type d -mtime +1 -exec rm -rf "{}" + || echo "error running 'cleantest' alias"; unset _latest_test'

# command-line completion for test specification via the -t switch
complete gtmtest 'c|*|`$gtm_test_com_individual/tstmatch.csh`|'
complete settest 'c|*|`$gtm_test_com_individual/tstmatch.csh`|'
# YottaDB historical names for these actions
alias s test_env
alias S test_env
alias rst tsync

# Build aliases -- these depend on YDBDevOps (not a public repository)
alias buildrel '$work_dir/YDBDevOps/devtools/buildrel.csh'
alias build 'buildrel $verno'
alias rebuild 'build -nof'

if ( ! $?original_path ) setenv original_path "$path"   # set only the first time we run this
set path = (. $original_path $gtm_tst/com/)

# If serverconf.txt doesn't exist, assume we're on localhost and create a dummy so tests don't complain
# You can create this file manually if you don't like it in your .cshrc-int
setenv gtm_test_serverconf_file $gtm_test/serverconf.txt
if ( ! -e "$gtm_test_serverconf_file" ) then
  mkdir -p $gtm_test
  echo >! $gtm_test_serverconf_file "# servername #buddy1(SE)  #buddy2(SE)  #buddy3(OE)  #GT.CM buddy1   #GT.CM buddy2   #alt server  syslog file       syslogpidfile           Java home"
  echo >> $gtm_test_serverconf_file "$HOST        NA           NA           NA           NA              NA              NA           /var/log/syslog   /var/run/rsyslogd.pid   NA"
endif

# Set up JAVA_HOME etc. (needed by test system)
setenv tst_awk awk
if ( -e $gtm_test_com_individual/set_java_paths.csh ) source $gtm_test_com_individual/set_java_paths.csh

# Set vars in gtm_env.csh -- needed to build with YDBDevOps, in case the user has that
if ! ( $?gtm_version_change ) setenv gtm_version_change 1   # needed for gtm_env.csh if $work_dir/YDB is set to a GT.M branch
set __save_ver=`alias ver`   # save/restore `ver` alias because gtm_env.csh overwrites it
  if ( -e $gtm_tools/gtm_env.csh ) source $gtm_tools/gtm_env.csh
  unalias vers versi versio   # remove unnecessary aliases defined by gtm_env.csh
alias ver "$__save_ver"
unset __save_ver
