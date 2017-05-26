#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9I09003044 : ZSHOW "G" implements process-private GVSTATS
#

# Disable randomtn as CTN statistic will depend on db tn and we want a static reference file
setenv gtm_test_disable_randomdbtn

# Disable mupip-set-version as that will disturb CTN statistic and in turn affect the static reference file
setenv gtm_test_mupip_set_version "disable"

# Disable dupsetnoop as a few statistics (particularly NBW or TBW) will be affected by it
setenv gtm_gvdupsetnoop "0"

setenv gtm_poollimit 0 # This test measure GVSTATS and having gtm_poollimt randomly would cause issues.

# blocksize should be at least 1024 as otherwise ZSHOW "G" output can wrap in multiple lines and cause test reference file issues.
$gtm_tst/com/dbcreate.csh mumps 2 -key=255 -rec=1000 -block=1024
$gtm_tst/com/backup_dbjnl.csh bak "*.dat" cp nozip
#to test multiple global directories, copy the gld file into an alternate gld file
cp mumps.gld alternate.gld

$GTM <<GTM_EOF
	do test1a^c003044
GTM_EOF

$GTM <<GTM_EOF
	do test1b^c003044
	do test1c^c003044
	do test1d^c003044
GTM_EOF

$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat" mv
cp bak/*.dat .

# From this point on only mumps.gld is used

# Test case 1e) Do all sorts of database operations and make sure each counter is non-zero.
#
$GTM <<GTM_EOF
	do test1e^c003044
	do test1f^c003044
	do test1g^c003044
	do test1h^c003044
	do test1i^c003044
	do test1j^c003044
	do test1k^c003044
	do test1l^c003044
GTM_EOF

echo '# 2c) Test that $VIEW("GVSTATS",<reg>) statistics persist across shutdowns'
$GTM <<GTM_EOF
	do viewgvstats^c003044("NONZERO")
GTM_EOF

echo '# 3) Test that DSE DUMP -FILE -ALL outputs the gvstats in same order as $VIEW("GVSTATS") except for CTN.'
$DSE <<DSE_EOF >>&! dse_df_all.out
	find -reg=AREG
	dump -file -all
	find -reg=DEFAULT
	dump -file -all
DSE_EOF
$grep -E "^Region| : # of " dse_df_all.out >&! dse_df_all_stats.out
# Filter out Journaling related stats as journaling is only randomly turned on and crit data which depends on circumstance
setenv check_all "DFL :|DFS :|JFL :|JFS :|JBB :|JFB :|JFW :|JRL :|JRP :|JRE :|JRI :|JRO :|JEX :|CAT :|CFE :|CFS :|CFT :|CQS :|CQT :|CYS :|CYT :"
$grep -vE "$check_all" dse_df_all_stats.out

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access (mupip endiancvt)
echo "# 7) Test that MUPIP ENDIANCVT preserves the global statistics as part of endian converting the database file."
foreach dbfile (*.dat)
	echo "yes" | $MUPIP endiancvt ${dbfile} >>&! endiancvt_${dbfile}_1.log # convert to alternate endian
	set exitstatus = $status
	if ($exitstatus != 0) then
		echo "MUPIP ENDIANCVT I failed. See endiancvt_${dbfile}_1.log"
		cat endiancvt_${dbfile}_1.log
		exit -1
	endif
	$grep ENDIANCVT endiancvt_${dbfile}_1.log
	echo "yes" | $MUPIP endiancvt ${dbfile} >>&! endiancvt_${dbfile}_2.log # convert back to same endian
	set exitstatus = $status
	if ($exitstatus != 0) then
		echo "MUPIP ENDIANCVT I failed. See endiancvt_${dbfile}_2.log"
		cat endiancvt_${dbfile}_2.log
		exit -1
	endif
	$grep ENDIANCVT endiancvt_${dbfile}_2.log
end
echo '# Now check that statistics are still non-zero by invoking viewgvstats^c003044("NONZERO")'
$GTM <<GTM_EOF
	do viewgvstats^c003044("NONZERO")
GTM_EOF
#
echo "# 5) Test DSE CHANGE -FILE -GVSTATSRESET command."
echo '# At this point we know the file header has non-zero statistics (just now executed a viewgvstats^c003044("NONZERO"))'
echo "# Now do the dse change command and check that the statistics have been cleared."
$DSE <<DSE_EOF
	find -reg=AREG
	change -file -gvstatsreset
	find -reg=DEFAULT
	change -file -gvstatsreset
DSE_EOF
echo "# Verify that statistics have been cleared in file header"
$GTM <<GTM_EOF
	do viewgvstats^c003044("ZERO")
GTM_EOF

# 2d) Test read-only processes
$GTM <<GTM_EOF
	do test2d^c003044
GTM_EOF
echo "# Verify that read-only statistics are still non-zero in file header"
$GTM <<GTM_EOF
	do viewgvstats^c003044("READONLY")
GTM_EOF

#
# 8) Test that MUPIP INTRPT on an active GT.M process creates a GTM_ZSHOW_DUMP file with ZSHOW "G" stats.
# This test is not necessary since ZSHOW "*" is tested above (that it includes ZSHOW "G" stats) and there is
# a separate existing test (jobexam related test) that tests that MUPIP INTRPT results in ZSHOW "*"
#
# 9) Process private global access statistics will be gathered only for regions whose corresponding segments have an
#    access method of BG or MM in the global directory. For regions with other access methods, for example GT.CM GNP
#    which maps a region/segment to a remote database file, ZSHOW "G" will not report any process private statistics even
#    though aggregated statistics (across all processes) will continue to be gathered in the remote database file header.
#
#	--> This is tested by doing ZSHOW "G", VIEW "GVSTATSRESET" and $VIEW("GVSTATS",<reg>) in
#		test/gtcm_gnp/inref/gtcm.m (which runs as part of the gtcm_gnp/basic subtest)
#
$gtm_tst/com/dbcheck.csh -nosprgde
