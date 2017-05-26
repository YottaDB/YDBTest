#!/usr/local/bin/tcsh -f
echo "Checking ZWR output of globals a with Chinese data for default Collation"
$GTM << \aaa >& chinese_defc.out
zwr ^a
zwr ^A
h
\aaa
diff $gtm_tst/$tst/inref/chinese_defc.txt chinese_defc.out >& chinese_defc.diff
if $status then
	echo "Globals with Chinese data with default collation check FAILED"
	echo "Check chinese_defc.diff"
else
	echo "Globals with Chinese data with default collation check PASSED"
	echo "Now verify data in application level"
	$GTM << \aaa
	d v^mixfill      
	d v1^mixfill      
	h
\aaa
endif
