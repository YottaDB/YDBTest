#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test to make sure that running "gtm_dist/mumps -run ^" will produce the correct error.'
echo '# previously caused an assert to fail in sr_unix/lref_parse.c.'
$gtm_dist/mumps -run ^
echo '# this should also produce the same error message.'
$gtm_dist/mumps -run fakeTag^
