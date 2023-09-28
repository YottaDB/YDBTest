#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
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

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

#create a global directory with two regions -- DEFAULT, REGX
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_use_V6_DBs 0   # Disable V6 DB mode as it causes changes in output of DSE commands (block #s/versions, offsets, etc)
$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test dse -restore command

echo "TEST DSE - RESTORE COMMAND"

#save block 3 and restore different versions of it

$DSE << DSE_EOF

find -reg=DEFAULT
save -bl=3 -comment="comment string"
save -bl=3
restore -bl=3 -ver=0
restore -bl=3 -ver=1
restore -bl=3
restore -bl=3 -ver=3

DSE_EOF

# try restoring an unsaved block

$DSE << DSE_EOF

find -reg=DEFAULT
restore -bl=0 -ver=1

DSE_EOF

# restore into block 2 from version 1 of block 3
# copies the block 3, ver 1 into block2


$DSE << DSE_EOF

find -reg=DEFAULT
save -bl=2
save -bl=3 -comment="comment string"
restore -bl=2 -from=3 -ver=1
dump -bl=3 -hea
dump -bl=2 -hea
restore -bl=2 -ver=1
dump -bl=2 -hea

DSE_EOF

# try restoring from unsaved version

$DSE << DSE_EOF

find -reg=DEFAULT
restore -bl=2 -from=4 -ver=1

DSE_EOF

# try restoring into a non existing block

$DSE << DSE_EOF

find -reg=DEFAULT
restore -bl=232 -from=4 -ver=1

DSE_EOF

# non existing 'from' version

$DSE << DSE_EOF

find -reg=DEFAULT
restore -bl=2 -from=3 -ver=4

DSE_EOF


# corrupt the local bit map, by 'restor'ing from block 3 then
# restore bit map from its saved version

$DSE << DSE_EOF

find -reg=Default
save -bl=3
save -bl=0
restore -bl=0 -from=3 -ver=1
integ
restore -bl=0 -ver=1
integ

DSE_EOF


# restore across the regions
# restore a block in AREG from a block in DEFAULT
# restore the blocks to default


$DSE << DSE_EOF

save -bl=2
find -reg=DEFAULT
save -bl=3
restore -bl=3 -from=2 -region=AREG
dump -bl=3 -head
restore -bl=3
dump -bl=3 -head
restore -bl=3 -from=2 -region=FREELUNCH
DSE_EOF

# save and restore a bit map

$DSE << DSE_EOF

save -bl=0
rest -bl=0
DSE_EOF

# save a block, (artifically) shrink the file
# then show that the block is still accessible to restore
# however it should fail to build as it's not a valid block
# and restore the total blocks to get a proper integ

$DSE << DSE_EOF

save -bl=4
save -bl=64
change -fileheader -total_blks=60
restore -bl=4 -from=64
remove -bl=64
change -fileheader -total_blks=65
restore -bl=4
DSE_EOF

# Restore a HUGE block number greater than 4GiB. Make sure the full 8-byte block number is displayed.
# Previously, only the least significant 4-byte block number used to be displayed in the error message.
# Also test that BLKINVALID error is displayed if restore target block number is greater than total block count
# but no such error is displayed in case the source target block number (-from) is greater than total block count.
# Finally restore the total blocks to get a proper integ.
$DSE << DSE_EOF
restore -bl=abcdef0123456789
change -fileheader -total_blks=abcdef012345679
restore -bl=abcdef012345678
restore -bl=abcdef012345678 -version=2
change -fileheader -total_blks=65
restore -bl=64 -from=abcdef012345678
restore -bl=64 -from=abcdef012345678 -version=3
DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
# move a database so it's not found to test for an appropriate error from restore
mv mumps.dat mumps.dat.save
$DSE << DSE_EOF
restore -bl=3 -from=2 -region=default
DSE_EOF
