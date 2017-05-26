#!/usr/local/bin/tcsh -f
#########################
\touch NOT_DONE.OLI

$GTM << GTM_EOF
for  hang 1  quit:\$GET(^lasti(2,^instance))>2
for  hang 1  quit:\$GET(^lasti(3,^instance))>2
for  hang 1  quit:\$GET(^lasti(4,^instance))>2
GTM_EOF

set failed_once = "FALSE"

@ cnt = 1
while (1)
	if (-f OLI.STOP) break
	echo "===== BEGIN ONLINE INTEG TRY $cnt at `date` ====="
	# Randomly choose normal or fast integ
	set rand = `$gtm_exe/mumps -run rand 2`
	if (0 == $rand) then
		$MUPIP integ -online -region "*" -dbg
	else
		$MUPIP integ -online -fast -region "*" -dbg
	endif
	set ret = $status
	if (0 == $ret) then
		echo "===== ONLINE INTEG TRY $cnt finished successfully at `date` ======"
	else
		set failed_once = "TRUE"
		echo "===== ONLINE INTEG TRY $cnt returned with non-zero status = $ret."
	endif
	@ cnt = $cnt + 1
	# Randomly sleep anywhere between 15 to 30 secs to give a chance of invoking an online integ
	# in the middle of a backup/online reorg/GT.M updates
	set rand = `$gtm_exe/mumps -run rand 16`
	@ rand_sleep = 15 + $rand
	echo "====== Sleep for $rand_sleep seconds before the next ONLINE INTEG ======="
	sleep $rand_sleep
	$echoline
	$echoline
	$echoline
end
if ("TRUE" == "$failed_once") then
	echo "TEST-E-FAILED: One or more of the ONLINE INTEG runs above had failed."
else
	echo "All the ONLINE INTEG runs completed successfully"
endif	
\rm -rf NOT_DONE.OLI
\rm -rf OLI.STOP
