#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2 -block_size=1024

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test dse -remove command

echo "TEST DSE -REMOVE COMMAND"

# remove a block before saving it
# save it
# remove the saved version, list the saved versions

$DSE << DSE_EOF

remove -blo=4
remove -blo=4 -ver=2
save -blo=4
remove  -ver=1 -blo=4
save -list

DSE_EOF

# remove -block with only one version

$DSE << DSE_EOF

save -bl=2
remove -bl=2
save -list

DSE_EOF

# remove a record, then try 'find'ing it

$DSE << DSE_EOF

find -key="^aglobal(1224,44064)"
remove  -re=4 -bl=27
find -key="^aglobal(1224,44064)"
add -bl=27 -re=4 -key="^aglobal(1224,44064)" -data="xyz"

DSE_EOF

# try removing non existing records

$DSE << DSE_EOF

remove -re=0 -bl=27
remove -re=23 -bl=27

DSE_EOF

# remove at an offset

$DSE << DSE_EOF

find -bl=27
remove  -offset=0 -bl=27
remove  -offset=261 -bl=27
dump -bl=27 -off=10 -hea
remove  -offset=10 -bl=27
dump -bl=27 -off=10 -hea
add -bl=27 -re=1 -key="^aglobal(1221,43956)" -data="xyz"

DSE_EOF

# try removing a record from block zero

$DSE << DSE_EOF

save -bl=0
remove -bl=0 -offset=9
remove -bl=0 -record=2
restore -bl=0 -ver=1
remove -bl=0
DSE_EOF

# test 'count' qualifier

$DSE << DSE_EOF

save -bl=4
dump -bl=4 -rec=2 -hea
remove -rec=2 -count=0 -bl=4
dump -bl=4 -rec=2 -hea
remove -rec=2 -count=2 -bl=4
restore -bl=4 -ver=1

DSE_EOF

# remove a star record

$DSE << DSE_EOF

save -bl=4
remove -rec=24 -bl=4
integ
restore -bl=4 -ver=1

DSE_EOF

# try both offset and record together

#$DSE << DSE_EOF

#remove  -reco=4 -off=41 -block=3
#remove  -off=41 -reco=4 -block=3

#DSE_EOF

# save block 1 three times and remove the first version to see that the copy down works correctly
$DSE << DSE_EOF
save
save
save
remove -ver=1
dump -head
restore -version=2
dump -head
remove -ver=2
remove
DSE_EOF

# save block in one region and show it can't be removed when we're in another

$DSE << DSE_EOF
save -bl=1
find -region=default
remove -bl=1
DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
