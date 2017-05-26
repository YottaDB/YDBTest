#!/usr/local/bin/tcsh
#
# D9E08-002477 JOB Interrupt puts IBS servers into a non functional state and breaks outofband
#

$gtm_tst/com/dbcreate.csh mumps 1 -key=200 -rec=400
$MUPIP set -region "*" -journal="enable,on,before" >& jnl.on

$GTM << GTM_EOF
	do ^d002477
GTM_EOF

# Check if JOBEXAM dump files were created for every MUPIP INTRPT that was sent through the above GT.M process
@ pid = `cat thread2.pid`
@ maxcnt = `cat thread2.numintrpts`
@ cnt = 0
@ actualcnt = 0
@ success = 1
while ($cnt < $maxcnt)
	@ cnt = $cnt + 1
	if (! -e GTM_JOBEXAM.ZSHOW_DMP_${pid}_${cnt}) then
		@ success = 0
	else
		@ actualcnt = $actualcnt + 1
	endif
end

@ gracecnt = $maxcnt / 2	# allow for 50% job interrupts to NOT create JOBEXAM files
if (($success == 0) && ($actualcnt < ($maxcnt - $gracecnt))) then
	echo "Test FAILED : $maxcnt MUPIP INTRPTs sent to pid=$pid but only $actualcnt GTM_JOBEXAM.ZSHOW_DMP* files found"
	echo ""
	ls -l GTM_JOBEXAM.ZSHOW_DMP*
	echo ""
endif

$gtm_tst/com/dbcheck.csh
