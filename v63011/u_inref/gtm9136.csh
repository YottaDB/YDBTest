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

echo "# Test to verify that the [NO]FFLF device parameters and the ydb_nofflf environment variable"
echo "# work appropriately."
#
# Methodology: The gtm9136.m routine has 3 entry points (envset(), usefflf(), and usenofflf()). Each of these entry
#              points opens a file (name passed in) and does a 'WRITE "hi",#' command, closes the file and exits. For
#              the first of these entry points (envset(), no device options are used beyond 'NEW' so what gets written
#              is determined by the setting of gtm_nofflf. The other two entry points use the option specified in the
#              name (FFLF or NOFFLF). Note FFLF is the default setting. These tests combine envvar settings and this
#              entry point to create files that can be compared to two expected versions of the file (written with or
#              without the newline character on the end).
#
$echoline
echo "#"
set outfile = "gtm9136_run_envset_default"
set compfile = "gtm9136_fflf.txt"
echo "# Test 1: default (unset) value of ydb_nofflf - make run and compare output file to $compfile"
unsetenv ydb_nofflf # Unset in case came in set
$ydb_dist/yottadb -dir << EOF
do envset^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of default (unset) ydb_nofflf test unexpected - analyze - rc: $status"
else
    echo "PASS - output file had fflf"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_envset_nofflf_TRUE"
set compfile = "gtm9136_nofflf.txt"
echo "# Test 2: setting of ydb_nofflf to TRUE - make run and compare output file to $compfile"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nofflf gtm_nofflf TRUE
$ydb_dist/yottadb -dir << EOF
do envset^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of ydb_nofflf=TRUE test unexpected - analyze - rc: $status"
else
    echo "PASS - output file had just ff (no lf)"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_envset_nofflf_FALSE"
set compfile = "gtm9136_fflf.txt"
echo "# Test 3: setting of ydb_nofflf to FALSE - make run and compare output file to $compfile"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nofflf gtm_nofflf FALSE
$ydb_dist/yottadb -dir << EOF
do envset^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of ydb_nofflf=FALSE test unexpected - analyze - rc: $status"
else
    echo "PASS - output file had fflf"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_devop_fflf_default"
set compfile = "gtm9136_fflf.txt"
echo "# Test 4: Specifying the FFLF device parameter with ydb_nofflf unset - comparing against $compfile"
unsetenv ydb_nofflf
$ydb_dist/yottadb -dir << EOF
do usefflf^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of using FFLF parm with ydb_nofflf unset unexpected - analyze - rc: $status"
else
    echo "PASS - output file had fflf"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_devop_fflf_nofflf_FALSE"
set compfile = "gtm9136_fflf.txt"
echo "# Test 5: Specifying the FFLF device parameter with ydb_nofflf set to FALSE - comparing against $compfile"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nofflf gtm_nofflf FALSE
$ydb_dist/yottadb -dir << EOF
do usefflf^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of using FFLF parm with ydb_nofflf set to FALSE unexpected - analyze - rc: $status"
else
    echo "PASS - output file had fflf"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_devop_fflf_nofflf_TRUE"
set compfile = "gtm9136_fflf.txt"
echo "# Test 6: Specifying the FFLF device parameter with ydb_nofflf set to TRUE - comparing against $compfile"
# Verify use of FFLF device option overrides ydb_nofflf environment variable
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nofflf gtm_nofflf TRUE
$ydb_dist/yottadb -dir << EOF
do usefflf^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of using FFLF parm with ydb_nofflf set to TRUE unexpected - analyze - rc: $status"
else
    echo "PASS - output file had fflf"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_devop_nofflf_default"
set compfile = "gtm9136_nofflf.txt"
echo "# Test 7: Specifying the NOFFLF device parameter with ydb_nofflf unset - comparing against $compfile"
unsetenv ydb_nofflf
$ydb_dist/yottadb -dir << EOF
do usenofflf^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of using NOFFLF parm with ydb_nofflf unset unexpected - analyze - rc: $status"
else
    echo "PASS - output file had just ff (no lf)"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_devop_nofflf_nofflf_FALSE"
set compfile = "gtm9136_nofflf.txt"
echo "# Test 8: Specifying the NOFFLF device parameter with ydb_nofflf set to FALSE - comparing against $compfile"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nofflf gtm_nofflf FALSE
# Verify use of NOFFLF device option overrides ydb_nofflf environment variable
$ydb_dist/yottadb -dir << EOF
do usenofflf^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of using NOFFLF parm with ydb_nofflf set to FALSE unexpected - analyze - rc: $status"
else
    echo "PASS - output file had just ff (no lf)"
endif

$echoline
echo "#"
set outfile = "gtm9136_run_devop_fflf_nofflf_TRUE"
set compfile = "gtm9136_nofflf.txt"
echo "# Test 9: Specifying the NOFFLF device parameter with ydb_nofflf set to TRUE - comparing against $compfile"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_nofflf gtm_nofflf TRUE
$ydb_dist/yottadb -dir << EOF
do usenofflf^gtm9136("$outfile.txt")
EOF
diff $outfile.txt $gtm_tst/$tst/outref/$compfile >& $outfile.diff
if (0 != $status) then
    echo "Result of using NOFFLF parm with ydb_nofflf set to TRUE unexpected - analyze - rc: $status"
else
    echo "PASS - output file had just ff (no lf)"
endif

echo
