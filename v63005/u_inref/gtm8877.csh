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
#
#
#
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
setenv gtm_dist $ydb_dist
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out

echo "# NO RESTRICTIONS"
$ydb_dist/mumps -run zsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo ""


# FILTER RETURNING -1
cat > $ydb_dist/restrict.txt << EOF
ZSYSTEM_FILTER:filterfn^gtm8877
PIPE_FILTER:filterfn^gtm8877
EOF
chmod -w $ydb_dist/restrict.txt
echo "# FILTER RETURNING -1 (expect a COMMFILTERERR in the syslog in addition to the RESTRICTEDOP error)"
$ydb_dist/mumps -run tpzsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo ""


# FILTER RETURNING A STRING
rm $ydb_dist/restrict.txt
cat > $ydb_dist/restrict.txt << EOF
ZSYSTEM_FILTER:filterfn2^gtm8877
PIPE_FILTER:filterfn2^gtm8877
EOF
chmod -w $ydb_dist/restrict.txt
echo "# FILTER RETURNING A STRING"
$ydb_dist/mumps -run zsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo ""


# TRIGGERING A FILTER IN A TP TRANSACTION
echo "# FILTER INVOCATION IN A TP TRANSACTION"
$ydb_dist/mumps -run tpzsystemfn^gtm8877
$ydb_dist/mumps -run tppipeopenfn^gtm8877
echo ""


# FILTERS WHILE RESTRICTING ZSYSTEM AND PIPE_OPEN
rm $ydb_dist/restrict.txt
cat > $ydb_dist/restrict.txt << EOF
ZSYSTEM
PIPE_OPEN
ZSYSTEM_FILTER:filterfn2^gtm8877
PIPE_FILTER:filterfn2^gtm8877
EOF
chmod -w $ydb_dist/restrict.txt
echo "# FILTER WITH ZSYSTEM AND PIPE_OPEN RESTRICTED"
$ydb_dist/mumps -run zsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo ""


# RECURSIVE FILTERS
rm $ydb_dist/restrict.txt
cat > $ydb_dist/restrict.txt << EOF
ZSYSTEM_FILTER:reczsystfilter^gtm8877
PIPE_FILTER:recpipefilter^gtm8877
EOF
chmod -w $ydb_dist/restrict.txt
echo "# RECURSIVE FILTERS"
$ydb_dist/mumps -run zsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo ""

# NO LABEL SPECIFIED IN FILTER
rm $ydb_dist/restrict.txt
cat > $ydb_dist/restrict.txt << EOF
ZSYSTEM_FILTER
PIPE_FILTER
EOF
chmod -w $ydb_dist/restrict.txt
echo "# No label specified in filters"
$ydb_dist/mumps -run zsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
