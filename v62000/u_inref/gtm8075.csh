#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "Test that buffer expansion for external and internal filters works fine in source/receiver server"

# Turn off gtmdbglvl as it might significantly increase test runtimes
unsetenv gtmdbglvl

source $gtm_tst/com/random_extfilter.csh 1	# sets gtm_tst_ext_filter_src and gtm_tst_ext_filter_rcvr env vars
setenv gtm_tst_ext_filter_spaces 1000		# override random choice to exactly 1000 so we know how much data goes through

$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096 -record_size=32000

$gtm_dist/mumps -run gtm8075

$gtm_tst/com/dbcheck.csh -extract
