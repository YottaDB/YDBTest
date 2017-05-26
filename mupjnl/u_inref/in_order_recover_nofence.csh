#!/usr/local/bin/tcsh -f
# Test To do: 21
# Test that broken transactions are resolved in correct order
# R1, R2 and R3 represents regions while T1 and T2 represent multi-region transactions in time order
# ----------------
# R1    R2    R3
# ----------------
#       T1    T1
# T2    T2    T2
# -----------------
# If recovery is done with only R1,R2 mjl files specified, both T1 and T2 are considered broken
# Although T2 happened AFTER T1, no hash table maintenance happens for -FENCES=NONE so when we see 
# T2 in R1 and T1 in T2, both of them have unresolved regions so we cannot decide amongst them 
# which happened first. . So T2 could be played FIRST and T1 could be played SECOND
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 4
$gtm_tst/com/jnl_on.csh
echo "Do multi-region updates"
echo `date +'%d-%b-%Y %H:%M:%S'` > time1.txt
$GTM << GTMEND
do init^tpmultireg
do inorder^tpmultireg
GTMEND
set time1=`cat time1.txt`
# Do backward recovery without specifying c.mjl and fences
$MUPIP journal -recover -back -since=\"$time1\" -fences=none a.mjl,b.mjl 
echo "There should not be any .broken or .lost file"
ls *.broken
ls *.lost
echo "All the updates should be there in the database"
$MUPIP extract extract.glo
cat extract.glo

$gtm_tst/com/dbcheck.csh


