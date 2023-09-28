#!/usr/local/bin/tcsh -f
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

# Test the dse -add command

echo "TEST DSE - ADD  COMMAND"

#create a global directory with two regions -- DEFAULT, REGX
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_use_V6_DBs 0   # Disable V6 DB mode as it causes changes in output of DSE commands (block #s, offsets, etc)

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# try adding a data/pointer record to the block zero
# try with record qualifier followed by offset qualifier
# try adding a star record to block zero

$DSE << DSE_EOF

add -bl=0 -data="add me" -key="^aglobal(29)" -rec=1
add -bl=0 -pointer=60  -key="^aglobal(30)" -rec=27
add -bl=0 -data="add me" -key="^aglobal(29)" -offset=0
add -bl=0 -pointer=60  -key="^aglobal(30)" -offset=10
add -bl=0 -pointer=60  -key="^aglobal(30)" -offset=27
add -bl=0 -star -poin=32

DSE_EOF

# add a record to an empty data block
# try adding  a record beyond the last existing record
# try adding a record to an already full block

$DSE << DSE_EOF

add -bl=30 -data="add me" -key="^aglobal(23)" -rec=1
dump -bl=30 -re=1 -hea
add -bl=30 -data="add me" -key="^aglobal(24)" -rec=3
add -bl=27 -data="add me" -key="^aglobal(25)" -rec=1
remove -bl=27 -re=1
remove -bl=30 -re=1

DSE_EOF

# try with some incorrect key combinations

$DSE << DSE_EOF

add -bl=30 -re=1 -key="^aglobal(strkey)" -data=" key error"
add -bl=30 -re=1 -key="aglobal(strkey)" -data=" key error"
add -bl=30 -re=1 -key="^xyz(strkey)" -data=" key error"
add -bl=30 -re=1 -key="^aglobal(""str"")" -data="add me"
dump -bl=30 -re=1 -head
remove -bl=30 -re=1

DSE_EOF

# try escapes codes in the data field

$DSE << DSE_EOF

add -bl=30 -re=1 -key="^aglobal(""str"")" -data="\\i\in\nv\vi\is\si\ib\bl\le\\"
dump -bl=30 -re=1 -head
remove -bl=30 -re=1

DSE_EOF

# add a record to an index block
# try adding a data record to an index block
# try adding a record beyond the last existing record in an index block

$DSE << DSE_EOF

add -bl=4 -pointer=50 -key="^aglobal(27)" -rec=1
dump -bl=4 -rec=1 -hea
remove  -rec=1
add -bl=4 -data="add me" -key="^aglobal(26)" -rec=1
add -bl=4 -pointer=56 -key="^aglobal(28)" -rec=27

DSE_EOF


# miss the block number parameter to the command

$DSE << DSE_EOF

find -bl=29

add -data="add me" -key="^aglobal(31)" -rec=1
add -data="add me" -key="^aglobal(32)" -rec=3
dump -bl=29 -rec=1 -head
remove -rec=1

DSE_EOF

# same as above but for an index block

$DSE << DSE_EOF

find -bl=1

add -pointer=50 -key="^aglobal(33)" -rec=1
dump -rec=1 -he
remove  -rec=1

DSE_EOF

# remove an existing star record and add it later

$DSE << DSE_EOF

remove -re=1 -bl=1
add -star -bl=1 -pointer=2

DSE_EOF

# commands with offset qualifier

$DSE << DSE_EOF

add -bl=4 -pointer=50 -key="^aglobal(38)" -offset=10
remove  -rec=1

DSE_EOF

# try giving too low offset, minimum possible offset, too large offset
# try adding to an already full block

$DSE << DSE_EOF

add -bl=38 -data="add me" -key="^aglobal(34)" -offset=0
add -bl=38 -data="add me" -key="^aglobal(35)" -offset=10
dump -bl=38 -off=10  -hea
remove -off=10
add -bl=38 -data="add me" -key="^aglobal(36)" -offset=E2
add -bl=27 -data="add me" -key="^aglobal(37)" -offset=10
remove -bl=27 -off=10

DSE_EOF

# missing qualifiers

$DSE << DSE_EOF

add -bl=30 -data="add me"
add -bl=30  -key="^aglobal(2334)"
add -bl=30  -rec=1
add -bl=30 -data="add me" -key="^aglobal(3333)"
add -bl=30 -data="add me"  -rec=1

add -bl=38 -offset=10
add -bl=38 -data="add me" -offset=10
add -bl=38 -key="^aglobal(423)" -offset=10

DSE_EOF

# try with an error in the command  < missing matching semicolon in key >

$DSE << DSE_EOF

add -block=3 -rec=2 -key="^aglobal(""xyz"") -data="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"

DSE_EOF

# try adding a record with a big data portion

$DSE << DSE_EOF

change -fi -rec=1024

add -block=29 -rec=1 -key="^aglobal(""xyz"")" -data="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"

dump -bl=29 -rec=1 -hea
remove -bl=29 -rec=1
change -fi -rec=256

DSE_EOF

# Try adding a null subscripted key
# change the fileheader to allow null subscripts inkey
# add it again

$DSE << DSE_EOF

add -block=3 -rec=2 -key="^aglobal("""")" -data="abc"
change -fi -null=TRUE
add -block=3 -rec=2 -key="^aglobal("""")" -data="abc"
dump -bl=3 -re=2 -hea
remove -bl=3 -re=2
change -fi -null=FALSE

DSE_EOF

# take a valid action on a bit map
# then try an add without specifing a block - it should give an error

$DSE << DSE_EOF

dump -block=0 -header
add -rec=1 -key="^abcd" -pointer=10
dump -header

DSE_EOF

# the following not supposed to work...
# add -offset=10 -record=1 -block=30 -key=^aglobal(234) -data="abcd"
# add -offset=250  -block=30 -key=^aglobal(235) -data="abcd" -rec=2

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
