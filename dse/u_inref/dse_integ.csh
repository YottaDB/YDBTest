#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#Test dse -integ command

echo "TEST DSE - INTEG COMMAND"

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2 -block_size=1024

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# integ on block zero
# save block 4, remove star record from it, then restore
# integ both before and after restoring

$DSE << DSE_EOF

integ -bl=0
save -bl=4
remove -bl=4 -re=24
integ
restore -bl=4 -ver=1
integ

DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
