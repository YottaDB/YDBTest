#!/usr/local/bin/tcsh -f
#
$gtm_tst/com/dbcreate.csh mumps 1
#
if ($?test_replic == 0) then
	$MUPIP set -journal="enable,on,before,auto=16448,alloc=2048,exten=100" -reg DEFAULT
endif
sleep 1
#
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
$GTM << gtm_eof
  f i=1:1:6000 s ^adata(i)="adata"_\$j(i,200)
  h 
gtm_eof
#
#
echo "Change auto limit"
 $MUPIP set -journal="enable,on,before,auto=32768,alloc=7168,exten=2048" -reg "*"
#
$GTM << gtm_eof
  ts ():(serial:transaction="BA")
  f i=1:1:10500 s ^bdata(i)="bdata"_\$j(i,20)
  tc
gtm_eof
#
echo "Change auto limit again"
 $MUPIP set -journal="enable,on,before,auto=23896,alloc=4096,exten=900" -reg "*"
$GTM << gtm_eof
  f i=1:1:9000 s ^cdata(i)="cdata"_\$j(i,200)
gtm_eof
#
echo "Backward recovery ......"
$MUPIP journal -recover -back -since=\"$time1\" mumps.mjl >>& rec_bak.log
set stat1=$status

$grep "Recover successful" rec_bak.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "C9C05001996 TEST FAILED"
	cat rec_bak.log
	exit 1
endif

$DSE dump -f >>& dump.out
set autolimit=`$grep " AutoSwitchLimit" dump.out | $tst_awk '{print $3}'`
set allocation=`$grep " Allocation" dump.out | $tst_awk '{print $3}'`
set extension=`$grep "Journal Extension" dump.out |$tst_awk '{print $6}'`
# autolimit = allocation + extension*3
if($autolimit != 31744 || $extension != 2048 || $allocation != 7168) then
	echo "C9C05001996 TEST FAILED because the file header settings are not right"
	cat dump.out
	exit 1
endif
echo "PASS"
$gtm_tst/com/dbcheck.csh -extract
