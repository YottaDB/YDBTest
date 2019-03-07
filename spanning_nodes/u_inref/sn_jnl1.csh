#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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

###############################################################################################
# Verify that the new limits are enforced on various database and journaling configuration    #
# parameters, such as maximum key, block, and record sizes, journal buffer size, and          #
# autoswitch and allocation limits.                                                           #
###############################################################################################
echo "Verify that the new limits are enforced on various database and journaling configuration parameters."
echo
if ($gtm_test_jnl_nobefore) then
	# nobefore image randomly chosen
	set b4nob4image = "nobefore"
else
	# before image randomly chosen
	set b4nob4image = "before"
endif

# Get the current limits
source $gtm_tst/com/set_limits.csh

echo "Too small a key size"
@ key_size = $MIN_KEY_SIZE - 1
$gtm_tst/com/dbcreate.csh mumps 1 $key_size >&! dbcreate-a.outx
$grep "%GDE-I-VALTOOSMALL, $key_size is less than the minimum of $MIN_KEY_SIZE for a KEY_SIZE" dbcreate.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a low key size not found"
	\mv dbcreate.out dbcreate-aa.out
else
	echo "OK"
	\mv dbcreate.out dbcreate-aa.outx
endif

echo

echo "Too large a key size"
@ key_size = $MAX_KEY_SIZE + 1
@ record_size = 1024
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size >&! dbcreate-b.outx
@ ok = 1
$grep "%GDE-I-VALTOOBIG, $key_size is larger than the maximum of $MAX_KEY_SIZE for a KEY_SIZE" dbcreate.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a high key size not found"
	@ ok = 0
endif
$grep "%GDE-I-KEYTOOBIG, But record size $record_size can only support key size" dbcreate.out >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL Unexpected error for a high key size for a record found"
	@ ok = 0
endif
if ($ok) then
	echo "OK"
	\mv dbcreate.out dbcreate-bb.outx
else
	\mv dbcreate.out dbcreate-bb.out
endif

echo

echo "Negative record size"
@ key_size = $MIN_KEY_SIZE + 1
@ record_size = $MIN_RECORD_SIZE - 1
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size >&! dbcreate-c.outx
@ ok = 1
$grep "%GDE-E-VALUEBAD, - is not a valid number" dbcreate.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a low record size not found"
	@ ok = 0
endif
$grep "%GDE-I-RECTOOBIG, Block size" dbcreate.out >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL Unexpected error for a high record size for a block found"
	@ ok = 0
endif
if ($ok) then
	echo "OK"
	\mv dbcreate.out dbcreate-cc.outx
else
	\mv dbcreate.out dbcreate-cc.out
endif

echo

echo "Too large a record size"
@ key_size = $MIN_KEY_SIZE + 1
@ record_size = $MAX_RECORD_SIZE + 1
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size >&! dbcreate-d.outx
@ ok = 1
$grep "%GDE-I-VALTOOBIG, $record_size is larger than the maximum of $MAX_RECORD_SIZE for a RECORD_SIZE" dbcreate.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a high record size not found"
	@ ok = 0
endif
$grep "%GDE-I-KEYTOOBIG, But record size $record_size can only support key size" dbcreate.out >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL Unexpected error for a high key size for a record found"
	@ ok = 0
endif
if ($ok) then
	echo "OK"
	\mv dbcreate.out dbcreate-dd.outx
else
	\mv dbcreate.out dbcreate-dd.out
endif

echo

echo "Key size larger than the record size"
@ key_size = $MAX_KEY_SIZE
@ record_size = $MIN_RECORD_SIZE
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size >&! dbcreate-e.outx
$grep "%GDE-I-KEYTOOBIG, But record size $record_size can only support key size" dbcreate.out >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL Unexpected error for a key size not fitting in a record found"
	\mv dbcreate.out dbcreate-ee.out
else
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh 0 >&! dbtry-e.out
	\mv dbcreate.out dbcreate-ee.outx
endif

echo

echo "Too small a block size"
@ key_size = $MIN_KEY_SIZE + 1
@ record_size = $MIN_BLOCK_SIZE
@ block_size = $MIN_BLOCK_SIZE - 1
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! dbcreate-f.outx
$grep "%GDE-I-VALTOOSMALL, $block_size is less than the minimum of $MIN_BLOCK_SIZE for a BLOCK_SIZE" dbcreate.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a low block size not found"
	\mv dbcreate.out dbcreate-ff.out
else
	echo "OK"
	\mv dbcreate.out dbcreate-ff.outx
endif

echo

