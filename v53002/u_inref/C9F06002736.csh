#!/usr/local/bin/tcsh
#
# C9F06-002736 DSE MAPS -RESTORE has issues if total_blks is multiple of 512
# C9F06-002736 [Unix only] DSE CHANGE -FILE -COMMITWAIT_SPIN_COUNT new qualifier needs to be tested
# C9F06-002736 [Unix only] DSE DUMP -FILE should print Commit Wait Spin Count in Unix
#
$gtm_tst/com/dbcreate.csh mumps -alloc=511
cp mumps.dat bak.dat

# First test DSE MAPS -RESTORE on an empty database
# This used to cause a "Free blocks counter in file header" integrity error.
$DSE << DSE_EOF
	maps -restore
DSE_EOF
$gtm_tst/com/dbcheck.csh

# Then test DSE MAPS -RESTORE on a non-empty database
# This used to cause a "DBMBPINCFL" integrity error.
cp bak.dat mumps.dat
$GTM << GTM_EOF
	do ^c002736
GTM_EOF
$DSE << DSE_EOF
	maps -restore
DSE_EOF
$gtm_tst/com/dbcheck.csh

# Test DSE CHANGE -FILE -COMMITWAIT_SPIN_COUNT and DSE DUMP -FILE
# Should accept positive values including ZERO but not negative values
cp bak.dat mumps.dat
set searchstr = "Commit Wait Spin Count"
@ loopcnt = 0
foreach value (128 -1 512 -120 0 16)
	@ loopcnt = $loopcnt + 1
	$DSE << DSE_EOF >& dse_out_${loopcnt}.log
		dump -file
DSE_EOF
	grep "$searchstr" dse_out_${loopcnt}.log
	$DSE << DSE_EOF
	change -file -commitwait_spin_count=$value
DSE_EOF
end

$DSE << DSE_EOF >& dse_out.log
	dump -file
DSE_EOF
grep "$searchstr" dse_out.log

$gtm_tst/com/dbcheck.csh
