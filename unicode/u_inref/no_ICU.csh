#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This will be the only subtest that runs on platforms that do not have ICU support
# DISABLE this test on all platforms that has ICU
#
# grab first the locale information as  the order of checking is first locale and then followed by ICU libraries
# scylla's locale -a gives binary output and grep needs -a option to get the actual value instead of "Binary file (standard input) matches"
# but -a is not supported on non-linux servers.
if ("Linux" == "$HOSTOS") then
	set binaryopt = "-a"
else
	set binaryopt = ""
endif
set locale_info=`locale -a | $grep $binaryopt -iE 'en_us\.utf.?8$' | $head -n1`
set echo;set verbose;setenv gtm_chset "UTF-8";unset echo;unset verbose
echo "Expected NONUTF8LOCALE or DLLNOOPEN error because of locale or ICU absence"
if ( "" != $locale_info ) then
	# this is because LC_CTYPE would be "C" in startup sometimes and so we will not be seeing the expected error message
	setenv LC_CTYPE $locale_info
	unsetenv LC_ALL
	$GTM >&! nonutf8locale.out
	# again here we will have two kinds of error messages - so account for both
	# DLLNOOPEN will be issued when no ICU is installed in the box
	# ICUSYMNOTFOUND will be issued when ICU is built with symbol renaming but gtm_icu_version is not defined. Right now,
	# 		 this error is issued only in beowulf where we have ICU version 3.4 and trying to run GT.M will result
	#		 in this error. Note, on beowulf setting gtm_icu_version to 3.4 might not also help as that will issue
	# 		 ICUVERLT36 on beowulf.
	# either case GTM wont startup.
	if (`$grep -c "DLLNOOPEN" nonutf8locale.out`) $gtm_tst/com/check_error_exist.csh nonutf8locale.out "DLLNOOPEN"
	if (`$grep -c "ICUSYMNOTFOUND" nonutf8locale.out`) $gtm_tst/com/check_error_exist.csh nonutf8locale.out "ICUSYMNOTFOUND"
else
	$GTM >&! nonutf8locale.out
	$gtm_tst/com/check_error_exist.csh nonutf8locale.out "NONUTF8LOCALE"
endif
#
set echo;set verbose;setenv gtm_chset "M";unset echo;unset verbose
echo "This should work"
$GTM << \eof
write "Hello I am fine without ICU",!
for i=1:1:50 s a(i)=$justify($extract("abcdef"_$CHAR(111,112,113)_$ASCII("xyz"),i,$length(i)),i)
zwrite a
for i=1:1:50 s b(i)=$justify($extract("abcdef"_$CHAR(111,112,113)_$ASCII("xyz"),i,$length(i)),50-i)
zwrite b
halt
\eof
#
