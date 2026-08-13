#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#--------------------------------------------------------------------------------------------------#"
echo "# [#1143] A database created by an older release picks up search index characteristics on upgrade  #"
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo "# The two file header fields were taken from the end of secshr_ops_array_filler, which held the"
echo "# live secshr_ops_array before those fields moved to node_local, and a file header is converted"
echo "# in place. An older database can therefore carry ANY bytes at those two offsets, and a shared"
echo "# memory segment must never be sized from them. What the current release has to show instead is"
echo "# what MUPIP CREATE would have given a new database : a quarter of the block size, and the"
echo "# default slot count. At the 4096 byte block size used below that is 1024 bytes and 1024 slots."
echo

# This subtest compares file header fields exactly, so keep the test system from changing the
# database underneath it. It switches versions itself, so it must not also have V6 databases forced
# on it by the harness - it creates one of those on purpose in stage 2.
setenv gtm_test_use_V6_DBs 0
setenv test_reorg NON_REORG

# DSE prints both fields on one line. Squeeze the spacing out so the reference file does not depend
# on column positions. $DSE follows the version switches below, $ydb_dist does not.
alias show_size 'echo "dump -fileheader" | $DSE |& grep -i "Search Index Size" | sed "s/  */ /g"'

echo "## Stage 1 : a V7 database created by an older GT.M or YottaDB release"
echo "# Auto upgrade supplies the defaults. It has to do so before the shared memory segment is"
echo "# sized, which is why db_init settles the fields and db_auto_upgrade stores the same values."
$gtm_tst/com/random_ver.csh -type V7 >&! prior_ver_v7.txt
if (0 != $status) then
	echo "TEST-I-SKIP, No suitable prior V7 version available, skipping stage 1."
else
	set prior_ver = `cat prior_ver_v7.txt`
	source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
	setenv gtmgbldir T1.gld
	$gtm_tst/com/dbcreate.csh T1 1 250 1024 4096 >&! T1-dbcreate.out
	echo "# Populate it with the older release, so the upgraded database has real data to search"
	$gtm_exe/mumps -run %XCMD 'for i=1:1:20000 set ^c(i)=i*7+3' >&! T1-fill.out
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	# T1.gld was written by the older release, in the global directory format that release used. A
	# newer YottaDB does not read an older format directly - GDE converts it, which is the same step
	# a user takes after upgrading - so run GDE over it before anything else opens it.
	echo "# mumps -run GDE, then exit : opening and exiting is what converts the global directory"
	$GDE exit >&! T1-gde.out
	echo "# The current release shows the MUPIP CREATE defaults, not what the older database left"
	show_size
	echo "# and every record the older release wrote is still found"
	$gtm_exe/mumps -run chk^ydb1143
	$gtm_tst/com/dbcheck.csh >&! T1-dbcheck.out
endif
echo

echo "## Stage 2 : a V6 database created by an older GT.M or YottaDB release"
echo "# A V6 file header has no such fields at all, and both offsets fall inside a V6 filler, so the"
echo "# current release has to show them off rather than size a segment from whatever is there."
echo "# MUPIP UPGRADE, which turns the header into a V7 header, is what supplies the defaults."
$gtm_tst/com/random_ver.csh -type V6 >&! prior_ver_v6.txt
if (0 != $status) then
	echo "TEST-I-SKIP, No suitable prior V6 version available, skipping stage 2."
else
	set prior_ver = `cat prior_ver_v6.txt`
	source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
	setenv gtmgbldir T2.gld
	$gtm_tst/com/dbcreate.csh T2 1 250 1024 4096 >&! T2-dbcreate.out
	echo "# Populate it with the older release"
	$gtm_exe/mumps -run %XCMD 'for i=1:1:20000 set ^c(i)=i*7+3' >&! T2-fill.out
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	echo "# mumps -run GDE, then exit : opening and exiting is what converts the global directory"
	$GDE exit >&! T2-gde.out
	echo "# Before MUPIP UPGRADE the header is still a V6 header, so both fields read as off"
	show_size
	echo y >&! yes.txt
	echo "# mupip upgrade -reg DEFAULT"
	$MUPIP upgrade -reg DEFAULT < yes.txt >&! T2-upgrade.out
	echo "# After MUPIP UPGRADE the header is a V7 header and carries the MUPIP CREATE defaults"
	show_size
	echo "# and every record the older release wrote is still found"
	$gtm_exe/mumps -run chk^ydb1143
	$gtm_tst/com/dbcheck.csh >&! T2-dbcheck.out
endif
echo

echo "# YDB1143 SEARCH INDEX UPGRADE TEST DONE"
