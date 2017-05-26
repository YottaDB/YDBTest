#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# simple updates in the background

$GTM << EOF >&! bg_gtm.out &
set instancename="INSTANCE1"
set noofupdates=$1
write \$H,!
do ^simpleinstanceupdate(0)
write \$H,!
write "will wait until told to quit (endbgupdate.txt) ...",!
for  quit:\$zsearch("endbgupdate.txt")'=""
write "OK, was told to quit, bye",!
write \$H,!
halt
EOF
