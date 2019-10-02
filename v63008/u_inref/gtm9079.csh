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
echo '# In V6.3-007, a failed zcompile call within a nested xecute will produce an incorrect error'
echo 'code. This issue was fixed in V6.3-008. This tests for whether the error code produced'
echo 'by attempting to zcompile a file, gtm9079A.m, that does not compile, within'
echo 'a xecute statement produces an incorrect error code.'

echo '# Verifying that the error code produced by zcompile when called within xecute'
echo 'on a file that does not compile is correct.'
$gtm_dist/mumps -r gtm9079
