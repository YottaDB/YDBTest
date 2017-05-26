# Test To do: 23
# Test that a good transaction is not considered LOST even if happens AFTER a broken transaction 
# in some other region. The key is that as long as there is NO multi-region broken or lost 
# transaction that happened in this region, all transactions can be considered GOOD.
# ----------------
# R1    R2    R3
# ----------------
#       T1    T1
# T2    T2
#             T3
# -----------------
# If during the recovery only R2,R3 is specified, T3 should be considered LOST 
# because it happened AFTER T2 which is broken. But since region R3 contains T1 (before T3) 
# and that is a GOOD transaction (neither LOST nor BROKEN) T3 will also be considered GOOD (and not LOST).
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 4
$gtm_tst/com/jnl_on.csh
echo "Do tp updates now"
echo `date +'%d-%b-%Y %H:%M:%S'` > time1.txt
sleep 1
$GTM << GTMEND
do goodaftrbrkn^tpmultireg
GTMEND
set time1=`cat time1.txt`
$MUPIP journal -recover -back -since=\"$time1\" b.mjl,c.mjl
echo "DB Extract"
$MUPIP extract extract.glo
cat extract.glo
echo "Broken transaction file"
$gtm_tst/$tst/u_inref/extr_req_info.csh "b.broken"
echo "Lost transaction file"
$gtm_tst/$tst/u_inref/extr_req_info.csh "b.lost"
$gtm_tst/com/dbcheck.csh

