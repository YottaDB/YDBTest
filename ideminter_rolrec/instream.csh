#!/usr/local/bin/tcsh -f
echo "IDEMPOTENT/INTERRUPTED/MUPIP_STOP'd RECOVER and ROLLBACK tests"

#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore 
source $gtm_tst/com/gtm_test_setbeforeimage.csh
setenv gtm_test_tp TP	# do TP transactions in imptp.m

if ($?gtm_test_replay) then
	source $gtm_test_replay
else
	# randomize block size ahead of dbcreate.csh to set align size correctly
	setenv tst_rand_blksize `$gtm_exe/mumps -run one^chooseamong 1024 2048 4096 8192`

	# Now check the incoming random align size and change it if required.
	@ align_bytes = `expr $test_align \* 512`
	if ($tst_rand_blksize >= $align_bytes) then
		while ($tst_rand_blksize >= $align_bytes && $test_align < 4194304)
			@ test_align = `expr $test_align \* 2`
			@ align_bytes = `expr $test_align \* 512`
		end
		set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
		setenv tst_jnl_str $tstjnlstr
	endif

	# Randomly set "gtm_fullblockwrites" to 1
	# This will make sure we test the full-block-writes code out very well.
	setenv gtm_fullblockwrites `$gtm_exe/mumps -run rand 2`

	# log all the randomly set env.variables in randsettings file
	# settings.csh is where most of the com scripts log their random settings. Append to it
	cat >> settings.csh << EOF
# Randomly chosen block size for dbcreate
setenv tst_rand_blksize $tst_rand_blksize
# Randomly chosen align size - in tst_jnl_str
setenv tst_jnl_str $tst_jnl_str
# Randomly set gtm_fullblockwrites to 1
setenv gtm_fullblockwrites $gtm_fullblockwrites

EOF

endif

setenv subtest_list "idemp_rollback_or_recover interrupted_rollback_or_recover mupipstop_rollback_or_recover"

$gtm_tst/com/submit_subtest.csh

echo "IDEMPOTENT/INTERRUPTED/MUPIP_STOP'd RECOVER and ROLLBACK tests ends"
