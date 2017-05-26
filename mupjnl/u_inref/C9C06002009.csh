#!/usr/local/bin/tcsh -f
#
$gtm_tst/com/dbcreate.csh mumps 1
setenv gtmgbldir "mumps.gld"
#
if ($?test_replic == 0) then
	$MUPIP set -journal="enable,on,before" -reg "*"
endif
#
$GTM << gtm_eof
 d ^jnlrec
gtm_eof
#
#
echo "forward extract ......"
$MUPIP journal -extract -det -forward  mumps.mjl >>& ext_for.log
set stat1=$status
#
grep "Extract successful" ext_for.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "C9C06002009 TEST FAILED"
	cat ext_for.log
	exit 1
endif
#
echo "Printing the record types ......"
$tst_awk '{n=split($0,line,"::");split(line[n],rec,"\\");m=split(rec[1],it," "); if ((it[m] != "EPOCH") && (it[m] != "PBLK")){if(it[m] != "UTF-8") print it[m];else print it[m-1]}}' mumps.mjf
$gtm_tst/com/dbcheck.csh -extract
