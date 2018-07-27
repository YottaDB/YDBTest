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
set t = `date +"%b %e %H:%M:%S"`
echo "# FILTER RETURNING -1 (attempting to use the pipe device after the open fails will cause an IONOTOPEN error)"
$ydb_dist/mumps -run tpzsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo "# Checking the Sys Log"
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
$grep RESTRICTEDOP getoper.txt |& sed 's/.*%YDB-E/%YDB-E/'
echo ""
sleep 1

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


# TRIGGERING A FILTER IN A TP TRANSACTION
echo "# TRIGGERING A RESTART OF A TP TRANSACTION WITHIN A FILTER"
rm $ydb_dist/restrict.txt
cat > $ydb_dist/restrict.txt << EOF
PIPE_FILTER:tpfilter^gtm8877
EOF
chmod -w $ydb_dist/restrict.txt
$ydb_dist/mumps -run tprestartfn^gtm8877
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
set t = `date +"%b %e %H:%M:%S"`
$ydb_dist/mumps -run zsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo "# Checking the Sys Log"
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
$grep FILTERNEST getoper.txt |& sed 's/.*%YDB-E/%YDB-E/'
$grep COMMFILTERERR getoper.txt |& sed 's/.*%YDB-E-COMMFILTERERR/%YDB-E-COMMFILTERERR/'
echo ""
sleep 1

# NO LABEL SPECIFIED IN FILTER
rm $ydb_dist/restrict.txt
cat > $ydb_dist/restrict.txt << EOF
ZSYSTEM_FILTER
PIPE_FILTER
EOF
set t = `date +"%b %e %H:%M:%S"`
chmod -w $ydb_dist/restrict.txt
echo "# No label specified in filters"
$ydb_dist/mumps -run zsystemfn^gtm8877
$ydb_dist/mumps -run pipeopenfn^gtm8877
echo "# Checking th Sys Log"
$gtm_tst/com/getoper.csh "$t" "" getoper.txt
$grep RESTRICTSYNTAX getoper.txt |& sed 's/.*%YDB-E/%YDB-E/'
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
