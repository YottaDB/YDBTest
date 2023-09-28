#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
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
# See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1682#note_1515770845 for more information.
setenv gtm_test_use_V6_DBs 0

# Get the limit for the max record size and max key size
source $gtm_tst/com/set_random_limits.csh

# Randomly choose the record size, block size and key size
@ rec_range = ($MAX_RECORD_SIZE - $RAND_BLOCK_SIZE) + 1
@ rec_size = `$gtm_exe/mumps -run rand $rec_range 1 $RAND_BLOCK_SIZE`
@ global_buff_count = 4096
$gtm_tst/com/dbcreate.csh mumps 1 $RAND_KEY_SIZE $rec_size $RAND_BLOCK_SIZE 1024 $global_buff_count >&! dbcreate.outx
$grep "YDB-W-MUNOSTRMBKUP" dbcreate.out >&! test.debug
if ( 0 == $status ) then
	mv dbcreate.out dbcreate.out_bkup
endif

@ blk_size = `$DSE dump -f |& $grep 'Block size ' | $tst_awk '{print $8}'`
# randomly choose the size of the mumps node to be greater than blk_size and less than rec_size, so that node will span across the blocks
@ node_sz_range = $rec_size - $blk_size
@ node_size = `$gtm_exe/mumps -run rand $node_sz_range 1 $blk_size`

echo "key_size=$RAND_KEY_SIZE " >>&! test.debug
echo "rec_size=$rec_size" >>&! test.debug
echo "blk_size=$blk_size" >>&! test.debug
echo "node_size=$node_size" >>&! test.debug

$GTM <<EOF
set ^tmp=\$\$^%RANDSTR($node_size)
EOF

#randomly choose if the subscript to use or not. Currently hard-coded
@ has_subs = `$gtm_exe/mumps -run rand 2`
if ( 1 == $has_subs) then
        set key = "^a(1)"
        set span_key = "^a(1,#SPAN"
	@ keysz_in_bytes = 10
else
        set key = "^a"
        set span_key = "^a(#SPAN"
	@ keysz_in_bytes = 7
endif
echo "key=$key" >>&! test.debug

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

$gtm_exe/mumps -run '%XCMD' "set $key=^tmp"

@ iter = 1
set ctrl_blkid = `$DSE find -key=\"$span_key$iter\)\" |& $grep "Key found in block" | $tst_awk '{print $5}' | $tst_awk -F\. '{print $1}'`
echo "ctrl_blkid=$ctrl_blkid" >>&! test.debug
# Add 1 in totspanblks count to account for control block of spanning node.
@ totspanblks = $totspanblks + 1
echo "totspanblks=$totspanblks" >>&! test.debug

set blkid_list = ()
set blkid_list = ( $blkid_list $ctrl_blkid )
echo $blkid_list >>&! test.debug
echo "span_key=$span_key" >>&! test.debug

@ iter = 2
while ( $iter <= $totspanblks )
        set blkid = `$DSE find -key=\"$span_key$iter\)\" |& $grep "Key found in block" | $tst_awk '{print $5}' | $tst_awk -F\. '{print $1}'`
        @ iter = $iter + 1
	echo "blkid=$blkid" >>&! test.debug
        set blkid_list = ($blkid_list $blkid)
	echo $blkid_list >>&! test.debug
end
echo $blkid_list >>&! test.debug

#Generate the DSE script to dump the blocks of the spanning node
echo '$DSE << EOF ' >&! dsecmd.csh
echo 'open -file="dse_span.zwr"' >>&! dsecmd.csh
@ iter = 1
while ( $iter <= $totspanblks )
	echo "dump -bl=$blkid_list[$iter] -zwr" >>&! dsecmd.csh
	$DSE INTEGRIT  -bl=$blkid_list[$iter] >>&! dseinteg.out
        @ iter = $iter + 1
end
echo 'close' >>&! dsecmd.csh
echo 'EOF' >>&! dsecmd.csh
source dsecmd.csh >&! dsecmd.out
#randomly kill or keep the spanning global before constructing with the MUPIP LOAD
@ killgbl = `$gtm_exe/mumps -run rand 2`
if ( 1 == $killgbl ) then
	echo "Spanning node will be killed"  >>&! test.debug
        $gtm_exe/mumps -run '%XCMD' "kill $key"
else
	echo "Spanning node will not be killed" >>&! test.debug
endif

$MUPIP load -format=zwr dse_span.zwr >&! mupip_load.outx
# Ensure that the spanning gloabl built from MUPIP LOAD is similar to original spanning global.
$GTM <<EOF
if ($key=^tmp) write $key=^tmp," spanning node construction successful",!
EOF

$gtm_tst/com/dbcheck.csh
