#!/usr/local/bin/tcsh -f
setenv test_reorg "NON_REORG"
source $gtm_tst/com/polish_collate.csh
$gtm_tst/com/dbcreate.csh "mumps" 1 125 500 -c=1
$GTM << \aaa
d ^colfill("set",15)
h
\aaa
$MUPIP reorg -f=50
$MUPIP reorg -f=100
$GTM << \aaa
d ^colfill("ver",15)
zwr ^A
zwr ^B
h
\aaa
$gtm_tst/com/dbcheck.csh 
