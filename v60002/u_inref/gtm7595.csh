#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7595: Excess storage allocation for journaling/journaling-encryption
# Test new non-TP journal buffer allocation scheme in gvcst_init.
# Buffers are allocated/reallocated based on block size and whether or not encryption is enabled.
#

$gtm_tst/com/dbcreate.csh mumps 7
\rm -rf *.dat *.mjl
if (("MM" == $acc_meth) || ("NON_ENCRYPT" == $test_encryption)) then
        set qual="-noencrypt"
else
	set qual="-encrypt"
endif
# It is possible the test framework randomly chose ASYNCIO. But a few segments are modified below to use
# a block size of 1KiB and 2KiB which are not a multiple of the file system block size of 4KiB.
# Therefore use -noasyncio (to disable ASYNCIO) for those segments to avoid DBBLKSIZEALIGN errors.
$GDE << EOF
	change -segment DEFAULT -noencrypt
	change -segment ASEG -noencrypt -block_size=1024 -noasyncio
	change -segment BSEG -noencrypt -block_size=2048 -noasyncio
	change -segment CSEG -noencrypt -block_size=4096
	change -segment DSEG $qual -block_size=1024 -noasyncio
	change -segment ESEG $qual -block_size=2048 -noasyncio
	change -segment FSEG $qual -block_size=4096
	change -region AREG -record_size=800
	change -region BREG -record_size=1600
	change -region CREG -record_size=3200
	change -region DREG -record_size=800
	change -region EREG -record_size=1600
	change -region FREG -record_size=3200
	exit
EOF
$MUPIP create
$MUPIP set -journal=enable,nobefore -reg "*" >>&! jnlset.log
$MUPIP set -journal=disable -reg DEFAULT >>&! jnlset.log

echo ""
echo "# Access regions (6 of them) in a few randomly chosen possible orders (720 of them)."
echo ""
set n=6
set iters=25
$gtm_exe/mumps -run %XCMD "do genperms^gtm7595($n,$iters)"
@ i = 0
while ($i < $iters)
	@ i = $i + 1
	$gtm_exe/mumps -run %XCMD "do access^gtm7595($n,$i)"
end

echo ""
$gtm_tst/com/dbcheck.csh
