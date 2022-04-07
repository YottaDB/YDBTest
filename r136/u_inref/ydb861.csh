#!/usr/local/bin/tcsh -f
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

echo '---------------------------------------------------------------------'
echo '######## Test various $ZATRANSFORM() invocations for correctness ########'
echo '---------------------------------------------------------------------'

echo ""
echo "------------------------------------------------------------"
echo '# Test an assortment of $ZATRANSFORM() invocations some of which returned'
echo '# wrong values and/or failed with a sig-11. We do not expect any failures'
echo '# in these invocations and let the reference file check for expected values.'
echo '#'
echo '# Types of expressions tested as first parm of $zatransform():'
echo '# 1. Literal boolean expression'
echo '# 2. Simple variable based expression'
echo '# 3. Literal equality expression (added per discussion here: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1371#note_905033866)'
echo '# 4. Arithmetic expression'
echo '# 5. Literal expressions for 0 and 1.'
echo '# 6. Specify character via $zchar() expression'
echo '# 7. Character right before numerics in ASCII string (":")'
echo '# 8. Character right after numerics in ASCII string ("/")'
echo "------------------------------------------------------------"
$ydb_dist/yottadb -run ydb861
