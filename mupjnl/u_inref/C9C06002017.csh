#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$gtm_tst/com/dbcreate.csh mumps 2 255 1000
#
if ($?test_replic == 0) then
	$MUPIP set -journal="enable,on,before,auto=16384,alloc=2048,exten=1024" -reg DEFAULT
	$MUPIP set -journal="enable,on,before,auto=16896,alloc=2048,exten=512" -reg AREG
endif

$GTM << gtm_eof
d ^c002017
gtm_eof
#
$GTM << gtm_eof
d defreg^c002017
gtm_eof
#
set time1=`cat time1.txt`
echo "Backward recovery ......"
$MUPIP journal -recover -backward -since=\"$time1\" -extract=a.mjf "*" >&! backward_recover.out
set stat1=$status
if ($stat1) then
	echo  "TEST-E-FAIL : Backward recovery failed with status : $stat1. See backward_recover.out for details."
endif
# A region name prefix (e.g. "AREG : ") is possible in MUJNLPREVGEN (backward phase parallelization with threads)
# and FILERENAME (forward phase parallelization with processes) messages. So filter those out.
$grep -E "MUJNLPREVGEN" backward_recover.out | sed 's/^.* : //g' | sort
$grep -E "FILERENAME" backward_recover.out | sed 's/^.* : //g' | sort
$grep "JNLSUCCESS" backward_recover.out
#
echo "Verifying data ......"
$GTM << GTM_EOF
 w "d dverify^c002017",! d dverify^c002017
 w "VERIFICATION PASSED",!
GTM_EOF

# Extract file must be a.mjf. Sort it before presenting it to everify
if (! -e a.mjf) then
	echo "TEST-E-FAIL : Expected a.mjf to be created but file is not there"
endif
mv a.mjf orig_a_mjf.txt	# change extension so everify is not confused (it does a *.mjf search)
# And then paste all records of ^a first and then all records of ^x into one extract file to ease parsing.
$grep "\^a" orig_a_mjf.txt > a.mjf
$grep "\^x" orig_a_mjf.txt >> a.mjf
echo "Verifying journal extract data ......"
$GTM << GTM_EOF
 w "d everify^c002017",! d everify^c002017
GTM_EOF
#
echo "Verifying the journal files ..."
set jnllist=`ls -rt *.mjl*`
foreach jnl1 ($jnllist)
	echo "****************************"
	$MUPIP journal -verify -forw $jnl1
end
$gtm_tst/com/dbcheck.csh -extract
