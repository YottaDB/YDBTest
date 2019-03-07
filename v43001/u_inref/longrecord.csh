#D9C03-002060 Writing long records to batch log file yields RMS-F-RSZ invalid record size
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

echo "Entering LONGRECORD subtest"
echo "d ^longrec"
echo "Redirect the output to longrecord.txt"
$GTM <<xyz >& longrecord.txt
d ^longrec
xyz
$tst_cmpsilent longrecord.txt $gtm_tst/$tst/u_inref/longrecord.txt
if $status == 0 then
	echo "PASSED from LONGRECORD test"
else
	echo "FAILED from LONGRECORD test"
endif
echo "Leaving LONGRECORD subtest"
