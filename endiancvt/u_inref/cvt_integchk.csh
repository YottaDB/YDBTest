#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script does the following simple steps.
# It is in a script because, the steps need to be executed in the remote side
# dbcreate.csh called by transaction_nos.csh
echo "# Run mupip integ, do the same set of updates and run mupip integ again"  >&! cvt_integchk_integ.out
$MUPIP integ -region "*"  >>&! cvt_integchk_integ.out
$gtm_exe/mumps -run populate
$MUPIP integ -region "*"  >>&! cvt_integchk_integ.out
# This script is invoked inside an ssh call to secondary.  beowulf has issues in intermingling while printing stdout/stderr.
# To avoid this, the outputs are redirected and printed at the end.
cat cvt_integchk_integ.out
