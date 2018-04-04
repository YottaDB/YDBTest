#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Collation - collation of the trigger subscript range can only be
# tested at trigger execution.
#
# This test has two test cases and one trigger.
#
# The trigger uses a range of Hindi numbers from 1 to 9 but in reverse.
# Unicode numbers collate in byte order which means that a Unicode
# range of 1 to 9 will collate all numbers beginning with 1 before any
# number beginning with 2.
#
# Test case 1: Use the trigger as is and see a %YDB-E-TRIGSUBSCRANGE
# error message.
#
# Test case 2: Use the trigger and an accompanying collation library
# which reverses the collation, Hindi numbers now collate 9 to 1. This
# use will not generate the %YDB-E-TRIGSUBSCRANGE error message.

# trigger error handler to catch the TRIGSUBSCRANGE
setenv gtm_trigger_etrap 'set $ecode="" write $zstatus'

# Test uses specific GDE configuration
setenv gtm_test_spanreg 0

# create the alternate collation libraries
source $gtm_tst/com/cre_coll_sl_unicode_numeric.csh 1 HINDI

# create the GDE file for no collation
cat > default.gde << EOF
add -name hindinum -region=hindinum
add -region hindinum -dynamic_segment=hindinum
add -segment hindinum -file=hindinum.dat
change -segment DEFAULT -file=mumps.dat
EOF
$convert_to_gtm_chset default.gde

# create the GDE file for with collation
cat > unicode.gde << EOF
add -name hindinum -region=hindinum
add -region hindinum -collation_default=1 -dynamic_segment=hindinum
add -segment hindinum -file=hindinum.dat
change -segment DEFAULT -file=mumps.dat
EOF
$convert_to_gtm_chset unicode.gde

if ($?test_replic == 1) then
	if ($tst_org_host == $tst_remote_host) then
		cp *${gt_ld_shl_suffix} $SEC_SIDE
	else
		$rcp *${gt_ld_shl_suffix} "$tst_remote_host":$SEC_SIDE/
	endif
endif

# run without the collation libraries
setenv test_specific_gde $tst_working_dir/default.gde
$gtm_tst/com/dbcreate.csh mumps
echo "Should see %YDB-E-TRIGSUBSCRANGE"
$gtm_exe/mumps -run trigcolunicode >&! shoulderror.outx
$grep '%YDB-E-TRIGSUBSCRANGE' shoulderror.outx >&! /dev/null && echo "PASS %YDB-E-TRIGSUBSCRANGE seen"
source $gtm_tst/com/ydb_trig_upgrade_check.csh
$gtm_tst/com/dbcheck.csh
$echoline

# since the GLD and DAT files have no value, just delete them
rm *.dat *.gld
if ($?test_replic == 1) then
	if ($tst_org_host == $tst_remote_host) then
		rm $SEC_SIDE/*.{dat,gld}
	else
		$rsh "$tst_remote_host" "rm $SEC_SIDE/*.{dat,gld}"
	endif
endif

# run with the collation libraries
setenv test_specific_gde $tst_working_dir/unicode.gde
$gtm_tst/com/dbcreate.csh mumps
echo "Should not see %YDB-E-TRIGSUBSCRANGE"
$gtm_exe/mumps -run trigcolunicode >&! shouldnoterror.outx
$grep '%YDB-E-TRIGSUBSCRANGE' shouldnoterror.outx || echo "PASS %YDB-E-TRIGSUBSCRANGE not seen"
source $gtm_tst/com/ydb_trig_upgrade_check.csh
$gtm_tst/com/dbcheck.csh -extract

