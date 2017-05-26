#!/usr/local/bin/tcsh -f
# Test To do: 19
#----------------
#R1    R2    R3
#----------------
#     T1    T1
#     T2    T2
#T3
#T4
#     T5
#     T6    T6
#-----------------

#In above example, if recovery is done with only R1,R2 mjl files specified, T1, T2 and T6 should be placed in brokentn file.
#T3 and T4 should be played forward. T5 should be placed in losttn file.
# Test that complete transactions even if they happen in time ,
# AFTER the earliest broken transaction (in some other reg are not considered lost and are played forward without issues.
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 4
$gtm_tst/com/jnl_on.csh
echo "Starting updates now"
echo `date +'%d-%b-%Y %H:%M:%S'` > time1.txt
$GTM << GTMEND
do init^tpmultireg
do updaftrbrkn^tpmultireg
GTMEND
set time1=`cat time1.txt`
# Do backward recovery without specifying c.mjl
$MUPIP journal -recover -back -since=\"$time1\" a.mjl,b.mjl 
echo "DB Extract"
$MUPIP extract extract.glo
cat extract.glo
echo "Broken transaction file"
$gtm_tst/$tst/u_inref/extr_req_info.csh "b.broken"
echo "Lost transaction file"
$gtm_tst/$tst/u_inref/extr_req_info.csh "b.lost"
$gtm_tst/com/dbcheck.csh
