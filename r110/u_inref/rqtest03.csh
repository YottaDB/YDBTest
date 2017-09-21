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

# This test is similar to rqtest05.csh (which does reverse and forward query) but this test only does reverse $query.
echo '# Test of reverse $query on local variables for NULL subscript handling to avoid infinite loops'

foreach lctstdnull (1 0)
	setenv gtm_lct_stdnull $lctstdnull
	$gtm_dist/mumps -run rqtest03
end
