#!/usr/local/bin/tcsh
unset backslash_quote
#To check how many of the carsh/stop's could not crash/stop.
set totalrun = `find . -name 'MUPIP*.log' | wc -l`
set badrun =  `find . -name 'MUPIP*.log' -exec $grep -E "NOTALIVE|MUPIPDIDNOTSTOP" {} \;  | wc -l `
@ allow = $totalrun * 2
if ($allow <  $badrun) then 
	# for 3 mupip's at most 2 bad run allowed (since each MUPIP*.log has three recover/rollback's
	# i.e. for interrupted/mupipstopd RECOVER and ROLLBACK, which have 2 rounds, a maximum of 4 misses are allowed.
	echo "TEST-E-TOO MANY MISSES, Out of $totalrun runs (i.e. $totalrun * 3 MUPIPs), $badrun MUPIPs (RECOVER/ROLLBACK) were missed." >>! check_timing.out
	find . -name 'MUPIP*.log' -exec $grep -E "NOTALIVE|MUPIPDIDNOTSTOP" {} \;  >>! check_timing.out
endif
echo "No of MUPIPs that could not be killed/stopped: $badrun (out of $totalrun * 3 MUPIPs)" >>!  check_timing.out
