#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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

# The max value of gtmsecshr_sock_name on various platforms
# The maximum value we are getting from the sizeof sun_path variable which is member sockaddr_un.
## 92 atlhxit1
## 92 atlhxit2
## 1024 lespaul and pfloyd
## 108 <all others>

echo "Create database file"
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 >&! dbcreate.out

echo "Change the permission for mumps.dat"
chmod 444 mumps.dat

# For AIX the sizeof(sun_path) is 1024 which matches GTM_PATH_MAX so creation of LOGTOOLONG is
# not possible on AIX. Just go with the same value everyone else uses and deal with it below.
set maxvalue = 108

# If the $gtm_tmp is less then the maximum length, make $gtm_tmp value to exceed max value
setenv gtm_tmp `pwd`
set pwdlen = `pwd | wc -c`
if ($pwdlen < $maxvalue) then
	@ diffe = $maxvalue - $pwdlen
	setenv gtm_tmp $gtm_tmp"/"
	set i = 1
	while ( $i != $diffe)
		setenv gtm_tmp $gtm_tmp"A"
		@ i = $i + 1
	end
endif
set tstno = 1
set tempdir = "$gtm_tmp"
echo "Create gtm_tmp directory"
mkdir $tempdir
# Make sure gtmsecshr not running so can do the proper envvar checking
$gtm_com/IGS $gtm_dist/gtmsecshr "STOP"

echo "Try to write some data to data base file which will cause fail and it starts gtmsecshr"
$gtm_dist/mumps -dir >& gtm_gtmsecshr.log <<here
set ^a=1
zsystem "ls -al ${tempdir}/gtm_s* "
here

$gtm_tst/com/check_error_exist.csh gtm_gtmsecshr.log "YDB-E-LOGTOOLONG" >>& test.logx
if ($status) then
	if ("aix" == "$gtm_test_osname") then
	    echo "TEST-I-PASSED.. YDB-E-LOGTOOLONG found in gtm_gtmsecshr.log" # White lie so reference file matches
	else
	    echo "TEST-E-FAILED.. YDB-E-LOGTOOLONG not found in gtm_gtmsecshr.log"
	endif
else
	echo "TEST-I-PASSED.. YDB-E-LOGTOOLONG found in gtm_gtmsecshr.log"
endif

if ( "HOST_OS390_S390" == "$gtm_test_os_machtype" ) then
	set error_msg = "YDB-E-MUTEXERR"
else
	set error_msg = "YDB-E-DBPRIVERR"
endif

$gtm_tst/com/check_error_exist.csh gtm_gtmsecshr.log "$error_msg" >>& test.logx
if ($status) then
	echo "TEST-E-FAILED.. $error_msg not found in gtm_gtmsecshr.log"
else
	echo "TEST-I-PASSED.. $error_msg found in gtm_gtmsecshr.log"
endif

unsetenv gtm_tmp
chmod 666 mumps.dat
$MUPIP rundown -region '*'
$gtm_tst/com/dbcheck.csh

if ("HOST_AIX_RS6000" == "$gtm_test_os_machtype") then
    $gtm_com/IGS $gtm_dist/gtmsecshr "STOP"  # Make sure secshr with bogus gtm_tmp dies now so doesn't affect other tests
endif

echo "SUBTEST END"
