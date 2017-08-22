#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2001-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Simplistic tests of direction (2nd) parameter to $query'

$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run rqtest00
$gtm_tst/com/dbcheck.csh
