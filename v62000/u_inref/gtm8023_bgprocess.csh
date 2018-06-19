#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# print timestamps at each step - it is useful to debug and this output is not part of reference file
set bgpids = ""

# Get the offset of "Dirty Global Buffers" to change it via dse cache -change
$gtm_tools/offset.csh node_local gtm_main.c | $grep wcs_active_lvl >&! offset.out
# offset = 0904 [0x0388]      size = 0004 [0x0004]    ----> wcs_active_lvl
set offset = `$tst_awk '{printf("%X",$3)}' offset.out`
set size = `$tst_awk '{printf("%X",$7)}' offset.out`

# Start a mumps process that fails while attempting an update - wait till it becomes primary and then succeeds
$gtm_exe/mumps -run gtm8023 >&! bgmumps1.out &
set bgpids = "$bgpids $!"

# Start a mumps process that does only reads and waits for it to become primary and do an update
$gtm_exe/mumps -run readonly^gtm8023 >&! bgmumps2.out &
set bgpids = "$bgpids $!"

# Wait for gtm8023.m to try an update and fail with SCNDDBNOUPD
# Artificially inflate "Dirty Global Buffers" and freeze the instance
# Since the instance is frozen, gtm8023.m should not be able to do a zwrite of ^global, unable to flush buffers
# Previously a SCNDDBNOUPD error would detach from jnlpool making instance freeze not honorable
date
$gtm_tst/com/wait_for_log.csh -log bgmumps1.out -message "SCNDDBNOUPD"


$MUPIP replic -source -freeze=on -comment="FREEZE_BY_BGPROCESS.csh"
$DSE dump -f -a | & $grep -E "Global Buffers"
$DSE cache -change -offset=$offset -val=FE -size=$size >&! dsechange.out
$DSE dump -f -a | & $grep -E "Global Buffers"
date >&! freeze.done

date
$gtm_tst/com/wait_for_log.csh -log bgmumps1.out -message "do a zwrite of global" -grep
date
# The below should not be seen, as the instance is frozen
$gtm_tst/com/wait_for_log.csh -log bgmumps1.out -message "noreorg(1)" -duration 15 -grep
date

# Restore the original "Dirty Global Buffers" (to prevent assert failures later) and turn freeze off
set oldval = `$tst_awk '/Old Value/ {printf ("%X",$11)}' dsechange.out`
$DSE dump -f -a | & $grep -E "Global Buffers"
$DSE cache -change -offset=$offset -val=$oldval -size=$size >&! dserevert.out
$DSE dump -f -a | & $grep -E "Global Buffers"
$grep 'Old Value' dsechange.out dserevert.out
$MUPIP replic -source -freeze=off

# Now that the freeze is lifted zwrite ^noreorg should have worked
$gtm_tst/com/wait_for_log.csh -log bgmumps1.out -message "noreorg(1)" -grep

# Start a process that does mupip backup continuously while the side is transitioning to primary
cat >&! bkgrnd_bkup.csh << CAT_EOF
#!/usr/local/bin/tcsh -f
@ run = 1
while (! -e bkgrndjobs.stop)
	mkdir bkup_\$run
	$MUPIP backup -online "*" bkup_\$run
	@ run++
	sleep 5
end
CAT_EOF

chmod +x bkgrnd_bkup.csh
./bkgrnd_bkup.csh >&! bkgrnd_bkup.out &
set bgpids = "$bgpids $!"

# Start a dse process that simply waits while the side is transitioning to primary
cat >&! bkgrnd_dse.csh << CAT_EOF
date
\$DSE << DSE_EOF
dump -file -all
spawn "$gtm_tst/com/wait_for_log.csh -log bkgrndjobs.stop -duration 3600 -waitcreation"
dump -file -all
DSE_EOF

date
CAT_EOF

chmod +x bkgrnd_dse.csh
./bkgrnd_dse.csh >&! bkgrnd_dse.out &
set bgpids = "$bgpids $!"

# Signal the main test that dse and mumps background processes have started so that it proceeds with -activate
# -activate should work despite the running dse/mumps/mupip processes
date >&! bgprocess.started

echo "$bgpids" >&! bg.pids
# END of the test
# Wait for all the background processes to exit
foreach pid ($bgpids)
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 600
	date
end
