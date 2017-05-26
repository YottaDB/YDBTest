#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# Test that, after we change $ZROUTINES, subsequent routine invocations/references access the latest available code -- which means
# whatever code is accessible by the current value of $ZROUTINES. Basically, we expect a process that performs SET $ZROUTINES
# to induce itself to automatically relink.
#
# Test for full array of invocation types, e.g. DO, GOTO, $TEXT, etc.
#

#####
# Copy all files associated with this subtest into working directory, and strip the "subtestname-" prefix.
source $gtm_tst/$tst/u_inref/unpack_subtest_files.csh "setzroutines" `pwd`
#####

# Take a copy of the template, so we can repeatedly fill in base.m
cp base.m base.m.template

echo "# Fill ./patch, so after we set ZROUTINES=./patch, we access the version 2 routine"
mkdir -p ./patch
$gtm_exe/mumps -run %XCMD 'ZCompile "bar.edit"'
cp bar.edit bar2.edit
$gtm_exe/mumps -run %XCMD 'ZCompile "bar2.edit"'	# note: $text(^bar2) will look in current directory, whose path is saved in the .o file
mv bar.o bar2.o ./patch

setenv gtmroutines '.* '"$gtmroutines"

echo "# Drive test"
$gtm_exe/mumps -run setzroutines
