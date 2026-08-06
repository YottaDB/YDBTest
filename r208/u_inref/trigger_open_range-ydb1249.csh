#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo "# [#1249] A trigger subscript specification with an open ended range is read back from ^#t correctly #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# A trigger subscript specification with an open ended range, for example [+^x(sub1=2:)], has an empty"
echo "# specification for the open side. Reading the definition back from ^#t used to examine the first byte of"
echo "# that empty specification, which is one byte past its end, and act on it when it happened to be a double"
echo "# quote, which it is when a quoted field such as the trigger's -xecute text follows. The length then"
echo "# underflowed and a valid definition was rejected with"
echo "#	%YDB-E-TRIGSUBSCRANGE, Trigger definition for global ^x has one or more invalid subscript range(s)"
echo "# or, on a dbg build, failed an assert in gvtr_process_range()."
echo
echo "# Create a database. AIM cross reference globals need null subscripts and have long keys."
$gtm_tst/com/dbcreate.csh mumps 1 -key_size=1019 -record_size=4080 -block_size=4096 -null_subscripts=TRUE

echo "# Run [ydb1249] : define a trigger for each shape of an open ended range and fire it across a span of"
echo "# subscripts, then cycle definitions to exercise the read path repeatedly. These definitions place no"
echo "# quoted field after the open side, so they exercise the parse without depending on the byte that follows"
echo "# it, and they pass on a build without the fix."
$ydb_dist/yottadb -run ydb1249

echo
echo "# Build AIM, which does produce a definition that reproduces the failure"
echo "#"
echo "# AIM writes its own triggers, and the KILL trigger it writes for a cross reference whose subscript"
echo "# specification is an open ended range is followed by its -xecute text, which is what supplies the double"
echo "# quote. The plugin is cloned and built here, against the YottaDB under test, rather than installed with"
echo "# ydbinstall: ydbinstall installs the distribution its own copy is bundled with, which is not the build"
echo "# under test in every pipeline, and the subtest would then report on an unrelated YottaDB."
git clone -q https://gitlab.com/YottaDB/Util/YDBAIM.git
mkdir YDBAIM/build
cd YDBAIM/build
cmake .. >& cmake.out
set aimstatus = $status
if (0 == $aimstatus) then
	make >& make.out
	set aimstatus = $status
endif
cd ../..
if (0 != $aimstatus) then
	echo "# TEST-E-FAIL : could not build YDBAIM; cmake.out and make.out follow"
	cat YDBAIM/build/cmake.out YDBAIM/build/make.out
	exit 1
endif

# The build produces one shared library per chset. gtm_chset is not set at all
# in an M mode run, so read it with printenv: tcsh substitutes the whole line
# before it evaluates a condition, and a reference to an unset variable guarded
# by $?gtm_chset on one line still stops the subtest.
set aimchset = `printenv gtm_chset`
if ("UTF-8" == "$aimchset") then
	set aimso = $cwd/YDBAIM/build/utf8/_ydbaim.so
else
	# The M shared library is at the top of the build directory, and the UTF-8
	# one in a subdirectory of it.
	set aimso = $cwd/YDBAIM/build/_ydbaim.so
endif
if (! -e $aimso) then
	echo "# TEST-E-FAIL : $aimso was not built; the build has these instead"
	sh -c 'find YDBAIM/build -name "_ydbaim.so"'
	exit 1
endif
setenv gtmroutines "$aimso $gtmroutines"

echo
echo "# Run [ydb1249aim] : cross reference ^x with the open ended subscript range [2:] and KILL it, 200 times."
echo "# The KILL is what reads the trigger definition back. A build without the fix reports, at an iteration"
echo "# that differs from run to run and on roughly one iteration in thirty"
echo "#	# error at iteration 6 : %YDB-E-TRIGSUBSCRANGE, Trigger definition for global ^x has one or more invalid subscript range(s) : sub1=2:"
echo "# so 200 iterations leave ample margin against a run that passes by chance. AIM halts the process on an"
echo "# error rather than reporting it, hence the exit status below as well."
$ydb_dist/yottadb -run ydb1249aim >& aimrun.out
set runstatus = $status
cat aimrun.out
echo "# ydb1249aim exit status : $runstatus"

# %YDBAIM-F-JOBERR names a file written by an AIM JOB'd process, and AIM leaves
# that file behind when it reports the error. Show it, since a JOB'd process
# that fails only on a loaded or resource limited system cannot be diagnosed
# from the error alone. The glob goes through sh because tcsh stops on one that
# matches nothing.
grep -q "completed 200 iterations" aimrun.out
if (0 != $status) then
	sh -c 'for f in /tmp/xref*YDBAIM*.err; do if [ -s "$f" ]; then echo "# JOB errors from $f"; head -20 "$f"; fi; done'
endif

echo
echo "# Invoking : dbcheck.csh"
$gtm_tst/com/dbcheck.csh
