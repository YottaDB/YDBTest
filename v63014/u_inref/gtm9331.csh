#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
echo '# GTM-9331 - Fixes issue when timer pops during an external call and that external call has its own signal'
echo '#            handling so the SIGALRM that pops to drive the timer handler gets handled by a different'
echo '#            handler so (in this test''s case) the $ZTIMEOUT never pops. This test actually tests this code'
echo '#	           two ways:'
echo '#              1. With the external call defined WITH the SIGSAFE keyword indicating it does no signal handling'
echo '#	                (which it actually does do).'
echo '#	             2. With the external call NOT defined with the SIGSAFE keyword.'
echo
echo '# Building call-in library and external call table'
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtm9331.c
$gt_ld_shl_linker ${gt_ld_option_output}libgtm9331${gt_ld_shl_suffix} $gt_ld_shl_options gtm9331.o $gt_ld_syslibs
rm gtm9331.o # Avoid interference with M routine compilations
#
setenv	GTMXC	gtm9331.tab
echo "`pwd`/libgtm9331${gt_ld_shl_suffix}" > $GTMXC   # Push out path to external call shared library
echo '# (note there are two external calls that call the same routine but one has SIGSAFE declared and the other does not'
cat >> $GTMXC << xx
sigwait1:	gtm_long_t	signalWait(I:gtm_uint_t):SIGSAFE
sigwait2:	gtm_long_t	signalWait(I:gtm_uint_t)
xx
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
$echoline
echo
echo '# Drive gtm9331 test routine (tests issue with $ZTIMEOUT)'
$gtm_dist/mumps -run gtm9331
$echoline
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
