#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###############################################################################################
# Set minimum autoswitch limit and maximum block size. Make sure that the maximum record size #
# is at least the maximum block size. Turn journaling on and start saving globals that barely #
# fit within a block each. It should take a certain number of globals to cause a journal file #
# switch. Verify that the switch happened; recover and validate the values.                   #
###############################################################################################
echo "Verify that autoswitch occurs as expected when non-spanning globals are used."
echo

# Get the current limits
source $gtm_tst/com/set_limits.csh

# Set the journal buffer size near the highest-possible value and try to set the autoswitch limit to be
# slightly less.
@ key_size = $MIN_KEY_SIZE * 2
@ record_size = $MAX_BLOCK_SIZE - 50
@ block_size = $MAX_BLOCK_SIZE
@ autoswitch = $MIN_AUTOSWITCH_LIMIT

# Create the database with the above configuration
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! db_create.outx
echo "# If gtm_test_use_V6_DBs=1 we expect a MUNOSTRMBKUP error, otherwise we do not."
# The discrepancy described above is not dealt with here but in the outref file.
$gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP
echo

# Enable nobefore-image journaling on all regions
$gtm_dist/mupip set -journal=enable,on,nobefore,auto=$autoswitch -reg "*" >&! mupip_set.out

# Create a backup of the empty database
cp mumps.dat mumps.dat.bak

# Set the size of a global to almost fully occupy one block
@ global_size = $record_size
@ writes_needed = (($autoswitch * 512) / ($global_size + $key_size) - 1)
@ total_writes = $writes_needed + 5

# Write as many globals as we expect to cause a switch; count the number of journal files for
# the last ten updates
$gtm_dist/mumps -direct << EOF >&! mumps.out
set l=$total_writes,s=$writes_needed
write "we need $writes_needed for the switch, but will do $total_writes writes total",!
for i=1:1:l  set @("^i"_i)=\$justify("abcdefghijklmnopqrstuvwxyz",$global_size)  if (i>(l-10)) zsystem "ls -l *.mjl* | wc -l"
EOF

# Verify that the switch occurred as expected
@ ones = `$grep 1 mumps.out | $grep -v "writes" | wc -l`
@ twos = `$grep 2 mumps.out | $grep -v "writes" | wc -l`
@ total = $ones + $twos
if ($ones == 0 || $twos == 0 || $total != 10) then
	echo "TEST-E-FAIL The journal autoswitch did not occur around the $writes_needed write."
	exit 1
endif

# Create a MUPIP extract of the current database
$gtm_dist/mupip extract -format=zwr mumps-a.zwr >&! extract-a.out

# Overwrite the current database with the empty backup
cp -r mumps.dat.bak mumps.dat

# Repopulate the globals from the journal file
$gtm_dist/mupip journal -recover -forward -verbose mumps.mjl >&! mupip_jnl_rec.out

# Create a MUPIP extract of the recovered database
$gtm_dist/mupip extract -format=zwr mumps-b.zwr >&! extract-b.out

# Compare the extracts by first matching the line counts and then diffing
@ lines_a = `wc -l mumps-a.zwr | $tst_awk '{print $1}'`
@ lines_b = `wc -l mumps-b.zwr | $tst_awk '{print $1}'`

if ($lines_a != $lines_b) then
	echo "TEST-E-FAIL Extracts mumps-a.zwr and mumps-b.zwr are different."
else
	@ lines = $lines_a - 2
	$tail -$lines mumps-a.zwr > mumps-a-headless.zwr
	$tail -$lines mumps-b.zwr > mumps-b-headless.zwr
	diff mumps-{a,b}-headless.zwr >&! diff_extracts.outx
	if ($status) then
		echo "TEST-E-FAIL Extracts mumps-a-headress.zwr and mumps-b-headless.zwr are different."
	else
		\rm mumps-{a,b}-headless.zwr
	endif
endif

# Verify that the database is OK
$gtm_tst/com/dbcheck.csh