echo "Too large a block size"
@ key_size = $MIN_KEY_SIZE + 1
@ record_size = $MIN_BLOCK_SIZE
@ block_size = $MAX_BLOCK_SIZE + 1
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! dbcreate-g.outx
$grep "%GDE-I-VALTOOBIG, $block_size is larger than the maximum of $MAX_BLOCK_SIZE for a BLOCK_SIZE" dbcreate.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a high block size not found"
	\mv dbcreate.out dbcreate-gg.out
else
	echo "OK"
	\mv dbcreate.out dbcreate-gg.outx
endif

echo

echo "Block size smaller than the record size"
@ key_size = $MAX_KEY_SIZE
@ record_size = $MIN_BLOCK_SIZE
@ block_size = $MIN_BLOCK_SIZE
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! dbcreate-h.outx
$grep "%GDE-I-RECTOOBIG, Block size $block_size" dbcreate.out >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL Unexpected error for a block size not fitting the record found"
	\mv dbcreate.out dbcreate-hh.out
else
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! dbtry-h.out
	\mv dbcreate.out dbcreate-hh.outx
endif

echo

echo "Small key size"
@ key_size = $MIN_KEY_SIZE
$gtm_tst/com/dbcreate.csh mumps 1 $key_size >&! dbcreate-i.out
if (! $status) then
	$gtm_tst/$tst/u_inref/try_db.csh >&! dbtry-i.out
	echo "OK"
else
	\mv dbcreate.out dbcreate-ii.out
endif

echo

echo "Large key size"
@ key_size = $MAX_KEY_SIZE
@ record_size = 1024
@ block_size = $key_size + 50
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! dbcreate-j.out
if (! $status) then
	$gtm_tst/$tst/u_inref/try_db.csh >&! dbtry-j.out
	echo "OK"
else
	\mv dbcreate.out dbcreate-jj.out
endif

echo

echo "Small record size"
@ key_size = $MIN_KEY_SIZE
@ record_size = $MIN_RECORD_SIZE
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size >&! dbcreate-k.out
if (! $status) then
	$gtm_tst/$tst/u_inref/try_db.csh 0 >&! dbtry-k.out
	echo "OK"
else
	\mv dbcreate.out dbcreate-kk.out
endif

echo

echo "Large record size"
@ key_size = $MIN_KEY_SIZE
@ record_size = $MAX_RECORD_SIZE
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size >&! dbcreate-l.out
if (! $status) then
	$gtm_tst/$tst/u_inref/try_db.csh >&! dbtry-l.out
	echo "OK"
else
	\mv dbcreate.out dbcreate-ll.out
endif

echo

echo "Small block size"
@ key_size = $MIN_KEY_SIZE + 1
@ record_size = $MIN_BLOCK_SIZE
@ block_size = $MIN_BLOCK_SIZE
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! dbcreate-m.out
if (! $status) then
	$gtm_tst/$tst/u_inref/try_db.csh >&! dbtry-m.out
	echo "OK"
else
	\mv dbcreate.out dbcreate-mm.out
endif

echo

