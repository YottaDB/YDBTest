#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
unsetenv gtm_local_collate
setenv gtm_chset "M"
if (! -d $tst_dir/$gtm_tst_out/utilobj/$gtm_verno ) then
	mkdir -p $tst_dir/$gtm_tst_out/utilobj/$gtm_verno
endif

if (($?gtm_tst) && ($?tst)) then
   setenv gtmroutines "$tst_dir/$gtm_tst_out/utilobj/$gtm_verno($gtm_test_com_individual) $gtm_exe .($gtm_tst/$tst/inref .)"
else
   setenv gtmroutines "$tst_dir/$gtm_tst_out/utilobj/$gtm_verno($gtm_test_com_individual) $gtm_exe"
endif

# This need to be unset, otherwise if $argv[2-] contain Unicode, it won't be displayed correctly.
unsetenv LC_ALL

# Unset to help with speed
unsetenv gtmdbglvl

cat $argv[2-] | $gtm_exe/mumps -run %XCMD $1
exit $status

