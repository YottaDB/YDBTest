#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Usage:
# $gtm_tst/com/switch_chset.csh <optional chset value>
# if no argument specified gtm_chset will be left undefined and hence CHSET will subsequently gets switched to "M"
#
set arg=`echo $1|tr '[a-z]' '[A-Z]'`

# Make it a noop if the current $gtm_chset value matches what needs to be set.
if ("" != "$arg") then
	if ($?gtm_chset) then
		if ("$arg" == "$gtm_chset") then
			# Both $arg and the current $gtm_chset are the same. Exit silently
			# The dummy line below is to satisfy the existing reference files. There are 80+ tests that do an unconditional $switch_chset
			# If the exising gtm_chset is the same (randomly chosen) the bypass would not print the setenv gtm_chset line and would cause reference file issues
			# Since the number of files to be fixed is too many, we decided to do this workaround - But the right way to do is to redirect the output and fix the reference file
			set echo;setenv gtm_chset "$arg";unset echo
			exit 0
		endif
	endif
else
	if (! $?gtm_chset) then
		# $arg is null and $gtm_chset is not defined, which is exactly the same. Exit silently
		set echo;unsetenv gtm_chset;unset echo
		exit 0
	endif
endif

if ( "UTF-8" == $arg ) then
	set echo;setenv gtm_chset "UTF-8";unset echo
	# set locale utf8 specific
	source $gtm_tst/com/set_locale.csh
	# all gtm sources are compiled under M mode.
	# If we change to utf-8 in the test then the library routines and GDE will croak on looking at M
	# compiled objects. So instruct the gtmroutines to look at the utf8 subdir inside gtm_exe
	source $gtm_tst/com/set_gtmroutines.csh "UTF8"
	set record_chset="setenv gtm_chset $gtm_chset"
else if ( "M" == $arg ) then
	set echo;setenv gtm_chset "M";unset echo
	# restore gtmroutines to its original value
	source $gtm_tst/com/set_gtmroutines.csh "M"
	set record_chset="setenv gtm_chset $gtm_chset"
	setenv LC_ALL C
else
	set echo;unsetenv gtm_chset;unset echo
	# restore gtmroutines to its original value
	source $gtm_tst/com/set_gtmroutines.csh "M"
	set record_chset="unsetenv gtm_chset"
	setenv LC_ALL C
endif
# whenever we switch gtm_chset the old compiled routines in the test directory will be complaining of incompatability
# so delete them. Take a log what is getting deleted - might help in debugging for failed tests
# use find instead of rm to prevent tcsh errors when there are no files found
setenv timeswitch `date +%H_%M_%S`
pwd >&! switch_chset_$timeswitch.log
find -name "*.o" -print -delete >>&! switch_chset_$timeswitch.log

# settings.csh will be used by scripts like mupip_set_version.csh etc. and someother  random decision taken.
# since the test flow starts with some gtm_chset value which is different now after the current switch,
# we need to record this piece of information in settings.csh as well, so that we override the correct value of gtm_chset
# whenever the script gets sourced
echo "# test over rides gtm_chset here"		>>! settings.csh
echo $record_chset				>>! settings.csh
exit $status
#
