#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# This test is for testing if empty host string in socket connection parameter causes assertion failure in debug build.'
echo '# This should issue YDB-E-GETADDRINFO instead of assert failure.'
$GTM << GTM_EOF
	do socket^ydb1076
GTM_EOF

