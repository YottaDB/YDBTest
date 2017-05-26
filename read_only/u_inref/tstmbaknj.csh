#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#Tests of mupip command "BACK" on read_only database files: mumps.dat,a.dat,b.dat,c.dat
echo ""
echo "*** TSTMBAKNJ ***"
echo ""
alias dbcheck '$gtm_tst/com/dbcheck.csh; $gtm_tst/com/backup_dbjnl.csh back "*.gld" cp nozip; cd back; $gtm_tst/com/dbcheck.csh ; cd - '
set verbose

$gtm_tst/com/dbcreate.csh mumps $1

$GTM << bbb
w "Do in0^sfill(""set"",1,$1)",!
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat

unset verbose
if ("ENCRYPT" == "$test_encryption") then
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig > $gtmcrypt_config
	setenv gtmcrypt_config $cwd/gtmcrypt.cfg
endif
set verbose
mkdir ./back
$MUPIP backup -noonline "*" ./back | & sort -f
mipcmanage
dbcheck
\rm -f ./back/*

echo "***** changing b.dat to read_only *****"
chmod 444 b.dat
$MUPIP backup -noonline "*" ./back | & sort -f
mipcmanage
unset verbose
$gtm_tst/com/dbcheck.csh
# b.dat will not be backedup in the back directory
# so a simple dbcheck.csh or mupip integ will not work.Hence the foreach loop and checking of status
set integ_stat = 0
cd back
foreach file (`ls *.dat`)
	$MUPIP integ $file >&! $file.integ
	$grep "No errors detected by integ" $file.integ
	@ integ_stat = $integ_stat + $status
end
cd -
if ( 0 != $integ_stat) then
	echo "TEST-E-INTEG in backup directory"
	cp -r back back_integ_$0:t:r
	echo "check files in back_integ_$0:t:r"
endif
if ("ENCRYPT" == "$test_encryption") setenv gtmcrypt_config `pwd`/gtmcrypt.cfg
\rm -rf back *.dat mumps.gld
