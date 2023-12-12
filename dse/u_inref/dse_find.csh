#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Disable using V6 DB mode due to differences in the block #s and offsets in output of DSE FIND
setenv gtm_test_use_V6_DBs 0
# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2 -block_size=1024

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
do ^misce
halt
GTM_EOF

# Test dse -find command

echo "TEST DSE - FIND COMMAND"

# find a block

$DSE << DSE_EOF

find -bl=0
find -bl=4
find -bl=232

DSE_EOF

# test -freeblock qualifier

$DSE << DSE_EOF

find -freeblock -hint=0
find -freeblock -hint=4
find -freeblock -hint=232

DSE_EOF

# test -key qualifier

$DSE << DSE_EOF

find -key="^aglobal(1223,44028)"
find -key="^aglobal(1227,44028)"

DSE_EOF

# try with a non existing global name
# try with a local variable name

$DSE << DSE_EOF

find -key="^notglobal"
find -key="notglobal"

DSE_EOF

# test -region qualifier
# try existing/non_existing regions

$DSE << DSE_EOF

find -region=*
find -reg
find -reg=AREG
find -reg=AREG
find -reg=DEFAULT
find -reg="NOREG"

DSE_EOF

# test -siblings qualifier
# check for a chain of siblings  25 - 26 - 27 -3

$DSE << DSE_EOF

find -siblings -bloc=3
find -siblings -bloc=27
find -siblings -bloc=26

DSE_EOF

# try with block zero and nonexisting block

$DSE << DSE_EOF

find -sib -bl=0
find -sib -bl=230

DSE_EOF

# find a record with minimum possible record size (7 bytes)

$DSE << DSE_EOF

find -reg=DEFAULT
find -key="^x(""abcd"")"

DSE_EOF

# find a key with '"' as a character in subscript (four doubles quotes needed)

$DSE << DSE_EOF

find -reg=DEFAULT
find -key="^x(""abc""""def"")"

DSE_EOF

#find some complicated keys

$DSE << DSE_EOF >& find.log
find -reg=DEFAULT
find -key=^misc(123)
find -key=^misc(123,456)
find -key=^misc(456)
find -key=^misc(\$ZChar(25))
find -key=^misc(\$ZChar(25),"""*""")
find -key=^misc(\$ZChar(25),"""*""","""string""")
find -key=^misc(\$ZChar(25),"""*""","""string""",123)
find -key=^misc(\$ZChar(25),"""+""")
find -key=^misc("""str1""")
find -key=^misc("""str1""","""str2""")
find -key=^misc("""str1""","""str3""")
find -key=^misc("""string""")
find -key=^misc("""string1""")
find -key=^misc(\$ZChar(255))
find -key=^misc
find -key=^misc(""""""""")
DSE_EOF

echo grep \"Key found in block find.log\"	# BYPASSOK
$grep "Key found in block" find.log

echo
echo "# Test of YDB@198872d1 (test invalid command in DSE does not cause ASAN global-buffer-overflow error in Debug build)"
$DSE << DSE_EOF
invalidcmd
DSE_EOF

echo

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh

# these last two tests mess with the global directory, don't actually touch the database, and so come after the dbcheck
# force the region to use another (noexistant) node so DSE rejects the region as accessed by GT.CM
$GDE change -segment DEFAULT -file=foo:/testarea1/mups.database

$DSE << DSE_EOF
find -region=default

DSE_EOF
# force the region to use an nonexistent database file so DSE rejects the region as not open
$GDE change -segment DEFAULT -file=/testarea1/foo.dat

$DSE << DSE_EOF
find -region=default

DSE_EOF

