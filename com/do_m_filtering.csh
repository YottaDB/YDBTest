#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# This script can be used to wrap a call to GT.M %XCMD in an safe environment for text filtering.
#

if (("" == "$1") || ("" == "$2")) then
	echo "usage:"
	echo "$gtm_test_com_individual/do_m_filtering.csh 'command' inputfile(s)"
	exit 1
endif

# if %XCMD doesn't exist, we can't do anything.
if (! -e $gtm_exe/_XCMD.m) then
	echo "TEST-E-M_FILTERING $gtm_exe doesn't support %XCMD."
	exit 1
endif

# if $tst_dir or $gtm_tst_out don't exist, we can't do anything.
if ((!($?tst_dir)) || (!($?gtm_tst_out)) || (! -e $tst_dir/$gtm_tst_out)) then
	echo "TEST-E-M_FILTERING tst_dir and/or gtm_tst_out not defined."
	exit 1
endif

# Switch to M mode, so it can parse anything, including invalid Unicode stuff.
# This is done manually since $switch_chset is not always availables as we are not always called in tests.

# Note that while unsetting the chset etc. we need to unset both gtm_chset and ydb_chset.
# Unsetting just gtm_chset is not enough as this script could be invoked by a yottadb process (e.g. a MUTEXLCKALERT
# causing the call graph : dse -> "gtmprocstuck_get_stack_trace.csh" -> "mtailhead.csh" -> "do_m_filtering.csh")
# in which case the yottadb process would have gtm_chset and ydb_chset set (even though the test system only set gtm_chset)
# and only unsetting gtm_chset will still let ydb_chset prevail resulting in a mismatch between ydb_chset and gtmroutines
# causing an INVOBJFILE error due to CHSET mismatch. Hence the call to "unset_ydb_env_var.csh" below in various places.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_chset gtm_chset
source $gtm_tst/com/unset_ydb_env_var.csh ydb_local_collate gtm_local_collate

setenv gtm_chset "M"
if (! -d $tst_dir/$gtm_tst_out/utilobj/$gtm_verno ) then
	mkdir -p $tst_dir/$gtm_tst_out/utilobj/$gtm_verno
endif

if (($?gtm_tst) && ($?tst)) then
	setenv gtmroutines "$tst_dir/$gtm_tst_out/utilobj/$gtm_verno($gtm_test_com_individual) $gtm_exe"
	if (-e $gtm_tst/$tst/inref) then
		setenv gtmroutines "$gtmroutines .($gtm_tst/$tst/inref .)"
	endif
else
	setenv gtmroutines "$tst_dir/$gtm_tst_out/utilobj/$gtm_verno($gtm_test_com_individual) $gtm_exe"
endif

# This need to be unset, otherwise if $argv[2-] contain Unicode, it won't be displayed correctly.
unsetenv LC_ALL

# Unset to help with speed
source $gtm_tst/com/unset_ydb_env_var.csh ydb_dbglvl gtmdbglvl

unsetenv ydb_app_ensures_isolation # in case it is set on test replay (else ZGBLDIRACC errors on non-existent gld file are possible)

cat $argv[2-] | $gtm_exe/mumps -run %XCMD $1
exit $status

