#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-7985 SIG-11 in MUPIP TRIGGER -TRIGGERFILE when using multi-line XECUTE code > 32K in each M line OR > 1Mb in total length

$gtm_tst/com/dbcreate.csh mumps 1 -rec=1048576 -block=4096 -global_buffer=16384

foreach linewidth (818 8180 8181 8182 81810)
	foreach maxstr (1048576 10485760)
		@ linesapprox = `expr $maxstr / $linewidth`
		@ num = 0
		while ($num < 3)
			@ nlines = $linesapprox + $num - 1
			echo " --> Testing linewidth = $linewidth : nlines = $nlines : linewidth * nlines = `expr $linewidth \* $nlines`"
			$gtm_exe/mumps -run xecutelimits $linewidth $nlines
			$gtm_exe/mupip trigger -noprompt -trigg=xecutelimits_${linewidth}_${nlines}.trg # file created in above step
			# grep the line #s where SAMPLE shows up to ensure those are exactly the line #s where multi-line XECUTE string
			# errors (if any) are reported by MUPIP TRIGGER -TRIGGERFILE above.
			$grep -n SAMPLE xecutelimits_${linewidth}_${nlines}.trg
			# Check whether trigger select works fine with such huge triggers. Redirect output to prevent reference file bloat
			cat /dev/null | $gtm_exe/mupip trigger -select >& trigselect_${linewidth}_${nlines}.out
			if ($status) then
				echo "TEST-E-FAIL : $gtm_exe/mupip trigger -select. See trigselect.out for details"
			endif
			# $gtm_exe/mupip extract -stdout -select="^#t" >& trigstdout.out
			@ num = $num + 1
		end
	end
end

$gtm_tst/com/dbcheck.csh -extract
