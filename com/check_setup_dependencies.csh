#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Usage: source check_setup_dependencies.csh <$gtm_test_com_individual>

# This script checks for the presence of dependencies the test system has.

# ksh	: encrypt_db_key.ksh expects /bin/ksh
# tcsh	: we've seen a few specific tcsh versions to cause issues
# gawk	: GG servers have gawk versions from 3.0.4 to 3.1.6 (lets check for GNU Awk 3)
# sed	: no specific sed version dependency. Just check for the presence
# lsof	: no specific lsof version dependency. Just check for the presence
# bc	: no specific bc version dependency. Just check for the presence
# sort  : no specific sort version dependency. Just check for the presence

if ($?skip_setup_dependencies) then
	echo 0
	exit
endif
set error = 0
set hostn = "$HOST:ar"
set hostos = `uname -s`

set tst_com = "$1"
source $tst_com/set_specific.csh
# make sure backslash_quote is set
# have to fork another tcsh since parent was run with -f

set backdef=`/usr/local/bin/tcsh -c 'if $?backslash_quote echo defined'`
if ("defined" != $backdef) then
	echo "TEST-E-UTILITY expected" '$backslash_quote' "to be set in .cshrc ;"
	@ error++
endif

# make sure system log file is readable
set syslog_file=`$grep -v '^#' $gtm_test_serverconf_file | $grep "^$hostn" | $tst_awk '{print $8}'`
if ("" == $syslog_file) then
	echo "TEST-E-UTILITY problem getting system log file for $hostn from $gtm_test_serverconf_file ;"
	@ error++
else
	if (! -r $syslog_file) then
		echo "TEST-E-UTILITY $syslog_file is not readable ;"
		@ error++
	endif
endif
endif

ls -l /bin/ksh >&! /dev/null
if ($status && "OS/390" != "$hostos") then
	echo "TEST-E-UTILITY /bin/ksh not available ;"
	@ error++
endif

# Make sure tcsh is usable
# The below script would internally increment $error and echo error message
source $tst_com/check_tcsh.csh

# gawk version
set expected_gawk_name = "GNU Awk"
set expected_min_gawk_ver = 3
set gawk_name_and_ver = `gawk -W version | $tst_awk -F . '{print $1;exit;}'`
set gawk_name = `echo $gawk_name_and_ver | $tst_awk '{printf("%s %s",$1,$2)}'`
set gawk_ver = `echo $gawk_name_and_ver | $tst_awk '{print $3}'`
if ( ( "$gawk_ver" < "$expected_min_gawk_ver" ) || ( "$gawk_name" != "$expected_gawk_name" ) ) then
	echo "TEST-E-UTILITY expected gawk version is $expected_gawk_name and min version of $expected_min_gawk_ver but found $gawk_name_and_ver ;"
	@ error++
endif

# /usr/bin/which (used by encryption scripts) on some platforms source ~/.cshrc
# and would exit if there are issues in sourcing ~/.cshrc
if ( (-e /usr/bin/which) && (-e ~/.cshrc) ) then
	/usr/bin/which which >&! /dev/null
	if ($status) then
		echo "TEST-E-UTILITY /usr/bin/which failed. Check if ~/.cshrc has issues"
		@ error++
	endif
endif

which sed >&! /dev/null
if ($status) then
	echo "TEST-E-UTILITY sed expected by test system, but not found ;"
	@ error++
endif

# lsof might be set to some arbitary path in set_specific, so check if it is set first.
if ($?lsof) then
	which $lsof  >&! /dev/null
else
	which lsof >&! /dev/null || which zlsof >&! /dev/null
endif
if ($status) then
	echo "TEST-E-UTILITY lsof expected by test system, but not found ;"
	@ error++
endif

which bc >&! /dev/null
if ($status) then
	echo "TEST-E-UTILITY bc expected by test system, but not found ;"
	@ error++
endif

which sort >&! /dev/null
if ($status) then
	echo "TEST-E-UTILITY sort expected by test system, but not found ;"
	@ error++
endif
# Check maximum shared memory limits
# For now, it is done only on linux machines and the limit is set to 1GB. Increase the scope and limit when needed
if ("Linux" == "$hostos") then
	set shmmax = `/sbin/sysctl kernel.shmmax | gawk '{print $NF}'`
	set shmexp = 1073741824
	# Since it deals with very large numbers, plain if ($a > $b) won't work. Rely on bc
	if ( `echo "($shmmax - $shmexp) < 0" | bc` ) then
		echo "TEST-E-SHMMAX expected to be at least $shmexp, but is only $shmmax."
		echo "Fix the configuration using sysctl -w kernel.shmmax=xxx and add a line in /etc/sysctl.conf ;"
		@ error++
	endif
endif

# Check maximum number of semaphore arrays
# For now, it is done only on linux machines and the check is set to 512. Increse the scope and limit when needed
if ("Linux" == "$hostos") then
	set semarray = `/sbin/sysctl kernel.sem | gawk '{print $NF}'`
	set semarrayexp = 512
	if ($semarrayexp > $semarray) then
		echo "TEST-E-SEMARRAY max number of semaphore arrays expected to be $semarrayexp, but is only $semarray."
		echo "Fix the configuration using sysctl -w kernel.sem=x x x x and add a line in /etc/sysctl.conf ;"
		@ error++
	endif
endif

# Ensure that a user-specific directory for relinkctl files exists and is usable.
source $tst_com/create_user_linktmpdir.csh
if (0 != $status) then
	echo "TEST-E-LINKTMPDIR failed to create a linktmpdir"
	@ error++
endif

# Ensure that a user-specific directory for gpg files exists and is usable.
if ($?test_encryption) then
	if ("NON_ENCRYPT" == $test_encryption) then
		set check_bypass = 1
	endif
endif
if (! $?check_bypass) then
	source $tst_com/create_user_gnupghome.csh
	if (0 != $status) then
		echo "TEST-E-GNUPGHOMEDIR failed to create a GNUPGHOME directory."
		echo "Ensure that test_encryption is set to NON_ENCRYPT on each box where you want this check bypassed ;"
		@ error++
	endif
endif

# Check that $ggdata and its subdirectories are write-accessible
if (-e $ggdata) then
	if (-e $ggdata/tests) then
		if ((! -r $ggdata/tests) || (! -w $ggdata/tests)) then
			echo "$ggdata/tests is not readable or writeable (to create $ggdata/tests/timinginfo etc.)"
			@ error++
		else
			foreach subdir (debuglogs timinginfo testresults)
				if (! -e $ggdata/tests/$subdir) then
					continue
				endif
				if ((! -r $ggdata/tests/$subdir) || (! -w $ggdata/tests/$subdir)) then
					echo "$ggdata/tests/$subdir is not readable or writeable"
					@ error++
				endif
			end
		endif
	else if (! -w $ggdata) then
		echo "$ggdata is not readable or writeable (to create $ggdata/tests)"
		@ error++
	endif
endif

if ($error) then
	echo "The test will not be submitted."
endif
echo $error  # echo required to check status of remote servers while used with ``
exit $error
