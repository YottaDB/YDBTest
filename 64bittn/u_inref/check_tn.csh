#!/usr/local/bin/tcsh -f

echo "region : $1 , gvname : $2 , new_tn : $3"
echo "Current transaction Number before updates"
$DSE << dse_eof >&! dse_dump_1_$3
find -region=$1
dump -fileheader
quit
dse_eof
$tst_awk '/Current transaction/ { print $1,$2,$3}' dse_dump_1_$3
$MUPIP integ -region $1
echo ""
echo "Find the region and change the current transaction number to new_tn"
$DSE << dse_eof
find -region=$1
change -fileheader -current_tn=$3
quit
dse_eof
$MUPIP integ -region $1
echo ""
echo "Do the updates : call ^updates(""$2"")"
$GTM << gtm_eof
do ^updates("$2")
halt
gtm_eof
$MUPIP integ -region $1
echo ""
echo "Current transaction Number after updates"
echo ""
$DSE << dse_eof >&! dse_dump_2_$3
find -region=$1
dump -fileheader
quit
dse_eof
$tst_awk '/Current transaction/ { print $1,$2,$3}' dse_dump_2_$3
echo ""
echo "********* end of loop ***************"
echo ""
echo ""

