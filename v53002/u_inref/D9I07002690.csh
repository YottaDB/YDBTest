#!/usr/local/bin/tcsh -f
#
# D9I07-002690 GTMASSERT in JNL_FILE_EXTEND.C;1 line 101 using V44004 at CSOB
#
# ------------------------------------------------------------------------------
unsetenv gtm_custom_errors	# The test explicitly tests journaling getting turned off. Instance freeze scheme
				# makes sure journaling is never turned off. So, unsetenv gtm_custom_errors.

echo "# Create database and turn on journaling"
$gtm_tst/com/dbcreate.csh mumps 1 . 512
$MUPIP set $tst_jnl_str -reg "*" >&! jnl_on.out
$grep "GTM-I-JNLSTATE" jnl_on.out

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 16

echo "# Start updates in the background"
$gtm_exe/mumps -run d002690

# ------------------------------------------------------------------------------
echo "# Allow some updates to happen while journaling is turned ON"
sleep 15

# ------------------------------------------------------------------------------
echo "# Manually make dskaddr to be out of sync with dsk (create an out-of-design situation)."
echo "# GT.M will respond to this by turning journaling OFF automatically."
echo "# This is done in a sequence of steps below."

set dselogprefix = "dse_out"

# DSE holds the crit lock while modifying dskaddr. But dskaddr is updated by GT.M concurrently using the jnl_qio lock
# Due to this, the following sequence might happen
# a) GT.M gets io_in_prog lock, computes dskaddr
# b) DSE whacks dskaddr
# c) Once the journal io is complete, GT.M sets dskaddr to the newly computed value
# With this timing, the final value of dskaddr will still be a valid one. (which we don't want to happen).
# To ensure we get out of design state, freeze the database ensures no more updates happen
# flush the buffer so we are guaranteed freeaddr and dskaddr are stable.Then find the dskaddr, compute new dskaddr and update
echo "# Do a mupip freeze"
$MUPIP freeze -on "*" >& freeze_on_all.out
$grep "All requested regions frozen" freeze_on_all.out
# We need to flush the journal buffers to ensure dskaddr is stable.
# else it could be concurrently updated as part of flushing the PFIN record written by recently executed MUPIP FREEZE -ON command.
echo "# Flush the journal buffers"
$GTM << EOF
view "jnlflush"
halt
EOF

set dselog1 = ${dselogprefix}_1.out
$DSE dump -file -all >&! $dselog1
# ------------------------------------------------------------------------------
echo "# Verify that journaling is currently turned ON"
$grep "Journal State " $dselog1 | sed 's/\(Journal Before imaging\)\(.*\)/\1 GTM_TEST_DEBUGINFO \2/'

# ------------------------------------------------------------------------------
echo "# Determine current values of dskaddr and freeaddr in journal buffer"
setenv hexdskaddr `$grep " Dskaddr " $dselog1 |& sed 's/.*Dskaddr *0x//g'`
setenv hexfreeaddr `$grep " Freeaddr " $dselog1 |& sed 's/.*Freeaddr *0x//g'`

# ------------------------------------------------------------------------------
echo "# Determine offset of jnl_buffer in shared memory"
set dselog2 = ${dselogprefix}_2.out
$DSE cache -show >&! $dselog2
setenv hexjnlbuffoffset `$grep " jnl_buffer_struct " $dselog2 |& sed 's/.* = 0x//g'`

# ------------------------------------------------------------------------------
echo "# Determine offset of dskaddr in journal buffer"
$gtm_tools/offset.csh jnl_buffer t_end.c >&! jnl_buffer_offset.out
setenv hexdskaddroffset `$grep -w dskaddr jnl_buffer_offset.out | sed 's/\].*//g;s/.*\[0x//g'`

# ------------------------------------------------------------------------------
echo "# Generate dse script that will change dskaddr to be out of sync with dsk"
setenv dsechangescript "dse_change_dskaddr_script.csh"
$gtm_exe/mumps -run dsechange^d002690 >&! dse_gtm.log

# ------------------------------------------------------------------------------
echo "# Invoke generated dse script"
set dselog3 = ${dselogprefix}_3.out
$DSE < $dsechangescript >&! $dselog3

# ------------------------------------------------------------------------------
echo "# Determine current values of dskaddr and freeaddr in journal buffer after the modification"
set dselog4 = ${dselogprefix}_4.out
$DSE dump -file -all >&! $dselog4

echo "# Unfreeze the database"
$DSE change -fileheader -freeze=FALSE -override
# ------------------------------------------------------------------------------
echo "# Verify that journaling does get turned OFF by GT.M as part of its updates (wait for a maximum of 2 minutes)"
set dselog5 = ${dselogprefix}_5.out
set wait_time = 120
while ($wait_time)
	$DSE dump -file -all >&! $dselog5
	$grep "Journal State                         OFF" $dselog5 >&! /dev/null
	if !($status) then
		break
	else
		sleep 1
		@ wait_time = $wait_time - 1
	endif
end
if (0 == $wait_time) then
	echo "TEST-E-TIMEOUT waiting for the journal state to be off"
	echo "No point in continuing the test without this state chage. Will exit the test. Check $dselog5"
	$gtm_exe/mumps -run stop^d002690
	exit
endif

$grep "Journal State " $dselog5 | sed 's/\(Journal Before imaging\)\(.*\)/\1 GTM_TEST_DEBUGINFO \2/'
echo "# Allow some updates to happen while journaling is turned OFF"
sleep 5

echo "# Switch to new journal file"
$MUPIP set $tst_jnl_str -reg "*" >&! jnl_on_again.out
$grep "GTM-I-JNLSTATE" jnl_on_again.out

echo "# Allow some updates to happen while journaling is turned BACK ON"
sleep 5

# ------------------------------------------------------------------------------
echo "# Verify that journaling is currently turned ON"
set dselog6 = ${dselogprefix}_6.out
$DSE dump -file -all >&! $dselog6
$grep "Journal State " $dselog6 | sed 's/\(Journal Before imaging\)\(.*\)/\1 GTM_TEST_DEBUGINFO \2/'

# ------------------------------------------------------------------------------
echo "# Stop GT.M updates"
$gtm_exe/mumps -run stop^d002690

# ------------------------------------------------------------------------------
echo "# Check integrity of database and cleanup"
$gtm_tst/com/dbcheck.csh
unsetenv gtm_white_box_test_case_enable
# ------------------------------------------------------------------------------
# End of Test.
