#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
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

# Test dse -shift command

echo "TEST DSE - SHIFT COMMAND "

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2 -block_size=1024

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

cp mumps.dat x.dat
# shift the last record in the block by 0x10 bytes forward
# dumping should show 4 empty records each of size 4 bytes
# then do integ

$DSE << DSE_EOF

find -reg=DEFAULT
find -blo=3
shift -bl=3 -forward=10 -offset=3B
dump -bl=3 -rec=1 -count=B -hea
integ

DSE_EOF

# now do the reverse, integ should pass

$DSE << DSE_EOF

find -reg=DEFAULT
find -bloc=3
shift -backward=10 -offset=4B
dump -bl=3 -rec=1 -count=7 -hea
integ

DSE_EOF

# null shifts

$DSE << DSE_EOF

find -reg=DEFAULT
find -bloc=3
shift -forward=0 -offset=20
shift -backward=0 -offset=20

DSE_EOF

# try shifting beyond block size

$DSE << DSE_EOF

find -reg=DEFAULT
find -bloc=3
shift -off=33 -for=532

DSE_EOF

# try shifting from a non existing offset

$DSE << DSE_EOF

find -reg=DEFAULT
find -bloc=3
shift -off=73 -for=50
shift -off=73 -back=50

DSE_EOF

# try shifting backward by more than offset

$DSE << DSE_EOF

find -reg=DEFAULT
find -bloc=3
shift -off=33 -back=53

DSE_EOF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
