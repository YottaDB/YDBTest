#!/usr/local/bin/tcsh -f
echo "Checking ZWR output of globals a with Chinese data for the sample Chinese Collation"
$GTM << \aaa >& chinese_chnc.out
zwr ^a
zwr ^A
h
\aaa
diff $gtm_tst/$tst/inref/chinese_chnc.txt chinese_chnc.out >& chinese_chnc.diff
if $status then
	echo "Globals with Chinese data with the sample Chinese collation check FAILED"
	echo "Check chinese_chnc.diff"
else
	echo "Globals with Chinese data with the sample Chinese collation check PASSED"
	echo "Now verify data in application level"
	$GTM << \aaa
	d v^mixfill      
	d v1^mixfill      
	h
\aaa
endif
