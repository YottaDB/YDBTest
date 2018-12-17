#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_fork_n_core() function in the SimpleThreadAPI. Note this test looks for generated core files and assumes they
# are created with the pattern "core*".
#
cp $gtm_tst/$tst/inref/forkncorenoenv.c .
cp $gtm_tst/$tst/inref/forkncorewithenv.c .
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist forkncorenoenv.c forkncorewithenv.c
$gt_ld_linker $gt_ld_option_output forkncorenoenv $gt_ld_options_common forkncorenoenv.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& forkncorenoenv.map
#
# Drive forkncorenoenv
#
echo "Driving forkncorenoenv"
forkncorenoenv
ls -1 core* >& /dev/null
if (0 == $status) then
    echo "forkncorenoenv: Core file found when this routine should not have generated one"
    set corename=`ls -1 core*`
    mv $corename hidden_unexpected_core_$corename
endif
#
# Try the "with environment" flavor
#
$gt_ld_linker $gt_ld_option_output forkncorewithenv $gt_ld_options_common forkncorewithenv.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& forkncorewithenv.map
#
# Drive forkncorewithenv
#
echo
echo "Driving forkncorewithenv"
`pwd`/forkncorewithenv
@ savestatus = $status
if (0 != $savestatus) echo "forkncorewithenv: Got return code $savestatus when expected return code 0"
ls -1 core* >& /dev/null
if (0 != $status) then
    echo "forkncorewithenv: Core file not found when this routine should have generated one"
else
    echo "forkncorewithenv: Expected core file found"
    set corename=`ls -1 core*`
    mv $corename hidden_expected_core_$corename
endif
