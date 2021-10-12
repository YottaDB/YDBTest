#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#################################################################################################"
echo '###### Utility label $$SRCDIR^%RSEL returns space separated list of source code directories #####'

echo "# --------------------------------"
echo "# Run M test program"
echo "# --------------------------------"
$ydb_dist/yottadb -run ^ydb772
