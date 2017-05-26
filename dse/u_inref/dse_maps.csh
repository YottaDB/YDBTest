#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test dse -maps command

echo -n
echo "TEST DSE - MAPS COMMAND"

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test busy->free, free->busy, busy->busy, free->free marks.
# Block 27 is initially BUSY. Take it thru a BUSY->FREE->BUSY cycle
# Block 28 is initially FREE. Take it thru a FREE->BUSY->FREE cycle

$DSE << DSE_EOF

maps -block=27
maps -free
maps
maps -busy
maps
maps -block=28
maps -busy
maps
maps -free
maps
quit

DSE_EOF

# map an already busy/free block to busy/free again

$DSE << DSE_EOF

maps -bl=28 -free
maps
maps -bl=27 -busy
maps

DSE_EOF

# Test -restore_all qualifier
# restore_all should set the local bit map to reflect the
#  blocks used in database

$DSE << DSE_EOF

maps -bl=28 -busy
maps
maps -restore_all
maps

DSE_EOF

# test speciying a bit map for the actions

$DSE << DSE_EOF

maps -bl=0
maps -free -bl=0
maps -busy -bl=0
maps

DSE_EOF
# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
