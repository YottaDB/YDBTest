#!/usr/local/bin/tcsh -f
if ( $#argv <= 1 ) then
	echo "check_chinese.csh requires two parameters" 
	echo "   param1: specifying the reference condition"
	echo "   param2: specifying full verify or partial verify"
	exit 1
endif

echo "Checking ZWR output of globals a and b with Chinese data for $1"
$GTM << \aaa >& chinese_$1.out
zwr ^a
zwr ^A
h
\aaa
diff $gtm_tst/$tst/inref/chinese_$1.txt chinese_$1.out >& chinese_$1.diff
if $status then
	echo "Checking globals with Chinese data for $1 FAILED"
	echo "Check chinese_.diff"
else
	echo "Checking globals with Chinese data for $1 PASSED"
	echo "Now verify data in application level"
	if ($2 == "partial") then
	$GTM << \ccc
	d vs^mixfill      
	d vs1^mixfill      
	h
\ccc
	else
	$GTM << \bbb
	d v^mixfill      
	d v1^mixfill      
	h
\bbb
	endif
endif
