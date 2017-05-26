#D9C03-002060 Writing long records to batch log file yields RMS-F-RSZ invalid record size
echo "Entering LONGRECORD subtest"
echo "d ^longrec"
echo "Redirect the output to longrecord.txt"
$GTM <<xyz >& longrecord.txt
d ^longrec
xyz
$tst_cmpsilent longrecord.txt $gtm_tst/$tst/u_inref/longrecord.ref
if $status == 0 then
	echo "PASSED from LONGRECORD test"
else
	echo "FAILED from LONGRECORD test"
endif	
echo "Leaving LONGRECORD subtest"
