#!/usr/local/bin/tcsh -f
# Hash table overflow bug for short int
if ($test_reorg == "REORG") setenv test_reorg NON_REORG
$gtm_tst/com/dbcreate.csh mumps 9 
$gtm_exe/mumps -dir << \aaa
d ^manyvars("lcl","set",50000,1)
d ^manyvars("lcl","ver",50000,1)
d ^manyvars("gbl","set",5000,2)
d ^manyvars("gbl","ver",5000,2)
h
\aaa
$MUPIP reorg >& reorg.out
if ($status) echo "REORG FAILED"
$gtm_tst/com/dbcheck.csh -extract   
