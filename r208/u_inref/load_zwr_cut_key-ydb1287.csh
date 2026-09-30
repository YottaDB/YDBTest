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

echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1287] MUPIP LOAD does not read past the end of a ZWR record whose key is cut short            #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# zwrkeyvallen() finds the key of a ZWR record for MUPIP LOAD. After a $, a closing " or a ) in the key,'
echo '# it read the next one to three bytes without checking them against the length of the record, and it'
echo '# scanned the ,<offset>,<length>) part of a $ze(...) record until it found a ) wherever that was.'
echo '# str2gvargs(), which then turns the key into a global reference, read past its end in the same way.'
echo '# MUPIP LOAD reads every line into the same buffer, so on a record whose key is cut short those reads'
echo '# found bytes left over from an earlier, longer line. The error LOAD reported, or whether it took the'
echo '# key as complete, then depended on those bytes. A dbg build failed an assert in one of the two instead.'
echo '#'
echo '# For each of 4 records, and each length that cuts the record within its key, the cut copy is loaded'
echo '# once after the full record and once after a filler record of the same length. Without the fix, the'
echo '# two loads of most cuts report different errors, as the error quotes bytes past the end of the cut.'
echo

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps

cp $gtm_tst/$tst/inref/ydb1287.m .

echo
echo '# Run [ydb1287] : for each cut of each record, run $ydb_dist/mupip load on a ZWR file of 3 records:'
echo '#   the full record or the filler, then ^s=1, then the cut copy'
echo '# expect each load to report the cut copy as its only failed record, and the output of the two loads'
echo '# of each cut to be the same'
$ydb_dist/yottadb -run run^ydb1287

echo
echo '# Stage 2 : The scan for the ) of a $ze(...) record did not stop at the end of the record. In stage 1 the line'
echo '# before each cut copy holds a ), which stopped the scan. Here each record has no ) and no line before it, so'
echo '# without the fix a pro build read on until it ran off the end of mapped memory and terminated with a SIG-11.'
echo '# Run [ydb1287] : for each record, run $ydb_dist/mupip load on a ZWR file holding only that record'
echo '# expect each load to report the record as its only failed record'
$ydb_dist/yottadb -run noparen^ydb1287

echo
echo '# Stage 3 : A record whose key is empty, e.g. =1, reached str2gvargs() with a length of 0, which failed an assert'
echo '# in a dbg build. The code after that assert reports NOTGBL for an empty key.'
echo '# Run [ydb1287] : run $ydb_dist/mupip load on a ZWR file holding only =1'
echo '# expect the load to report =1 as its only failed record, with a NOTGBL error'
$ydb_dist/yottadb -run emptykey^ydb1287

echo
echo '# Stage 4 : a replication filter in the source server returns a SET whose key is in $ze(...) form'
echo '# ext2jnl() converts each record a filter returns back into a journal record. It passes NULL to zwrkeyvallen() for'
echo '# the two outputs of the $ze(...) form, but zwrkeyvallen() wrote through them whenever the key started with $, so'
echo '# the server running the filter terminated with a SIG-11. Such a key is not a global name, and must now be reported'
echo '# as NOTGBL.'
$gtm_tst/$tst/u_inref/zwr_filter_key-ydb1287.csh source

echo
echo '# Stage 5 : the same filter, run in the receiver server instead'
$gtm_tst/$tst/u_inref/zwr_filter_key-ydb1287.csh receiver

echo
echo "# Invoking : dbcheck.csh"
$gtm_tst/com/dbcheck.csh
