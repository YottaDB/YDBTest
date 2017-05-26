#! /usr/local/bin/tcsh -f
# Mupip recover should work if freeze flag is set.
setenv gtmgbldir "mumps.gld"
source $gtm_tst/com/dbcreate.csh mumps 1 . . . 1000 256
$MUPIP set -file -journal=enable,on,before,buff=2308 mumps.dat
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
$GTM <<xy
d rt^rdbfill
w "h 5",!  h 5
xy
mkdir ./save1 ; \cp {*.dat,*.mj*} ./save1
$gtm_tst/com/dbcheck.csh 
echo "Extact from database..."
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! dbextr.glo
if ($status) echo "TEST-E-tail command failed"
\rm -f tmp.glo
$DSE << bbb 
ch -f -freeze=TRUE
quit
bbb
echo ""
$MUPIP journal -recov -backward mumps.mjl -since=\"$time1\"
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! recextr.glo
if ($status) echo "TEST-E-tail command failed"
\rm -f tmp.glo
diff dbextr.glo recextr.glo
