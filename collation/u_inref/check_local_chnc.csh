#!/usr/local/bin/tcsh -f
echo "From ZWR output testing local Chinese collation"
diff $gtm_tst/$tst/inref/local_chnc.txt local_chnc.out >&! local_chnc.diff
if $status then
	echo "Local Chinese collation test FAILED"
	echo "Check local_chnc.diff"
else
	echo "Local Chinese collation test PASSED"
endif
