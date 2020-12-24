#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that ZSHOW "*":lvn does not include the output of ZSHOW "I" in the'
echo '# "V" section of the zshow output into the lvn'
echo ""

echo '# Running : set x=1 zshow "*":array zwrite array("V",*) only shows x'
$ydb_dist/yottadb -run ^ydb558
