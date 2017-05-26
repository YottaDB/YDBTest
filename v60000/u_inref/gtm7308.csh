#!/usr/local/bin/tcsh -f
setenv test_reorg NON_REORG
$gtm_tst/com/dbcreate.csh mumps 1 255 950 1024 . . . . . ALWAYS . -stdnull

# Test a couple of edge cases to make sure gvcst_put is creating correct index keys.
# Create a database with the following characteristics.
# Block size (in bytes)			1024
# Maximum record size			950
# Maximum key size			255
# Null subscripts			ALWAYS
# Standard Null Collation		TRUE

# In V55000, the following case causes a block split and the newly create index key ends in "1 0 0" instead of "0 0".
echo ""
echo "Case #1. ^x should NOT have an index key that is one byte too long."
$GTM << EOF
f i=1:1:150 s ^x(\$j(i,250))=1
h
EOF

# In V55000, the following case causes a block split and the newly create index key ends in "0 0 FF 0 0" instead of "0 0".
echo ""
echo "Case #2. ^nsgbl should NOT have an index key with double double nulls."
$GTM << EOF
s ^nsgbl("xyz","")="begin1"_\$j(" ",900)_"end1"
s ^nsgbl("xyz")="begin2"_\$j(" ",100)_"end2"
h
EOF

$gtm_tst/com/dbcheck.csh
