#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7519: Various REORG -TRUNCATE fixes
#

setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"
@ blksz = 512
@ recsz = $blksz
$gtm_tst/com/dbcreate.csh mumps 1 255 $recsz $blksz . . 1

echo "# Put something in the database so REORG doesn't complain"
$gtm_exe/mumps -run %XCMD 'set ^nonemptydb=1'

echo "# Start alternating truncates and extends in the background. Block 512 oscillates into/out of existence."
foreach i (1 2 3 4 5)
	( $gtm_tst/$tst/u_inref/start_truncate_oscillator.csh >>&! start_truncate_oscillator_$i.out & ) >&! exectrunc_$i.out
end

echo "# Do some database updates that frequently read bitmap block 512"
setenv gtm_tp_allocation_clue 512
@ loops = 25
@ i = 0
while ($i < $loops)
        @ i = $i + 1
        $gtm_exe/mumps -run gtm7519
end

$gtm_tst/$tst/u_inref/close_truncate_oscillator.csh >>&! close_truncate_oscillator.out

$gtm_tst/com/dbcheck.csh
