#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# C9J09003198.csh - test gtm_permission() changes to support invalid user/groups
# Create the database manually instead of using dbcreate
$gtm_exe/mumps -run GDE >& gde1.log << GDE_EOF
exit
GDE_EOF
$gtm_exe/mupip create >& create1.log
# turn off world access to force uid/gid lookup
chmod 660 mumps.dat

# change owner of mumps.dat to a bogus uid=55555
$gtm_com/IGS BOGUSCHOWN 1
echo
echo "** test bogus owner 55555"
echo "** journal file will be world rw since 55555 is not a member of gtc group"
echo
$gtm_exe/mupip set -journal=enable,on,nobefore -region "*" >& journal1.log
ls -al mumps.* > mumps1.log
ls -al mumps.dat | $tst_awk '{printf "%s  %s   %s %10s\n",$1,$3,$4,$NF}'
ls -al mumps.mjl | $tst_awk '{printf "%s  $USER   %s %10s\n",$1,$4,$NF}'

$gtm_exe/mumps -dir <<here
set ^a=1
write "^a = ",^a,!
here

$gtm_tst/com/dbcheck.csh
$gtm_exe/mupip rundown -file mumps.dat

mv mumps.dat savemumps.dat
mv mumps.gld savemumps.gld
mv mumps.mjl savemumps.mjl

$gtm_exe/mumps -run GDE >& gde2.log << GDE_EOF
exit
GDE_EOF
$gtm_exe/mupip create >& create2.log
# turn off world access to force uid/gid lookup
chmod 660 mumps.dat

# change cur_group to a bogus gid
$gtm_com/IGS BOGUSCHOWN 2
echo
echo "** test bogus group 55555"
echo "** journal file will be world rw since installation is not group restricted"
echo
$gtm_exe/mupip set -journal=enable,on,nobefore -region "*">& journal2.log
ls -al mumps.* > mumps2.log
ls -al mumps.dat | $tst_awk '{printf "%s  $USER  %s %10s\n",$1,$4,$NF}'
ls -al mumps.mjl | $tst_awk '{printf "%s  $USER  %s %12s\n",$1,$4,$NF}'
$gtm_exe/mumps -dir <<here
set ^a=1
write "^a = ",^a,!
here

$gtm_tst/com/dbcheck.csh

echo "# End of C9J09003198 testing"
