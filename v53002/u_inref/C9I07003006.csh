#!/usr/local/bin/tcsh -f
#
# C9I07-003006 - Assert fail in op_unwind.c line 48 if runtime error in indirection & NEW in $ET
#
$gtm_tst/com/dbcreate.csh mumps 1

echo "# Test with error trap that does: NEW of Intrinsic Special Variable"
echo "# using mumps -run"
$gtm_exe/mumps -run test1^c003006
echo "# using do command in GTM"
$GTM << EOF
do test1^c003006
EOF

echo "# Test with error trap that does: NEW of a local variable"
echo "# using mumps -run"
$gtm_exe/mumps -run test2^c003006
echo "# using do command in GTM"
$GTM << EOF
do test2^c003006
EOF

echo "# Test with error trap that does: TSTART"
echo "# using mumps -run"
$gtm_exe/mumps -run test3^c003006
echo "# using do command in GTM"
$GTM << EOF
do test3^c003006
EOF

echo "# Test with error trap that does: Exclusive NEW"
echo "# using mumps -run"
$gtm_exe/mumps -run test4^c003006
echo "# using do command in GTM"
$GTM << EOF
do test4^c003006
EOF

$gtm_tst/com/dbcheck.csh
