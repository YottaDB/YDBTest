#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

echo '# D9D08-002352 $Q() fails on nodes with "" in last subscript'
#
foreach value (0 1)
	echo "# --------------------------------------------------"
	echo "# Testing with ydb_lct_stdnull env var set to $value"
	echo "# --------------------------------------------------"
	setenv ydb_lct_stdnull $value
	$GTM << GTM_EOF
	do ^d002352
	halt
GTM_EOF

end
