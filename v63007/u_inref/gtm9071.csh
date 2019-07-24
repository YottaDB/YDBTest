#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
echo '# The ZMESSAGE command appropriately handles a Boolean expression within an argument; starting with V6.3-000 such an argument tended to cause a segmentation violation'

echo '# Trying "zmessage 1&1"'
echo '# Should print "%SYSTEM-E-ENO1, Operation not permitted"'
$gtm_dist/mumps -r %XCMD 'zmessage 1&1'
