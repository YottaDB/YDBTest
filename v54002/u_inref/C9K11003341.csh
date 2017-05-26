#!/usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps

# create a database with a broken alignement
cp mumps.dat copy
cat copy >> mumps.dat
# integ should fail with DBMISALIGN
$MUPIP integ mumps.dat
# fix the issue by extending the database
$MUPIP extend -block=358 DEFAULT
# integ should pass
$MUPIP integ mumps.dat

# create a database with correct alignment, but wrong block count
$DSE change -file -total=111
# integ should fail with DBTOTBLK
$MUPIP integ mumps.dat
# fix the issue
$DSE change -file -total=1CB
# integ should pass
$MUPIP integ mumps.dat

$gtm_tst/com/dbcheck.csh
