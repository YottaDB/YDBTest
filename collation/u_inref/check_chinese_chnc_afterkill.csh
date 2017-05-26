#!/usr/local/bin/tcsh -f
echo "Checking ZWR output of globals a with Chinese data for the sample Chinese Collation after kill"
$GTM << \aaa >& chinese_chnc_afterkill.out
zwr ^a
zwr ^A
h
\aaa
diff $gtm_tst/$tst/inref/chinese_chnc_afterkill.txt chinese_chnc_afterkill.out >& chinese_chnc_afterkill.diff
if $status then
	echo "Globals with Chinese data with the sample Chinese collation after kill check FAILED"
	echo "Check chinese_chnc_afterkill.diff"
else
	echo "Globals with Chinese data with the sample Chinese collation after kill check PASSED"
	echo "Now verify data in application level"
	$GTM << aaa
	d vs^mixfill
	d vs1^mixfill
	h
aaa
endif
