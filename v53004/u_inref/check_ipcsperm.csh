#!/usr/local/bin/tcsh -f

set file = $1
set expected = $2
set expected2 = $3

$tst_awk '{ if (5<NF){ line=$(NF-4)":"$(NF-3)":"$(NF-2)":"$(NF-1)":"$(NF) ; if (line == "'"$expected"'") print $0}}' ${file} >&! ${file}_filtered
if ("" != "$expected2") then
	$tst_awk '{ if (5<NF){ line=$(NF-4)":"$(NF-3)":"$(NF-2)":"$(NF-1)":"$(NF) ; if (line == "'"$expected2"'") print $0}}' ${file} >>&! ${file}_filtered
endif
if (2 <= `wc -l ${file}_filtered | $tst_awk '{print $1}'`) then
	echo "TEST-I-PASS ipcs permission check passed for the file $file" 
else
	echo "TEST-E-FAIL ipcs permission check failed. check $file"
	echo "Expected ipcs permissions were $expected and $expected2"
	echo "Check the actual ipcs permissions in $file"
endif
