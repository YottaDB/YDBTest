#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# C9905001114 [rog] check DSE find -sibling
# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
# Temporarily disable random spanning regions as the dse test is very sensitive to block layout which is affected
# by where each global maps to. Later we will enhance this test to work with a static .sprgde file this way
# dse + spanning regions is tested.
setenv gtm_test_spanreg 0

echo "DSE test Starts..."

setenv subtest_list "dse_all dse_cache dse_crit dse_spawn dse_add dse_change dse_dump dse_eval dse_exit"
setenv subtest_list "$subtest_list dse_find dse_integ dse_maps dse_open dse_overwrite dse_page "
setenv subtest_list "$subtest_list dse_remove dse_restore dse_save dse_shift"

if !($?test_replic) then
	setenv subtest_list "$subtest_list dse_chng_fhead C9905001114"
else
	setenv subtest_list "$subtest_list dse_updproc"
endif
# dse_cache can generate an arbitrarily large DB depending on how fast the machine is.
# Because of this, there is no reasonable upper limit to set within the test to preallocate
# a DB file to allow those platforms that cannot do dynamic file extensions when in MM access
# mode.  Therefore, don't run it.
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	setenv subtest_exclude_list "dse_cache"
endif
set dbname=`basename $0 .csh`
setenv gtmgbldir mumps.gld

$gtm_tst/com/submit_subtest.csh

echo "DSE test DONE."
unsetenv gtmgbldir
