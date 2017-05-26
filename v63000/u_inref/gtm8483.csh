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

#
# Verify that mupip jnl extract does not change the crash field.
#

source $gtm_tst/com/gtm_test_setbeforeimage.csh
setenv gtm_test_jnl SETJNL

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.log

echo "# Get the crash field left as TRUE"
$gtm_dist/mumps -run ^%XCMD 's ^x=1  zsy "kill -9 "_$j' #BYPASSOK
$MUPIP journal -show=header -forward -noverify mumps.mjl |& $grep Crash

echo "# Run the extract"
$MUPIP journal -extract -noverify -detail -for -fences=none mumps.mjl

echo "# Make sure journal extract does not reset it to FALSE"
$MUPIP journal -show=header -forward -noverify mumps.mjl |& $grep Crash

echo "# Make sure a recover goes just fine"
$MUPIP journal -recover -back -noverify "*"

$gtm_tst/com/dbcheck.csh
