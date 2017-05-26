#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Before image journaling only works with BG
setenv acc_meth "BG"

$gtm_tst/com/dbcreate.csh mumps 1 -allocation=10 -block_size=65024 -record_size=32767 -global_buffer=64
$MUPIP set -journal="enable,on,before,alignsize=4096" -reg "*"
#
$GTM << gtm_eof
	d ^c001511
gtm_eof
#
#
echo "Show and Extract ......"
$MUPIP journal -extract -detail -forward -show=all mumps.mjl >>& ext_for.log
set stat1=$status
#
$grep "Show successful" ext_for.log
set stat2=$status
$grep "Extract successful" ext_for.log
set stat3=$status
if ($stat1 != 0 || $stat2 != 0 || $stat3 != 0) then
	echo "C9A06001511 TEST FAILED"
	cat ext_for.log
	exit 1
endif
#
$grep PBLK mumps.mjf |$tst_awk '{split($0,items," ");printf("PBLK record size is: %s\n",items[2])}'
$gtm_tst/com/dbcheck.csh
