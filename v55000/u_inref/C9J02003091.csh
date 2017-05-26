#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if !($?gtm_test_replay) then
	set cpbkup = `$gtm_exe/mumps -run rand 2`
	set nob4jnl = `$gtm_exe/mumps -run rand 2`
	echo "# Copy or Backup the database randomness chosen : $cpbkup"	>>&! settings.csh
	echo "setenv cpbkup $cpbkup"						>>&! settings.csh
	echo "# set nobefore journaling instead of default : $nob4jnl"		>>&! settings.csh
	echo "setenv nob4jnl $nob4jnl"						>>&! settings.csh
endif
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps 1

echo "# Turn on journaling with -file= pointing to the database itself. Expect GTM-E-FILEEXISTS and GTM-E-JNLNOCREATE"
$MUPIP set $tst_jnl_str,file=mumps.dat -reg "*"

echo "# Now Turn on journaling normally"
if ($?nob4jnl) then
	$MUPIP set -journal="on,enable,nobefore" -reg "*" 	>&! jnl_on_1.out
else
	$MUPIP set $tst_jnl_str -reg "*" 			>&! jnl_on_1.out
endif
$grep "GTM-I-JNLSTATE" jnl_on_1.out

echo "# Turn on journaling again with -file= pointing to the database itself. Expect GTM-E-FILEEXISTS and GTM-E-JNLNOCREATE"
$MUPIP set $tst_jnl_str,file=mumps.dat -reg "*"

echo "# Do some updates"
$gtm_exe/mumps -run %XCMD 'for i=1:1:10 s ^a(i)=$justify(i,i)'

echo "# Now backup the database using cp or mupip backup"
set backup_dir = backup_dir
mkdir $backup_dir
if ($?cpbkup) then
	$MUPIP backup -noon -bkupdbjnl="OFF" "*" $backup_dir >&! mupip_backup.out
else
	cp mumps.dat $backup_dir
endif
cp mumps.gld mumps.mjl $backup_dir
if ("ENCRYPT" == "$test_encryption" ) then
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig > $gtmcrypt_config
	setenv gtmcrypt_config $cwd/gtmcrypt.cfg
endif

echo "# In the backup directory, try some journal enabling commands"
cd $backup_dir

echo "# mupip set -journal=on -reg * should fail with GTM-E-FILEEXISTS and GTM-E-JNLNOCREATE"
$MUPIP set $tst_jnl_str -reg "*"

echo "# mupip set -journal=on,file=<existing-file> -reg DEFAULT should fail with GTM-E-FILEEXISTS and GTM-E-JNLNOCREATE"
$MUPIP set $tst_jnl_str,file=mumps.mjl -reg DEFAULT

echo "# mupip set -journal=on,file=<new-file> -reg DEFAUT should work fine"
$MUPIP set $tst_jnl_str,file=newmumps.mjl -reg DEFAULT	>&! jnl_on_2.out
$grep "GTM-I-JNLSTATE" jnl_on_2.out

echo "# The journal file shoud have NO previous links"
$MUPIP journal -show -forward newmumps.mjl 		>&! jnl_show.out
$grep "file name" jnl_show.out

cd ..
$gtm_tst/com/dbcheck.csh

