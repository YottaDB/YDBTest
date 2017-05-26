#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7688: REORG's READ_RECORD macro causes SIG-11; aggravated by MM
#

# Create a tiny database (10 blocks, 1 block extension size) with a tiny number of global buffers (64) if BG.
$gtm_tst/com/dbcreate.csh mumps 1 255 900 1024 10 64 1
$gtm_exe/mumps -run gtm7688
$gtm_tst/com/dbcheck.csh
