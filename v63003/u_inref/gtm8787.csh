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
# Tests that Mupip Journal -Extract=-stdout handles its termination appropriately
#

# Creating database,journal file
setenv gtm_test_db_format "NO_CHANGE"
source $gtm_tst/com/gtm_test_setbgaccess.csh
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 1>>& create.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif
$MUPIP Set -Region Default -Journal=enable,on,before,file=mumps.mjl >>& jnlcreate.out
if ($status) then
	echo "Journal Create Failed, Output Below"
	cat jnlcreate.out
endif

# Updating database with massive amount of information so it will take time to extract,
# allowing the system to easily exit while extracting
$ydb_dist/mumps -run ^%XCMD "for i=1:1:10 set ^x(i)=i"
set t = `date +"%b %e %H:%M:%S"`

echo "# Running extract and terminating in separate terminal"
(expect -d $gtm_tst/$tst/u_inref/gtm8787.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "EXPECT FAILED"
endif
$ydb_dist/mumps -run gtm8787 >>& temp.out
set s = `cat temp.out`
$gtm_tst/com/getoper.csh "$t" "" log.outx "" $s

echo "# Searching Sys Log for a KILLBYSIG Error (Expecting nothing, would be found in previous versions)"
cat log.outx |& $grep KILLBYSIG |& $tst_awk '{print $5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12}'
echo ""
echo "# Searching Sys Log for a NOPRINCIO Error"
cat log.outx |& $grep NOPRINCIO |& $tst_awk '{print $5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12}'


$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
