#!/usr/local/bin/tcsh -f

if (! $?test_replic) then
	echo "This subtest needs to be run with -replic. Exiting..."
	exit -1
endif
# Limit the compression value to 6 <C9J06_003139_failure/resolution_v4.txt>
if ($?gtm_test_replay) then
	# sourcing of the replay script would have been done already. No need to do anything now.
else if ( ($?gtm_zlib_cmp_level) ) then
	if ( ($gtm_zlib_cmp_level > 6) ) then
		set cmp_val = 6
		echo "# Resetting compression level at the test level"	>> settings.csh
		echo "setenv gtm_zlib_cmp_level $cmp_val"		>> settings.csh
		setenv gtm_zlib_cmp_level $cmp_val
	endif
endif
# With journaling, this test requires BEFORE_IMAGE in order to ensure same # of PBLKs get written on both sides
# so set that unconditionally even if test was started with -jnl nobefore 
source $gtm_tst/com/gtm_test_setbeforeimage.csh

# Create database, start replication servers
$gtm_tst/com/dbcreate.csh mumps

# Do updates with sleeps in between to trigger free epoch code
$GTM << GTM_EOF
	do ^c003139
GTM_EOF

# Let primary/secondary sync and then stop replication servers 
$gtm_tst/com/dbcheck.csh -extract -replon

# Check journal file sizes in primary and secondary are ALMOST identical
set prijnlcnt = `ls -1 *.mjl* | wc -l`
if ("$prijnlcnt" != "1") then
	echo "C003139-E-PRIJNLCNT : Count expected is 1 but is [$prijnlcnt]"
endif

setenv prijnlsize `ls -l mumps.mjl | $tst_awk '{print $5}'`

set secjnlcnt = `$sec_shell '$sec_getenv; ls -1 *.mjl* | wc -l'`
if ("$secjnlcnt" != "1") then
	echo "C003139-E-SECJNLCNT : Count expected is 1 but is [$secjnlcnt]"
endif

set secjnlls = `$sec_shell '$sec_getenv; cd $SEC_SIDE; ls -l mumps.mjl'`
setenv secjnlsize `echo $secjnlls | $tst_awk '{print $5}'`

# Now that we have both journal sizes, do the ALMOST identical check using an M program
$GTM << GTM_EOF
	do check^c003139
GTM_EOF

