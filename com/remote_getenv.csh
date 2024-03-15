#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
## Usage: remote_getenv.csh <SEC_DIR>
#
if ($1 == "") then
	echo "Usage: remote_getenv.csh <SEC_DIR>"
	exit 1
endif
setenv srcdir $1
#############################################
# Read and Set environment as original host
#############################################
#temporarily, keep all env.csh
#if (-e $srcdir/env.csh) then
#	mv $srcdir/env.csh $srcdir/env.csh.old_`date +%H%M%S`
#endif
set tmp_time = "`date +%H_%M_%S`_$$"
if ( $?HOSTOS == "0" )  setenv HOSTOS `uname -s`
if ($HOSTOS == "SunOS") then
        # if running in UTF-8 locale, punctuation marks get displayed as their octal equivalents due to some tcsh bug
        # to work around this until tcsh is fixed, we transform such an output to what it should normally be.
	sed 's/\\\075/=/g' $srcdir/env.txt >&! $srcdir/env_$tmp_time.txt
	if ($status) then
       		echo "sed command failed during UTF8 solaris transformation in remote_getenv.csh"
	endif
	mv $srcdir/env_$tmp_time.txt $srcdir/env.txt
endif
sed 's/=/ "/;s/^/setenv /;s/$/"/' $srcdir/env.txt >&! $srcdir/env_$tmp_time.csh
source $srcdir/env_$tmp_time.csh
if (-e $srcdir/env_supplementary.csh) source $srcdir/env_supplementary.csh
if (-e $srcdir/env_individual.txt) then
	cat $srcdir/env_individual.txt | sed 's/=/ "/'| sed 's/^/setenv /' | sed 's/$/"/' >! $srcdir/env_individual.csh
	source $srcdir/env_individual.csh
endif
if (-e $srcdir/unsetenv_individual.csh) source $srcdir/unsetenv_individual.csh
# Check if $gtm_crypt_plugin inherited from the remote side is usable on this side. If not, unsetenv it so that we fall back to
# whatever the default configuration of encryption plugin is present on this side.
if ($?gtm_crypt_plugin) then
	if (! -e $gtm_dist/plugin/$gtm_crypt_plugin) then
		unsetenv gtm_crypt_plugin
	endif
endif
# encryption settings are in the test's directory (ie. $tst_general_dir)
if (-e $srcdir/../encrypt_env_settings.csh) then
	source  $srcdir/../encrypt_env_settings.csh >>&! $srcdir/encrypt_env_settings_source.out	# GTCM
else if (-e $srcdir/../../encrypt_env_settings.csh) then
	source  $srcdir/../../encrypt_env_settings.csh >>&! $srcdir/encrypt_env_settings_source.out	# multisite
endif

#in order to define system specifics on the remote server correctly
source $gtm_tst/com/set_specific.csh
# this will take care of gtmroutines and locale set up defintions along with other regular setups
source $gtm_tst/com/getenv.csh

# Check if the YottaDB build has ASAN enabled on the remote side of a multi-host test. If so, need to set
# ASAN_OPTIONS env var (among other things) on the remote side to disable leak check (LSAN) as that can cause failures.
# Note: Do this BEFORE the "source $gtm_tst/com/set_gtm_machtype.csh" step as that invokes YottaDB and would otherwise
# fail (due to memory leaks identified) in case ASAN is enabled in the current build.
source $gtm_tst/com/set_ydb_build_env_vars.csh

# override machtype environment from primary
source $gtm_tst/com/set_gtm_machtype.csh

# This script is called to set env vars on the remote side of a multi-host test. But for multi-host tests,
# "com/do_random_settings.csh" disables "gtm_statshare" (see reasoning in a comment there). So do the same
# here now that we are setting up the remote host env vars. Note that in addition to setting "gtm_statshare" to 0,
# we need to ensure "gtm_statsdir" is unset too as the update process and helpers now record statistics in a
# STATSDB database (since GTM-F132372 in GT.M V7.0-002). This is because "gtm_statsdir" comes in set to point
# to a local host test path in "com/submit_subtest.csh" and it is possible that path does not exist in the remote
# host (in which case the update process/helpers would encounter errors at startup trying to create the statsdb).
setenv gtm_statshare 0
unsetenv gtm_statsdir

