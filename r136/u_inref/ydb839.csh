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
echo "# Verify misspelt ISVs are not interpreted as valid ISVs"
echo '# Testing invalid ISVs $ZDEBUG and $ZSTASSS'
echo "# Expecting %YDB-E-INVSVN for both"
$gtm_dist/mumps -run ydb839
