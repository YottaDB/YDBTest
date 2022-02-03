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
#
echo '# --------------------------------------------------------------------------------------------'
echo '# Test that DSE DUMP -ZWR (or -GLO) does not dump garbled records when max record size is small'
echo '# --------------------------------------------------------------------------------------------'

echo "# Create database with max-key-size=1019 and max-record-size=1"
$gtm_tst/com/dbcreate.csh mumps -key_size=1019 -record_size=1

echo "# Set ^x(sub) where sub is of length 1, 8, 9 and 1014 (max-possible-before-GVSUBOFLOW-error)"
$ydb_dist/yottadb -run %XCMD 'for i=1,8,9,1014 set ^x($translate($justify("s",i)," ","s"))=1'

# We only test ZWR format as the code is the same for both.
# And testing GLO means more complication since that does not work in UTF-8 mode.
set format = "ZWR"
echo "# Try dumping the ^x nodes using DSE DUMP -$format"
$ydb_dist/dse << DSE_EOF
open -file=$format.txt
dump -$format -block=3
DSE_EOF

echo "# Dump contents of file $format.txt. Verify subscripts of length 9 and 1014 do show up fine"
cat $format.txt

$gtm_tst/com/dbcheck.csh
