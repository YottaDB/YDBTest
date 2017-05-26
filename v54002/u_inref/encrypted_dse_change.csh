#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# journal enable is done in this test. So let's not randomly enable journaling in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL

setenv gtmgbldir "mumps.gld"

# This test require encryption, so turn it on if needed.
if ("NON_ENCRYPT" == "$test_encryption") then
	echo "Test need to be run with encryption"
	exit
endif

$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -journal=enable,on,before,epoch=3600 -reg DEFAULT

$DSE change -fileheader -flush_time=100000

# This is what happens:
# 1) The initial updates has taken the database to a TN say 1000.
# 2) The first DSE command sets the TN to 0x10 (16) which is lesser than the TN at that point. DSE (via t_qread -> dsk_read)
# reads the block 0 in to the global buffers as well as into the encrypted twin buffer (even though block 0 is not encrypted).
# Both these block contents (unencrypted global buffer and it's encrypted twin counterpart in shared memory) will have the TN
# value set to some number greater than 0x10 (16) (due to the initial updates). As part of the commit of this DSE command, it
# will update only the unencrypted global buffer in shared memory which will now contain the TN as 0x10 (16). The encrypted
# twin buffer is not updated until wcs_wtstart is done and hence will still have the pre-update TN. In our test case since
# flush_time is large enough, it won't happen anytime soon.
# 3) The second DSE command will read the same block again, now from the memory which is unencrypted and hence will have the
# TN 0x10 (16). When this DSE command goes through t_end, it now sees that the TN of this block is less than the epoch_tn
# (since we deliberately made it so in the previous DSE command) and hence wants to write a before image. But, since encryption
# is enabled, it will fetch the before image from the encrypted twin buffer. Before writing the before image (jnl_write_pblk)
# it ensures that the encrypted twin buffer for this block has the same block header information as the unencrypted buffer
# and this is where the assert fails as the encrypted twin buffer is stale.
$gtm_exe/mumps -run %XCMD 'for i=1:1:1000 set ^a(i)=i'

$DSE << EOF
change -block=0 -tn=10
change -block=0 -level=FF
EOF
echo ""
$gtm_tst/com/dbcheck.csh
