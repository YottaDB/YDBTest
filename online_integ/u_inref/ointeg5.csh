#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This subtest verifies that mupip online integ correctly handles various error conditions
# related to not being able to create the snapshot files.

$gtm_tst/com/dbcreate.csh mumps 1

# Since we are going to be moving around in the directory structure, set absolute path to dbkeys file
if ("ENCRYPT" == "$test_encryption" ) setenv gtmcrypt_config $PWD/gtmcrypt.cfg

echo " "
$echoline
echo "# Test Case # 1: Current directory does not have write permissions and gtm_snaptmpdir is not set"
$echoline
unsetenv GTM_BAKTMPDIR
source $gtm_tst/com/unset_ydb_env_var.csh ydb_snaptmpdir gtm_snaptmpdir
mkdir curdirnowriteperms
cd curdirnowriteperms
ln -s ../mumps.gld mumps.gld
ln -s ../mumps.dat mumps.dat
chmod a-w .
set mupip_log = "../mupip_log1.log"
$MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log
echo "# Verify SSTMPCREATE error is present."
if ( "os390" != $gtm_test_osname ) then
	set errENO = "ENO13"
else
	set errENO = "ENO111"
endif
$gtm_tst/com/check_error_exist.csh $mupip_log SSTMPCREATE $errENO MUNOTALLINTEG
echo "# Setting write permissions on directory so test cleanup does not have a problem."
chmod a+w .
cd .. # get back into the standard subtest directory

echo " "
$echoline
echo "# Test Case # 2: Directory pointed to by gtm_snaptmpdir does not exist"
$echoline
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_snaptmpdir gtm_snaptmpdir $PWD/dirdoesnotexist
set mupip_log = "mupip_log2.log"
$MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log
echo "# Verify SSTMPCREATE error is present."
if ( "os390" != $gtm_test_osname ) then
	set errENO = "ENO2"
else
	set errENO = "ENO129"
endif
$gtm_tst/com/check_error_exist.csh $mupip_log SSTMPCREATE $errENO MUNOTALLINTEG

echo " "
$echoline
echo "# Test Case # 3: Directory pointed to by gtm_snaptmpdir does not have write permissions"
$echoline
set snaptmpdir = $PWD/dirwowriteperms
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_snaptmpdir gtm_snaptmpdir $snaptmpdir
mkdir $snaptmpdir
chmod a-w $snaptmpdir
set mupip_log = "mupip_log3.log"
$MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log
echo "# Verify SSTMPCREATE error is present."
if ( "os390" != $gtm_test_osname ) then
	set errENO = "ENO13"
else
	set errENO = "ENO111"
endif
$gtm_tst/com/check_error_exist.csh $mupip_log SSTMPCREATE $errENO MUNOTALLINTEG
echo "# Setting write permissions on directory so test cleanup does not have a problem."
chmod a+w $snaptmpdir

echo " "
$echoline
echo "# Test Case # 4: Directory pointed to by gtm_snaptmpdir is actually a file"
$echoline
set snaptmpdir = $PWD/dirisafile
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_snaptmpdir gtm_snaptmpdir $snaptmpdir
touch $snaptmpdir
set mupip_log = "mupip_log4.log"
$MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! $mupip_log
echo "# Verify SSTMPCREATE error is present."
if ( "os390" != $gtm_test_osname ) then
	set errENO = "ENO2"
else
	set errENO = "ENO135"
endif
$gtm_tst/com/check_error_exist.csh $mupip_log SSTMPCREATE $errENO MUNOTALLINTEG
source $gtm_tst/com/unset_ydb_env_var.csh ydb_snaptmpdir gtm_snaptmpdir
$gtm_tst/com/dbcheck.csh