echo "Large block size"
@ key_size = $MIN_KEY_SIZE + 1
@ record_size = $MIN_BLOCK_SIZE
@ block_size = $MAX_BLOCK_SIZE
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! dbcreate-n.out
$gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP
egrep "-I-|-E-" dbcreate.out >&! /dev/null
if ($status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! dbtry-n.out
	\mv dbcreate-n.out dbcreate-n.outx
else
	\mv dbcreate.out dbcreate-nn.out
endif

echo

echo "Create a normal database"
$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate-o.out
if (! $status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! dbtry-o.out
else
	\mv dbcreate.out dbcreate-oo.out
endif

echo

echo "Too small an autoswitch limit"
@ autoswitch = $MIN_AUTOSWITCH_LIMIT - 1
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,auto=$autoswitch -reg "*" >&! mupip_set-a.out
$grep "%YDB-E-JNLINVSWITCHLMT, Journal AUTOSWITCHLIMIT \[$autoswitch\] falls outside of allowed limits \[$MIN_AUTOSWITCH_LIMIT\] and \[$MAX_AUTOSWITCH_LIMIT\]" mupip_set-a.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a low autoswitch limit not found"
else
	echo "OK"
	\mv mupip_set-a.out mupip_set-a.outx
endif

echo

echo "Too large an autoswitch limit"
@ autoswitch = $MAX_AUTOSWITCH_LIMIT + 1
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,auto=$autoswitch -reg "*" >&! mupip_set-b.out
$grep "%YDB-E-JNLINVSWITCHLMT, Journal AUTOSWITCHLIMIT \[$autoswitch\] falls outside of allowed limits \[$MIN_AUTOSWITCH_LIMIT\] and \[$MAX_AUTOSWITCH_LIMIT\]" mupip_set-b.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a high autoswitch limit not found"
else
	echo "OK"
	\mv mupip_set-b.out mupip_set-b.outx
endif

echo

echo "Too small an allocation limit"
@ allocation = $MIN_ALLOCATION_LIMIT - 1
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,alloc=$allocation -reg "*" >&! mupip_set-c.out
$grep "%YDB-W-JNLINVALLOC, Journal file allocation $allocation is not within the valid range of $MIN_ALLOCATION_LIMIT to $MAX_ALLOCATION_LIMIT" mupip_set-c.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a low allocation limit not found"
else
	echo "OK"
	\mv mupip_set-c.out mupip_set-c.outx
endif

echo

echo "Too large an allocation limit"
@ allocation = $MAX_ALLOCATION_LIMIT + 1
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,alloc=$allocation -reg "*" >&! mupip_set-d.out
$grep "%YDB-W-JNLINVALLOC, Journal file allocation $allocation is not within the valid range of $MIN_ALLOCATION_LIMIT to $MAX_ALLOCATION_LIMIT" mupip_set-d.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a high allocation limit not found"
else
	echo "OK"
	\mv mupip_set-d.out mupip_set-d.outx
endif

echo

echo "Allocation larger than autoswitch limit"
@ autoswitch = $MIN_AUTOSWITCH_LIMIT
@ allocation = $MAX_ALLOCATION_LIMIT
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,auto=$autoswitch,alloc=$allocation -reg "*" >&! mupip_set-e.out
$grep "%YDB-E-JNLSWITCHTOOSM, Journal AUTOSWITCHLIMIT \[$autoswitch blocks\] is less than Journal ALLOCATION \[$allocation blocks\] for database file" mupip_set-e.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for autoswitch limit being lower than allocation size not found"
else
	echo "OK"
	\mv mupip_set-e.out mupip_set-e.outx
endif

echo

echo "Too small a journal buffer size"
@ buffer_size = $MIN_JOURNAL_BUFFER_SIZE - 1
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,buffer_size=$buffer_size -reg "*" >&! mupip_set-f.out
$grep "%YDB-W-JNLBUFFREGUPD, Journal file buffer size for region DEFAULT has been adjusted from $buffer_size to $DEF_JOURNAL_BUFFER_SIZE." mupip_set-f.out >&! /dev/null

if ($status) then
	echo "TEST-E-FAIL Expected error for a low journal buffer size not found"
else
	echo "OK"
	\mv mupip_set-f.out mupip_set-f.outx
endif

echo

echo "Too large a journal buffer size"
@ buffer_size = $MAX_JOURNAL_BUFFER_SIZE + 1
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,buffer_size=$buffer_size -reg "*" >&! mupip_set-g.out
$grep "%YDB-W-JNLBUFFREGUPD, Journal file buffer size for region DEFAULT has been adjusted from $buffer_size to $MAX_JOURNAL_BUFFER_SIZE." mupip_set-g.out >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL Expected error for a high journal buffer size not found"
else
	echo "OK"
	\mv mupip_set-g.out mupip_set-g.outx
endif

echo

echo "Small autoswitch limit"
@ autoswitch = $MIN_AUTOSWITCH_LIMIT
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,auto=$autoswitch -reg "*" >&! mupip_set-h.out
if (! $status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! mupiptry-h.out
endif

echo

echo "Large autoswitch limit"
@ autoswitch = $MAX_AUTOSWITCH_LIMIT
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,auto=$autoswitch -reg "*" >&! mupip_set-i.out
if (! $status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! mupiptry-i.out
endif

echo

echo "Small allocation limit"
@ allocation = $MIN_ALLOCATION_LIMIT
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,alloc=$allocation -reg "*" >&! mupip_set-j.out
if (! $status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! mupiptry-j.out
endif

echo

echo "Large allocation limit"
@ allocation = $MAX_ALLOCATION_LIMIT
@ autoswitch = $MAX_AUTOSWITCH_LIMIT
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,alloc=$allocation,auto=$autoswitch -reg "*" >&! mupip_set-k.out
if (! $status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! mupiptry-k.out
endif

echo

echo "Small journal buffer size"
@ buffer_size = $DEF_JOURNAL_BUFFER_SIZE
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,buffer_size=$buffer_size -reg "*" >&! mupip_set-l.out
if (! $status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! mupiptry-l.out
endif

echo

echo "Large journal buffer size"
@ buffer_size = $MAX_JOURNAL_BUFFER_SIZE
$gtm_dist/mupip set -journal=enable,on,$b4nob4image,buffer_size=$buffer_size -reg "*" >&! mupip_set-m.out
if (! $status) then
	echo "OK"
	$gtm_tst/$tst/u_inref/try_db.csh >&! mupiptry-m.out
endif

echo

# Verify that the database is OK
$gtm_tst/com/dbcheck.csh
