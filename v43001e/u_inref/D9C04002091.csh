#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "ENTERING D9C04002091"
source $gtm_tst/com/dbcreate.csh mumps

$gtm_exe/mumps -run d002091

$gtm_tst/com/dbcheck.csh -extract
echo "LEAVING D9C04002091"
