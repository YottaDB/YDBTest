#!/usr/local/bin/tcsh -f
#################################################################
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
#
echo '# Testing VIEW <KEYWORD>[:<region-list>]'

setenv ydb_poollimit "50"
setenv gtm_test_jnl SETJNL

echo "# Create a 3 region DB with gbl_dir mumps.gld and regions DEFAULT, AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 3 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

# Some of the VIEW commands tested (i.e. VIEW DBFLUSH and VIEW POOLLIMIT) only affect the
# DB when an -access_method of BG is specified
$MUPIP set -access_method=BG -file mumps.dat >>& dbcreate_log.txt
$MUPIP set -access_method=BG -file a.dat >>& dbcreate_log.txt
$MUPIP set -access_method=BG -file b.dat >>& dbcreate_log.txt

$MUPIP set -region "*" -flush_time=1:0:0 # Prevent interruptions from flush timers

echo '# Run generalTest to test all commands of the form VIEW <KEYWORD>[:<region-list>]'
echo '# and the VIEW POOLLIMIT:<region-list>:n[%] command'
echo '# Tests for:'
echo '#    	-VIEW commands accepting region sub-argument accept comma (,) delimited region lists'
echo '# 	-YottaDB sorts the regions, eliminating any duplicates from the list. '
echo '#		-If the VIEW argument has a corresponding environment variable to set the default state,'
echo '# 		 the state applies to databases as the application implicitly opens them with references.'
$ydb_dist/mumps -run generalTest^gtm8922

echo '# Run gvsResetTest to test VIEW GVSRESET:<REGION>'
echo '# Tests for:'
echo '#    	-VIEW commands accepting region sub-argument accept comma (,) delimited region lists'
echo '# 	-YottaDB sorts the regions, eliminating any duplicates from the list. '
$ydb_dist/mumps -run gvsResetTest^gtm8922

# The openRegionsTest will run a VIEW command using our cmdline args
# as its VIEW options. So the options var will be a list
# of every VIEW option to test

set options=\
("DBFLUSH:AREG,BREG,BREG" "DBFLUSH" "DBSYNC:AREG,BREG,BREG"\
 "DBSYNC" "EPOCH:AREG,BREG,BREG" "EPOCH" "FLUSH:AREG,BREG,BREG"\
 "FLUSH" "JNLFLUSH:AREG,BREG,BREG" "JNLFLUSH"\
 "GVSRESET:AREG,BREG,BREG" "GVSRESET:" "POOLLIMIT:AREG,BREG,BREG:40"\
 "POOLLIMIT::40")


echo "# Run openRegionTest"
echo '# Tests for:'
echo '# 	-YottaDB sorts the regions, eliminating any duplicates from the list. '
echo '# 	-VIEW with no region sub-argument opens any unopened mapped regions in the current global directory, '
echo '#			while one with a list only opens the listed regions. '
foreach option ($options)
	echo "# Run openRegionTest with $option subarguments"
	$ydb_dist/mumps -run openRegionsTest^gtm8922 $option
end


echo '# Shut down the DB '
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
echo ''
