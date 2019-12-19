#!/usr/local/bin/tcsh -f
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

# This test ensures that YottaDB throws the appropriate error message about an
# undefined variable when $translate is called for the first time with the first argument
# a defined variable and the second and third arguments undefined variables. In GTM version
# v63006, a bug was introduced that throws a sig-11 in UTF-8 mode or outputs nothing in M mode
# if the second and third arguments are undefined. Contrary to the GTM release notes, this bug
# was not actually fixed in version V63008 and was discovered after our v63008/gtm9093 test
# failed on a YottaDB build that included the v63008 changes.
$ydb_dist/mumps -r ydb511
