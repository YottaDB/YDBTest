#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-8228 [nars] Test that releasing M-locks at process exit does not require crit

setenv gtm_test_spanreg     0		# Test requires traditional global mappings, so disable spanning regions
echo "Create TWO database files a.dat and mumps.dat"
$gtm_tst/com/dbcreate.csh mumps 2	# creates a.dat and mumps.dat
$gtm_exe/mumps -run gtm8228
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
#Do a multi-line input test for lke
$gtm_exe/mumps -run lketest^gtm8228 >& lke.out
echo 'Show that lke accepts multiple inputs by writing "show locks" twice to the input'
cat lke.out
echo
echo "Show that mupip accepts multi-line input by writing integ on one line and mumps.dat on another"
echo '$grep for "No errors detected by integ" in mupiptest.outx for success'
$gtm_exe/mumps -run mupiptest^gtm8228 >& mupiptest.outx
$grep "No errors detected by integ" mupiptest.outx
echo
$gtm_tst/com/dbcheck.csh
