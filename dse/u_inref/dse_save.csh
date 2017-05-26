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

# Test dse -save command

echo "TEST DSE - SAVE COMMAND"
#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# save block 3
# corrupt third block and restore from the saved version
# list an unsaved block
# save and restore block zero

$DSE << DSE_EOF

save -bl=3
save -bl=3 -co="first version"
save -bl=3 -co="first version"

overwrite -data="corrupting the block" -offset=13
integ
restore -ver=1
overwrite -data="corrupting the block" -offset=20
restore -ver=1
integ

DSE_EOF

# list the saved versions of block 4

$DSE << DSE_EOF

save -bl=4 -list

DSE_EOF

# save block zero and do the same as above

$DSE << DSE_EOF

save -bl=0
overwrite  -data="corrupting " -offset=20
integ
restore -v=1
integ

DSE_EOF

# test the -list qualifier

$DSE << DSE_EOF

save -bl=3 -comment="has comment"
save -bl=3
save -bl=1 -comment="first block"
save -list
save -list -bl=3

DSE_EOF

#test the limit by saving block 1 129 time - one more copy than DSE can hold (128); remove 1 - it should fit

$DSE << DSE_EOF
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
save
remove -version=1
save
DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
