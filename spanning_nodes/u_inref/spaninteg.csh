#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	#
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

# Disable use of V6 DB mode by using a random V6 version to create the DBs to prevent warning coming out of
# MUPIP CREATE that causes problems for this test (GTM-W-MUNOSTRMBKUP).
setenv gtm_test_use_V6_DBs 0

# Verify that spanning node INTEG checks are properly issued in case of damaged spanning node.

# Get the limit for the max record size and max key size
source $gtm_tst/com/set_random_limits.csh

# Randomly choose the record size, block size and key size
@ rec_range = ($MAX_RECORD_SIZE - $RAND_BLOCK_SIZE) + 1
@ rec_size = `$gtm_exe/mumps -run rand $rec_range 1 $RAND_BLOCK_SIZE`
$gtm_tst/com/dbcreate.csh mumps 1 20 $rec_size $RAND_BLOCK_SIZE 1024 4096 >&! dbcreate.outx
$grep "YDB-W-MUNOSTRMBKUP" dbcreate.out >&! test.debug
if ( 0 == $status ) then
	mv dbcreate.out dbcreate.out_bkup
endif

@ blk_size = `$DSE dump -f |& $grep 'Block size ' | $tst_awk '{print $5}'`

@ node_sz_range = ($rec_size - $blk_size) + 1
@ node_size = `$gtm_exe/mumps -run rand $node_sz_range 1 $blk_size`

echo "key_size=$RAND_KEY_SIZE " >>&! test.debug
echo "rec_size=$rec_size" >>&! test.debug
echo "blk_size=$blk_size" >>&! test.debug
echo "node_size=$node_size" >>&! test.debug

set key = "^a(1)"
set span_key = "^a(1,#SPAN"
@ keysz_in_bytes = 10
echo "key=$key" >>&! test.debug
echo "span_key=$span_key" >>&! test.debug

#size of blk_hdr in bytes is 16
@ blk_hdr_sz = 16
#size of rec_hdr in bytes is 4
@ rec_hdr_sz = 4
#effective block size where spanning node value can be stored
@ eff_blk_size = (($blk_size - $rec_hdr_sz) - $blk_hdr_sz) - $keysz_in_bytes
@ totspanblks = `expr $node_size / $eff_blk_size`
@ rem = `expr $node_size % $eff_blk_size`
if ( 0 != $rem) then
	@ totspanblks = $totspanblks + 1
endif
# Add 1 in totspanblks count to account for control block of spanning node.
@ totspanblks = $totspanblks + 1
echo "totspanblks=$totspanblks" >>&! test.debug

$GTM <<EOF
set ^a(1)=\$\$^%RANDSTR($node_size)
EOF

@ iter = 1
set ctrl_blkid = `$DSE find -key="$key" |& $grep "Key found in block" | $tst_awk '{print $5}' | $tst_awk -F\. '{print $1}'`
echo "ctrl_blkid=$ctrl_blkid" >>&! test.debug

set blkid_list = ()
set blkid_list = ( $blkid_list $ctrl_blkid )
echo $blkid_list >>&! test.debug

# Construct the array of the block-ids of spanning nodes
@ iter = 2
while ( $iter <= $totspanblks )
	set blkid = `$DSE find -key=\"$span_key$iter\)\" |& $grep "Key found in block" | $tst_awk '{print $5}' | $tst_awk -F\. '{print $1}'`
	@ iter = $iter + 1
	echo "iter=$iter blkid=$blkid" >>&! test.debug
	set blkid_list = ($blkid_list $blkid)
end

echo $blkid_list >>&! test.debug

#Generate the DSE script to dump the blocks of the spanning node
echo '$DSE << EOF ' >&! dsecmd.csh
echo 'open -file="dse_span.zwr"' >>&! dsecmd.csh

@ iter = 1
while ( $iter <= $totspanblks )
echo "dump -bl=$blkid_list[$iter] -zwr" >>&! dsecmd.csh
	@ iter = $iter + 1
end
echo 'close' >>&! dsecmd.csh
echo 'EOF' >>&! dsecmd.csh

source dsecmd.csh >&! dsecmd.out

#Randomly choose the first block of the spanning node to be corrupted
@ crptblkind = `$gtm_exe/mumps -run rand $totspanblks`

if ( ($crptblkind == 1) || ($crptblkind == 0) ) then
	@ crptblkind = 2
else
	@ crptblkind = $crptblkind + 1
endif

@ tmp  = ( $totspanblks / 2 )
@ num = `$gtm_exe/mumps -run rand $tmp 1 1`
# increment number by 1 because if it is 0, the following loop will never terminate.
@ num = $num + 1

@ count = 0

# Keep corrupting the blocks of spanning node in the increment of num
while ( $crptblkind < $totspanblks )
	@ count = $count + 1
	set crptblkno = $blkid_list[$crptblkind]

	echo "crptblkind = $crptblkind" >>& test.debug
	echo "crptblkno = $crptblkno" >>& test.debug

	echo "dse overwrite -bl=$crptblkno -data=""999"" -offset=19" >>& test.debug
	$DSE overwrite -bl=$crptblkno -data="999" -offset=19  >>& test.debug
	@ crptblkind = $crptblkind  + $num
end

echo "Total corrupted blocks count = $count" >>& test.debug

$MUPIP integ -reg "*" >&! integreport.outx

# If the last block of the spanning node is corrupted, we will get one less DBSPANCHUNKORD error message.
@ err_cnt = `$grep "YDB-E-DBSPANCHUNKORD" integreport.outx | wc -l`
@ err_cnt_1 = $err_cnt + 1

if (( $count == $err_cnt ) || ($count == $err_cnt_1) ) then
	echo "YDB-E-DBSPANCHUNKORD issued correctly"
else
	echo "DBSPANCHUNKORD integ check is failed"
endif

@ cnt = `$grep "YDB-E-DBSPANGLOINCMP" integreport.outx | wc -l`
if ( $count != 0 ) then
	if ( $cnt == 1 ) then
		echo "YDB-E-DBSPANGLOINCMP issued correctly"
	else
		echo "DBSPANGLOINCMP integ check is failed"
	endif
else
# There is no corruption of spanning node, so there wont be DBSPANGLOINCMP message
	echo "YDB-E-DBSPANGLOINCMP is not issued"
endif
#$gtm_tst/com/dbcheck.csh
