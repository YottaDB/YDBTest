#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#
# Test case for C9I06-003000 : In rare cases, the source server could get into an infinite loop
# trying to read a particular transaction from a journal file that does not contain this transaction.
#

setenv gtm_test_spanreg 0	# because this test does not do anything significant with subscripted variables
				# and since dbcreate/dbcheck calls are not balanced disable spanning regions

# Get the current limits
source $gtm_tst/com/set_limits.csh

cat << COMMENT

# Start replication with BEFORE image journaling on primary and secondary.
# Use 2 databases a.dat and mumps.dat AND minimum alignsize on both sides.
# Do the following updates on the primary.
#     f i=1:1:x s ^a=\$j(i,y)
# The x and y are chosen such that we would be guaranteed that at least one
# alignsize boundary is reached in the journal file.

COMMENT

# unconditionally set before image journaling.
source $gtm_tst/com/gtm_test_setbeforeimage.csh
# unconditionally reset the align size to the minimum
@ force_align_size = $MIN_JOURNAL_ALIGN_SIZE
set tstjnlstr = `echo $tst_jnl_str | sed 's/,align=[1-9][0-9]*//;s/$/,align='$force_align_size'/'`
setenv tst_jnl_str "$tstjnlstr"
echo "$tst_jnl_str" >! new_tst_jnl_str.txt
$gtm_tst/com/dbcreate.csh mumps 2

echo "# Check if the align size is minimal. The rest of the test relies on it."
echo "# If align size is not minimal, no point in continuing the test. Will exit"
$MUPIP journal -show=header a.mjl -forward > & ! header_a.mjl.txt
set show_status = $status	# just in case above command errors out
set align_in_jnl = `$tst_awk '/Align size/ {print $3}' header_a.mjl.txt`
@ exp_align_in_jnl = $force_align_size * 512
if ((0 != $show_status) || ("$exp_align_in_jnl" != "$align_in_jnl")) then
	echo "TEST-E-ALIGNSIZE of a.mjl is expected to be $exp_align_in_jnl but is $align_in_jnl"
	echo "Will not continue the test"
	$gtm_tst/com/dbcheck.csh
	exit 1
endif

@ global_size = 200
@ global_count = ((3 * $force_align_size * 512) / 2) / $global_size

$GTM << EOF
for i=1:1:$global_count set ^a=\$justify(i,$global_size)
EOF

cat << COMMENT

# Run "mupip journal -extract -noverify -detail -for -fences=none a.mjl" on primary.
# Run "grep 0x00020000 a.mjf" on primary. Sample output is as follows.
# 0x00020000 [0x00f8] :: SET    \61170,60629\253\818546390\13802\0\253\^a="  ....253"
# Note down the value "253" above (in the \253\^a=). This means the 253rd set was written at an alignsize boundary.
# Assuming it to be 253, the rest of the description continues

COMMENT

$MUPIP journal -extract -noverify -detail -forward -fences=none a.mjl
set record = `$grep 0x00200000 a.mjf`
if ("SET" != `echo "$record" | $tst_awk '{print $4}'`) then
	echo "TEST-E-JNLRECORD. SET record expected at 0x00200000 but found the below instead"
	echo "$record"
	echo "Test cannot continue. Will exit"
	$gtm_tst/com/dbcheck.csh
	exit 1
endif

set updatenumber = `echo "$record" | $tst_awk -F\\ '{print $6}'`
set moreupdates = 100
@ updloop1 = $updatenumber - 1
@ resyncno = ($updatenumber - 1 ) + $moreupdates

# Log the calculated values in a file.
cat >> testnumbers.out << EOLOG
updatenumber : Obtained from journal extract file : $updatenumber
moreupdates  : Number of additional updates done  : $moreupdates
updloop1     : One less than the updatenumber     : $updloop1
resyncno     : secondary will be rolled back upto : $resyncno
EOLOG

cat << COMMENT

# stop replication and restart with a fresh set of databases.
# Do the following updates on the primary.
#     f i=1:1:252 s ^a=\$j(i,200)
#     f i=1:1:100 s ^x=\$j(i,200)
#     set i=253 s ^a=\$j(i,200)
# Note that we are doing 252 updates of ^a followed by 100 updates of ^x followed by the 253rd update of ^a.

COMMENT

$gtm_tst/com/RF_SHUT.csh
$gtm_tst/com/backup_dbjnl.csh first_updates_backup "*.gld *.mjl* *.mjf *.dat" "mv"
$gtm_tst/com/dbcreate.csh mumps 2
setenv portno `$sec_shell "$sec_getenv; cat $SEC_SIDE/portno"`
setenv start_time `cat start_time`
$GTM << EOF
for i=1:1:$updloop1 set ^a=\$justify(i,$global_size)
for i=1:1:$moreupdates set ^x=\$justify(i,$global_size)
set i=$updatenumber set ^a=\$justify(i,$global_size)
EOF

cat << COMMENT

# Once all these updates are sent across to the secondary, shut down the secondary and primary.
# On the secondary run : mupip_rollback.csh -resync=352 -lost=x.los "*"
#     Note that the -resync= value should be greater than 252 but less than 252+100+1.
#     This way we are taking the database on the secondary to some point back in time BEFORE the 253rd  ^a update.

COMMENT

#$gtm_tst/com/RF_sync.csh
#echo "Receiver shut down ..."
#$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
#echo "Source shut down ..."
#$gtm_tst/com/SRC_SHUT.csh "." >>& SHUT_${start_time}.out

$gtm_tst/com/RF_SHUT.csh on

echo "mupip journal rollback ..."
$sec_shell '$sec_getenv ; cd $SEC_SIDE ; $gtm_tst/com/mupip_rollback.csh -resync='$resyncno' -lost=x.lost "*"' \
                         >&! secondary_rollback.out
set secondary_rollback = `$tst_awk '/YDB-I-RLBKJNSEQ,/ {print $10}' secondary_rollback.out`
if ("$secondary_rollback" != "$resyncno") then
	echo "TEST-E-ROLLBACK Journal seqno of the instance after rollback is $secondary_rollback. Expected: $resyncno"
	echo "Check testnumbers.out and secondary_rollback.out"
	exit 1
endif
$grep YDB-S-JNLSUCCESS secondary_rollback.out

cat << COMMENT

# Now start primary and secondary.
# The source server will start sending from seqno 352 onwards since that is the journal seqno of the secondary.
#     All these journal records correspond to updates to ^x.
# Eventually it will have to send ^a (the 253rd update) across. At that point, without the fix,
# In dbg, it will assert fail in gtmsource_readfiles.c. In pro, it will spin taking 100% of the cpu.
# With the fix it will send it across without any issues.

COMMENT

$gtm_tst/com/RF_START.csh
$gtm_tst/com/dbcheck.csh -extract
