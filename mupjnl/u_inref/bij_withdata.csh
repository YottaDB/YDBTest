#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case: 04 - bij_withdata"
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -journal=enable,before -reg "*"
$GTM << EOF
f i=1:1:100 s ^val(i)=i
EOF
echo "Back up the database"
mkdir ./save;cp {*.dat,*.mjl*} ./save
# with backward direction
echo "---------------------------------------------------------"
set eov1 = "`$MUPIP journal -show=header -forw mumps.mjl |& $grep 'Time of last update'`"
echo "mupip journal -recover -backward mumps.mjl"
$MUPIP journal -recover -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
$GTM << EOF
d ^test04
EOF
set eov2 = "`$MUPIP journal -show=header -forw mumps.mjl |& $grep 'Time of last update'`"
if ("$eov1" != "$eov2") then
	echo "Recover command has changed last record's time stamp"
	echo "$eov1...$eov2"
endif
echo "---------------------------------------------------------"
echo "delete database"
rm *.dat
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable
# gtm_extract_nocol to non-zero value.
setenv gtm_extract_nocol 1
echo "mupip journal -extract -backward mumps.mjl"
$MUPIP journal -extract -backward mumps.mjl
unsetenv gtm_extract_nocol
echo "---------------------------------------------------------"
echo "mupip journal -verify -backward mumps.mjl"
$MUPIP journal -verify -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
echo "mupip journal -show -backward mumps.mjl"
$MUPIP  journal -show -backward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
## end transaction will be 101
echo "---------------------------------------------------------"
# all action qualifiers together and backward option
echo "mupip journal -extract -verify -recover -show -backward mumps.mjl"
echo "This should fail, because there  is no database"
$MUPIP journal -extract -verify -recover -show -backward mumps.mjl
echo "---------------------------------------------------------"
echo "Now copy  the backup database"
cp -f ./save/*.dat .
echo "mupip journal -extract -verify -recover -show -backward mumps.mjl"
$MUPIP journal -extract -verify -recover -show -backward mumps.mjl
echo "---------------------------------------------------------"
# with forward option
# will give JNLDBTNNOMATCh error message
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover -forward mumps.mjl
echo "---------------------------------------------------------"
echo "mupip journal -recover -forward mumps.mjl -nochecktn"
$MUPIP journal -recover -forward mumps.mjl -nochecktn
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
echo "mupip journal -extract -forward mumps.mjl"
$MUPIP journal -extract -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
echo "mupip journal -show -forward mumps.mjl"
$MUPIP journal -show -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
echo "Now delete database"
rm *.dat
$MUPIP create
echo "make journal file read-only and then run recover"
chmod 444 *.mjl*
echo "mupip journal -recover -forward mumps.mjl"
$MUPIP journal -recover -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
$GTM << EOF
d ^test04
EOF
echo "---------------------------------------------------------"
rm *.dat
# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable
# gtm_extract_nocol to non-zero value.
setenv gtm_extract_nocol 1
echo "mupip journal -extract -forward mumps.mjl"
$MUPIP journal -extract -forward mumps.mjl
unsetenv gtm_extract_nocol
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
echo "mupip journal -verify -forward mumps.mjl"
$MUPIP journal -verify -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
echo "mupip journal -show -forward mumps.mjl"
$MUPIP journal -show -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
rm *dat
$MUPIP create
echo "mupip journal -recover -extract -verify -show -forward mumps.mjl"
$MUPIP journal -recover -extract -verify -show -forward mumps.mjl
if ($status == 0) then
	echo "PASSED"
else
	echo "FAILED"
endif
echo "---------------------------------------------------------"
rm *.mjf
$GTM << EOF
d ^test4so
EOF
set time1=`cat time1.txt_abs`
echo mupip journal -extract -backward -since=\"$time1\" -before=\"$time1\" mumps.mjl
$MUPIP journal -extract -backward -since=\"$time1\" -before=\"$time1\" mumps.mjl
echo "---------------------------------------------------------"
## add for C9C06-002010 - test plan is not clear
echo "For TR C9C06-002010"
\rm  *.dat
chmod 0666 *.mjl*
\mv *.mjl* ./save
$MUPIP create
$MUPIP  set -journal="enable,before" -file mumps.dat
$GTM << EOF
d ^c2010
EOF

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
set sincetime = `cat sincetime.txt_abs`
$MUPIP journal -recover -back -since=\"$sincetime\" mumps.mjl
$GTM << EOF
w ^a(1),",",^a(3),",",^a(4),!,^a(2),!
EOF
echo "Now extract..."
$MUPIP journal -extract="c2010.mjf" -det -forw mumps.mjl
echo "End of test"
$gtm_tst/com/dbcheck.csh
