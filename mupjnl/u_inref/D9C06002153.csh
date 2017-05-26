#!/usr/local/bin/tcsh -f
#
$gtm_tst/com/dbcreate.csh mumps 1 
#
echo "Enable before image journaling"
if ($?test_replic == 0) then
	$MUPIP set -journal="enable,on,before" -reg "*"
endif
#
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
$GTM << gtm_eof
	d fill^d002153
gtm_eof
#
cp mumps.dat back.dat
#
echo "Region Seqno :"
$DSE dump -f >>& dump1.out
$grep "Region Seqno" dump1.out| $tst_awk '{num=split($0,items," "); print items[num]}'

echo "Backward recovering ......"
$MUPIP journal -recover -back -since=\"$time1\" "*" >>& rec_bak.log
set stat1=$status
#
$grep "Recover successful" rec_bak.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "D9C06-002153 test failed"
	cat rec_bak.log
	exit 1
endif
#
echo "Region Seqno again: "
$DSE dump -f >>& dump2.out
$grep "Region Seqno" dump2.out| $tst_awk '{num=split($0,items," "); print items[num]}'
#
echo "PASS"
$gtm_tst/com/dbcheck.csh -extract
