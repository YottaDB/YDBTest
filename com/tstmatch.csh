#!/usr/local/bin/tcsh -f
###########################################################
#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
###########################################################

# Display all tests/subtests matching $1 which is in the form [test/]pattern.
# If [test/] is omitted and pattern exactly matches a test, return only pattern.
# Otherwise return all subtests matching test/*pattern* where test defaults to '*'
#
# This script may be used to perform tab-completion using the following tcsh command:
#     complete gtmtest 'c|*|`$gtm_test_com_individual/tstmatch.csh`|'
# Note: the above line must use 'c|*' instead of 'n|-t' to allow output of forms not starting with $1

# Select directory to scan for test name in this order:
#  - current directory's git repository if it is a YDBTest clone
#  - $0:h:h if it is a YDBTest clone
#  - $work_dir/YDBTest
set searchdir = "`git rev-parse --show-toplevel >& /dev/stdout`"
if ( $? || ! -e "${searchdir:q}/com/gtmtest.csh" ) then
	set searchdir = $0:h:h
	if ! ( -e "${searchdir:q}/com/gtmtest.csh" ) then
		set searchdir = "${work_dir:q}/YDBTest"
	endif
endif

set arg = "$1:q"
# Get arg from command line if invoked by tab-completion
if ( $?COMMAND_LINE ) then
	set args = ( $COMMAND_LINE )   # split command line into words
	set prev = $#args
	if ( "$COMMAND_LINE" !~ "* " ) @ prev--
	if ( $prev == 0 || "${args[$prev]:q}" != "-t" ) exit 0   # Do nothing if prev arg is not '-t'
	if ( "${args[$#args]:q}" != "-t" ) set arg = "${args[$#args]:q}"
else if ( "$arg" !~ "*/*" && -d $searchdir/$arg ) then
	# If arg exactly matches a test name, return just that test
	echo $arg
	exit 0
endif

# Otherwise, look for a test/subtest substring match
set test = "$arg:h"
set subtest = "$arg:t"
if ( "$arg" !~ "*/*" ) set test = "*"   # if no '/' in pattern, match all tests

# The following grep is made faster by being fairly explicit
# Note: '\x7f' is appended to end of line as a unique line delimeter since command substitution replaces newlines with spaces.
# (To observe the problem when lines are all concatenated into one, run 'tstmatch.csh env' with the '\x7f' ending removed)
set testlist = `grep -EH '^setenv[ \t]+(subtest_list_[^ \t]|unicode_testlist).*'$subtest $searchdir/$test/instream.csh | sed -Ee 's/(.*)/\1\x7f/'`
if ( $? != 0 ) exit 0

# Note: re '\x7f " line delimiter, see comment above
set matches = `echo "$testlist" | awk -F '[" \t]+' 'BEGIN {RS="\x7f "} \
	{n=split($1,name,"/"); test=name[n-1]; for (i=3; i<NF; i++) if ($i !~ "^[$]" && $i ~ "'$subtest'") print test "/" $i} \
	'`

if ( $#matches == 0 ) exit
if ( $?COMMAND_LINE ) then
	# Tab-completion requires output of just the appendages to $arg, not the full match
	set appendages = `echo "$matches:q" | grep -oP "(?<=$arg)[^ \t]*"`
	# Sed command to find common prefix of multiple lines
	# recipe taken from: https://stackoverflow.com/questions/65245764/portable-sed-way-to-find-longest-common-prefix-of-strings/65245765#65245765
	set common_prefix = `printf "%s\n" $appendages | sed -e '1h;G;s/^\(.*\).*\n\1.*/\1/;h;$\\!d'`
	# If there is a common prefix to append, output it; otherwise display all possible results
	if ( "$common_prefix" != "" ) then
		echo "$appendages:q"
	else
		# There are multiple results, so display them.
		# - The following workaround prepends #matches primarily as a
		#   dummy output to ensure that tcsh thinks there is no common prefix
		#   among the matches -- so that tcsh doesn't try to append
		#   the START of a match to the user's EXISTING partial match
		#   when we actually want it to display all matches:
		#   e.g. '-t gtm931<tab>' would otherwise APPEND all of 'v63013/gtm931'
		#   because it is a common prefix of the two tests containting gtm931.
		# - Prepend '0' to return this dummy result first for nicer display, since tcsh sorts results digits-first.
		#   If someone creates a test starting with '00' (unlikely) then it will, unfortunately, display first.
		echo "0${#matches}-MATCHES: $matches:q"
	endif
else
	echo "$matches:q"
endif
