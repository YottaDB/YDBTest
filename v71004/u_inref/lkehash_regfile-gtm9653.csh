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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9653 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959409653)

MLKHASHRESIZE, MLKHASHRESIZEFAIL and MLKREHASH messages include region and database file names. Previously, these error messages did not provide the region and database file names. (GTM-9653)

CAT_EOF
echo

echo '# The three messages go to the operator log (syslog) and not to the terminal. The LKE REHASH command rebuilds the'
echo '# LOCK hash table of a region, which issues MLKREHASH, and the LKE GROWHASH command increases the size of the LOCK'
echo '# hash table, which issues MLKHASHRESIZE. This subtest runs both commands and checks the two messages in the'
echo '# operator log. MLKHASHRESIZEFAIL is issued only if an entry cannot be placed in the larger hash table, which this'
echo '# subtest does not attempt to cause because that needs LOCK names whose hash values collide even in the larger hash'
echo '# table, and such names are not easy to create.'
echo '# Before the fix : MLKREHASH had only the region name and MLKHASHRESIZE had neither name'
echo "# With the fix   : expect both messages to have [for region DEFAULT ($tst_working_dir/mumps.dat)]"
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

# Start of the syslog window searched below (local time, as com/getoper.csh expects)
set syslog_start = `date +"%b %e %H:%M:%S"`
# The operator log shows the database file by its real path, which can differ from $tst_working_dir when the test
# area is reached through a symbolic link. The output below replaces the real path with $tst_working_dir/mumps.dat,
# which the reference file has as ##TEST_PATH##/mumps.dat.
set dbpath = `realpath mumps.dat`

echo '# Run [lke rehash -region=DEFAULT]'
$LKE rehash -region=DEFAULT
echo '# Run [lke growhash -region=DEFAULT]'
$LKE growhash -region=DEFAULT
echo

echo '# Messages for this database file in the operator log (sizes and the shared memory id replaced by N)'
$gtm_tst/com/getoper.csh "$syslog_start" "" syslog.txt "" "MLKHASHRESIZE.*$dbpath" >&! getoper.logx
$grep -E "MLKREHASH|MLKHASHRESIZE" syslog.txt | $grep "$dbpath" >&! mlk_syslog.logx
sed 's/.*\(%[A-Z]*-[IW]-MLK\)/\1/; s/ -- generated from .*//; s|'"$dbpath"'|'"$tst_working_dir"'/mumps.dat|; s/from [0-9]* to [0-9]*/from N to N/; s/id = [0-9]*/id = N/' mlk_syslog.logx
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
