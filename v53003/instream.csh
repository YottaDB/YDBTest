#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# -------------------------------------------------------------------------------------
# for stuff fixed in V53003
# -------------------------------------------------------------------------------------
# C9E11002657 [Kishore]   GTM gives sig 11 when zbreak action has a do and earlier relink removed zbreaks
# C9I09003032 [Kishore]   Prevent malformed string literals from over-scanning EOL
# C9I09003039 [Narayanan] $NEXT function exposed a bad assert in op_gvname.c
# C9I09003044 [Narayanan] ZSHOW "G" implements process-private GVSTATS
# D9I10002706 [Narayanan] Nested fprintf calls lead to infinite loop of messages in util_output
# C9I05002987 [Narayanan] MUPIP REORG -UPGRADE should not be required for V5 created databases
# C9I11003054 [SteveJ]    GDE needs to default MM access method to NOBEFORE even if journaling not on
# C9B11001824 [Narayanan] Trigger TPFAIL error in MUPIP JOURNAL RECOVER and ensure proper message gets displayed
# C9I06002996 [Narayanan] Test MUPIP ENDIANCVT -OVERRIDE qualifier
# D9I11002713 [Narayanan] $ZJOBEXAM() at process start up gives a SIG-11
# C9I11003055 [Narayanan] GT.M fails with SIG-11 if multiple regions map to same database file
# D9I07002691 [Roger]     MUPIP LOAD -FORMAT=ZWR chokes on decimal values and ^%GO doesn't put UTF-8 in the label
# C9G04002783 [s7ss]      MUPIP BACKUP and MUPIP INTEG -REG should prevent M-kills from starting
# D9H12002672 [s7ss]      MUPIP BACKUP should release ALL CRIT before sleep-waiting for kill-in-progress
# C9I06002997 [s7ss]      MUPIP FREEZE should inhibit new kills and wait for ongoing kills to complete
# D9I10002703 [Narayanan] Test that buffer overflow scenarios with environment variables dont cause SIG-11s/cores
# -------------------------------------------------------------------------------------
#
echo "v53003 test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "D9I10002703"
#
setenv subtest_list_non_replic "C9E11002657 C9I09003032 C9I09003039 C9I09003044 D9I10002706 C9I05002987 C9I11003054"
setenv subtest_list_non_replic "$subtest_list_non_replic C9B11001824 C9I06002996 D9I11002713 C9I11003055 D9I07002691"
setenv subtest_list_non_replic "$subtest_list_non_replic C9G04002783 D9H12002672 C9I06002997"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
        setenv subtest_exclude_list "$subtest_exclude_list C9B11001824"
endif

# Disable D9I10002706 test on HPUX-HPPA as that has been observed to cause eternal hangs in add_inter (see D9I10-002706 folder)
if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list D9I10002706"
endif
# filter out subtests that cannot pass with MM
# C9I06002996	MM can't down dynamic downgrade
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list C9I06002996"
endif
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list C9I05002987"
else if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	if ("dbg" == "$tst_image") then
		# We do not have dbg V5 builds needed by the C9805002987 subtest so disable it.
		setenv subtest_exclude_list "$subtest_exclude_list C9I05002987"
	endif
endif
# If the platform/host does not have GG structured build directory, disable tests that require them
if ($?gtm_test_noggbuilddir) then
	setenv subtest_exclude_list "$subtest_exclude_list D9I10002703"
endif

$gtm_tst/com/submit_subtest.csh
echo "v53003 test DONE."
