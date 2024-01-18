#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9400 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9400)

MUPIP REORG defers MUPIP STOP recognition while performing bit map adjustments after an action that frees
a block, which prevents such events from possibly causing KILLABANDONED and associated errors. Previously
REORG did not use such a deferral. The workaround was to stop the REORG with a CTRL-C. (GTM-9400)

CAT_EOF

echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps

echo "# Load 100,000 nodes into database to make sure later [mupip reorg] has some work to do while we try to [mupip stop] it"
$gtm_dist/mumps -run %XCMD 'for i=1:1:100000 set ^x(i)=$j(i,200)'

echo "# Try [mupip reorg] with fillfactor of 50, 10, 90 in a loop for 10 iterations and try to [mupip stop] the reorg each time"
echo "# At each stage, after the reorg is done, run a [mupip integ] to see if there is any integ error. We expect none."
echo "# Before YDB@57006c9f, we used to see KILLABANDONED integrity errors in the [mupip integ] output."
@ maxcnt = 10
@ cnt = 1
while ($cnt <= $maxcnt)
        foreach fillfactor (50 10 90)
		($gtm_dist/mupip reorg -fill=$fillfactor -region DEFAULT & ; echo $! >&! reorg_${cnt}_$fillfactor.pid) >&! reorg_${cnt}_$fillfactor.out
		# Sleep a random time between 1 to 1000 milliseconds before issuing the [mupip stop] to the reorg pid.
		$gtm_dist/mumps -run %XCMD 'hang 0.001*$random(1000)'
		set bgpid = `cat reorg_${cnt}_$fillfactor.pid`
		$gtm_dist/mupip stop $bgpid >& mupip_stop_$bgpid.out
		$gtm_tst/com/wait_for_proc_to_die.csh $bgpid
		# Strip FORCEDHALT message if present as otherwise it will be caught by test framework
		$gtm_tst/com/check_error_exist.csh reorg_${cnt}_$fillfactor.out "FORCEDHALT" >>& FORCEDHALT.logx
                $gtm_dist/mupip integ -reg "*" >& integ_${cnt}_$fillfactor.out
                if ($status) then
                        touch STOP
                        break
                endif
        end
        if (-e STOP) then
                break
        endif
	@ cnt = $cnt + 1
end

if (! -e STOP) then
	echo "PASS : [mupip integ] reported no errors (including KILLABANDONED)"
else
	echo "FAIL : [mupip integ] reported errors (likely KILLABANDONED)"
endif

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
