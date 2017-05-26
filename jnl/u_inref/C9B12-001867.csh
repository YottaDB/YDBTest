#! /usr/local/bin/tcsh -f
# Journal recover should not look for previous generation if nochain is specified.
# in the new software, backward recovery does not support chain/nochain, so this subtest is removed from the jnl test. - zhouc - 05/07/2003
setenv gtmgbldir "mumps.gld"
source $gtm_tst/com/dbcreate.csh mumps 1 . . . 1000 256
$MUPIP set -file -journal=enable,on,before,buff=128 mumps.dat
$GTM <<xy
d rt^rdbfill
w "h 5",!  h 5
xy
$MUPIP set -file -journal=enable,on,before,buff=128 mumps.dat
$GTM <<xy
d rt^rdbfill
w "h 5",!  h 5
xy
$gtm_tst/com/dbcheck.csh 
mkdir ./save1 ; \cp {*.dat,*.mj*} ./save1
$gtm_tst/com/dbcheck.csh 
echo "Extact from database..."
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! dbextr.glo
if ($status) echo "TEST-E-tail command failed"
\rm -f tmp.glo
$MUPIP journal -recov -backward -since=\"0 1:00\" mumps.mjl 
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! recextr.glo
if ($status) echo "TEST-E-tail command failed"
\rm -f tmp.glo
diff dbextr.glo recextr.glo
