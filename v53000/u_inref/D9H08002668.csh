#!/usr/local/bin/tcsh -f
#
# D9H08-002668 MUPIP REORG hangs with lots of global variables in -SELECT qualifier
#
$gtm_tst/com/dbcreate.csh mumps

$gtm_exe/mumps -run d002668	# would have created file reorgselect.csh 

# Try reorg WITHOUT SELECT qualifier
$MUPIP reorg >& reorg_noselect.out
echo "Checking # of globals reported in REORG NOSELECT"
grep "Global:" reorg_noselect.out | wc -l | $tst_awk '{print $1}'	# Check that all globals we expect to show up do show up

# Try extract WITHOUT SELECT qualifier
$MUPIP extract noselect.ext >& extract_noselect.out
echo "Checking # of globals reported in EXTRACT NOSELECT"
grep "RECORDSTAT," extract_noselect.out | wc -l | $tst_awk '{print $1}'	# Check that all globals we expect to show up do show up

# Try reorg WITH SELECT qualifier
source reorgselect.csh >& reorg_select.out
echo "Checking # of globals reported in REORG SELECT"
grep "Global:" reorg_select.out | wc -l | $tst_awk '{print $1}'		# Check that all globals we expect to show up do show up

# Try extract WITH SELECT qualifier
source extractselect.csh >& extract_select.out
echo "Checking # of globals reported in EXTRACT SELECT"
grep "RECORDSTAT," extract_select.out | wc -l | $tst_awk '{print $1}'	# Check that all globals we expect to show up do show up

$gtm_tst/com/dbcheck.csh mumps

