#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 8 125 1000 4096 4096 4096 4096
$MUPIP set -journal=enable,on,before -reg "*" |& sort -f 
echo "Multi-Process GTM Process starts in background..."
setenv gtm_test_jobid 1
setenv gtm_test_jobcnt 3
$gtm_tst/com/imptp.csh >>&! imptp.out 
sleep 60
#
echo "Now GTM process ends"
$gtm_tst/com/endtp.csh >>& endtp.out
$gtm_tst/com/dbcheck.csh "-extract"
$gtm_tst/com/checkdb.csh   
#
$MUPIP set -journal=off -reg FREG
$MUPIP set -journal=off -reg GREG

setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh  >&! imptp.out 
sleep 60
echo "Now GTM process ends"
$gtm_tst/com/endtp.csh >>& endtp.out
$gtm_tst/com/dbcheck.csh "-extract"
$gtm_tst/com/checkdb.csh   
#
\mkdir ./save
\cp *.dat ./save
# 
unsetenv test_replic
setenv test_reorg "NON_REORG" 
echo "Extact from database..."
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! data1.glo
\rm -f tmp.glo
echo "$MUPIP journal -recover -backward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl -since="
$MUPIP journal -recover -backward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl -since=\"0 0:0:30\"
echo "$MUPIP journal -recover -backward *  -since="
$MUPIP journal -recover -backward "*" -since=\"0 0:0:30\"
$gtm_tst/com/dbcheck_filter.csh  
echo "Extact from database..."
$MUPIP extract tmp.glo >>& extract.out
if ($status) echo "Extract fails"
$tail -n +3  tmp.glo >! data2.glo
\rm -f tmp.glo
\rm *.dat
$MUPIP create |& sort -f 
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
echo "$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl"
$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl
$gtm_tst/com/dbcheck.csh 
$MUPIP extract tmp.glo >>& extract.out
if ($status) echo "Extract fails"
$tail -n +3  tmp.glo >! data3.glo
\rm -f tmp.glo
echo "diff data1.glo data2.glo"
$tst_cmpsilent data1.glo data2.glo
if ($status) echo "TEST falied in MUPIP recover -BACKWARD"
echo "diff data1.glo data3.glo"
$tst_cmpsilent data1.glo data3.glo
if ($status) echo "TEST falied in MUPIP recover -FORWARD"
