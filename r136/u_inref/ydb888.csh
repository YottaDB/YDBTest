#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# Test $ZGLD is a valid synonym for $ZGBLDIR'
echo '# $ZGLD, $ZG, $ZGBLDIR should all work'
$gtm_exe/mumps -run %XCMD 'write $zg'
$gtm_exe/mumps -run %XCMD 'write $zgld'
$gtm_exe/mumps -run %XCMD 'write $zgbldir'
