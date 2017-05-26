#!/usr/local/bin/tcsh -f
echo "From ZWR output testing local collation"
diff $gtm_tst/$tst/inref/local_polm.txt local_polm.out >&! local_polm.diff
if $status then
	echo "Local collation test FAILED"
	echo "Check local_polm.diff"
else
	echo "Local collation test PASSED"
endif
