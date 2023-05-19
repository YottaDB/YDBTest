#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a sed script that converts a V6 format DSE DUMP -FILE output into a V7 format DSE DUMP -FILE output.
# This was used to update pre-existing reference files when GT.M V7.0-000 was merged into YottaDB. It greatly
# simplified the process of updating the reference files.
# This script is considered good to have even for the future and hence is included in the git repository.

# ----------------------------------------------------------------------------------------------
# The main changes are that each of the 2 columns of output get 8 more spaces now.
# The below sed commands take care of adding the 8 spaces.
# We specify 1 space in each of these search terms below except for "Maximum TN  " where we specify 2 spaces.
# This is needed to prevent it from matching the line "Maximum TN Warn " too.
# ----------------------------------------------------------------------------------------------
s,Access method ,&        ,;
s,Reserved Bytes ,&        ,;
s,Maximum record size ,&        ,;
s,Maximum key size ,&        ,;
s,Null subscripts ,&        ,;
s,Standard Null Collation ,&        ,;
s,Last Record Backup ,&        ,;
s,Last Database Backup ,&        ,;
s,Last Bytestream Backup ,&        ,;
s,In critical section ,&        ,;
s,Cache freeze id ,&        ,;
s,Freeze match ,&        ,;
s,Freeze online ,&        ,;
s,Current transaction ,&        ,;
s,Maximum TN  ,&        ,;
s,Maximum TN Warn ,&        ,;
s,Master Bitmap Size ,&        ,;
s,Default Collation ,&        ,;
s,Collation Version ,&        ,;
s,Create in progress ,&        ,;
s,Reference count ,&        ,;
s,Journal State ,&        ,;
s,Journal Before imaging ,&        ,;
s,Journal Allocation ,&        ,;
s,Journal Extension ,&        ,;
s,Journal Buffer Size ,&        ,;
s,Journal Alignsize ,&        ,;
s,Journal AutoSwitchLimit ,&        ,;
s,Journal Epoch Interval ,&        ,;
s,Journal Yield Limit ,&        ,;
s,Journal Sync IO ,&        ,;
s,Mutex Hard Spin Count ,&        ,;
s,Mutex Queue Slots ,&        ,;
s,Replication State ,&        ,;
s,Zqgblmod Seqno ,&        ,;
s,Endian Format ,&        ,;
s,Database file encrypted ,&        ,;
s,Spanning Node Absent ,&        ,;
s,Defer allocation ,&        ,;
s,Async IO ,&        ,;
s,DB is auto-created ,&        ,;
s,LOCK shares DB critical section ,&        ,;
s,Recover interrupted ,&        ,;
s,Max conc proc time ,&        ,;
s,Reorg Sleep Nanoseconds ,&        ,;
s,Global Buffers ,&        ,;
s,Block size (in bytes) ,&        ,;
s,Starting VBN ,&        ,;
s,Free space ,&        ,;
s,Extension Count ,&        ,;
s,Number of local maps ,&        ,;
s,Lock space ,&        ,;
s,Timers pending ,&        ,;
s,Flush timer ,&        ,;
s,Flush trigger ,&        ,;
s,Freeze online autorelease ,&        ,;
s,No. of writes/flush ,&        ,;
s,Certified for Upgrade to ,&        ,;
s,Desired DB Format ,&        ,;
s,Blocks to Upgrade ,&        ,;
s,Modified cache blocks ,&        ,;
s,Wait Disk ,&        ,;
s,Mutex Sleep Spin Count ,&        ,;
s,KILLs in progress ,&        ,;
s,Region Seqno ,&        ,;
s,Zqgblmod Trans ,&        ,;
s,Commit Wait Spin Count ,&        ,;
s,Inst Freeze on Error ,&        ,;
s,Maximum Key Size Assured ,&        ,;
s,Spin sleep time mask ,&        ,;
s,WIP queue cache blocks ,&        ,;
s,DB shares gvstats ,&        ,;
s,Read Only ,&        ,;
s,Full Block Write ,&        ,;
s,Max Concurrent processes ,&        ,;

# ----------------------------------------------------------------------------------------------
# Below are some fields which changed in value in V7.0-000
# The sed commands below take care of changing their V6 values to their corresponding V7 values
# ----------------------------------------------------------------------------------------------
s,Starting VBN                           513,Starting VBN                          8193,;
s,Total blocks            0x,Total blocks            0x00000000,;
s,Free blocks             0x,Free blocks             0x00000000,;
s,Maximum TN                     0xFFFFFFFF83FFFFFF,Maximum TN                     0xFFFFFFF803FFFFFF,;
s,Maximum TN Warn                0xFFFFFFFD93FFFFFF,Maximum TN Warn                0xFFFFFFD813FFFFFF,;
s,Certified for Upgrade to                V6,Certified for Upgrade to                V7,;
s,Desired DB Format                       V6,Desired DB Format                       V7,;
s,Master Bitmap Size                            496,Master Bitmap Size                           8176,;
s,Blocks to Upgrade               0x00000000,Blocks to Upgrade       0x0000000000000000,;

