#!/usr/local/bin/tcsh 
# to analyze if the expected jnl seqno's (or transaction numbers) are seen in the jnl extract file (or lost tn file, etc.)
# usage:
# analyze_jnl_extract.csh filename lowerlimit upperlimit [tn]
# if the 4th argument is "tn", analyzes transaction numbers, otherwise analyzes jnlseqno's.

set filename = $1
set ll = $2
set ul = $3
set tn = $4

if (! -e $filename) then
	# due to an open TR, an empty lost_tn file may not get created:
	# C9D12-002477 MUPIP JOURNAL should not create empty lost trans file
	if ((0 == $ll) && (0 == $ul)) then
		echo "lost transaction file empty"
		exit
	endif
	echo "TEST-E-NONEXIST $filename does not exist"
	exit 1
endif
$tst_awk -f $gtm_tst/com/analyze_jnl_extract.awk -F\\ -v ll=$ll -v ul=$ul -v tn=$tn $filename
