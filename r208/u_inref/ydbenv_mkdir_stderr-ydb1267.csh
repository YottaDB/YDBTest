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

echo "#--------------------------------------------------------------------------------------------------#"
echo '# [YDB#1267] %YDBENV reports the stderr of a failed "mkdir -p" in the CREATEFAIL error              #'
echo "#--------------------------------------------------------------------------------------------------#"
echo

# The "mkdir" label of %YDBENV opens its "mkdir -p" PIPE device with a stderr device and used to
# never READ that device, so a genuine failure produced only
#
#	%YDBENV-F-CREATEFAIL unable to create directory <dir> with error code 1
#
# and discarded the reason the OS gave. Each failing stage below therefore asserts that CREATEFAIL
# names that reason. On a build without the fix for YottaDB/DB/YDB#1267, those two assertions report
# WRONG while every other assertion here still passes, since the error itself is unchanged.
#
# ydb_env_set has to be SOURCED from a POSIX shell, so every stage runs it through the sh script
# ydbenv_mkdir_stderr-ydb1267.sh. That script's output holds absolute path names and the quoting
# style "mkdir" picked from the host locale, neither of which belongs in a reference file, so the
# stages assert against the output and name the file instead of displaying it.

set setsh = "$gtm_tst/$tst/u_inref/ydbenv_mkdir_stderr-ydb1267.sh"

echo '# Stage 1 : "mkdir -p" of $ydb_tmp fails with EACCES'
echo '# Command : mkdir noperm; chmod 555 noperm; sh ydbenv_mkdir_stderr-ydb1267.sh $cwd/noperm/tmp'
mkdir noperm
chmod 555 noperm
sh $setsh $cwd/noperm/tmp >&! stage1.out
set act = `$tst_awk '/^Exit status = /{print $4}' stage1.out`
if ("$act" == "237") then
	echo "PASS : exit status 237, which is the U237 CREATEFAIL error"
else
	echo "WRONG : expected exit status 237, got [$act] - see stage1.out"
endif
if (0 != `$grep -c -E 'YDBENV-F-CREATEFAIL.*Permission denied' stage1.out`) then
	echo "PASS : CREATEFAIL names [Permission denied]"
else
	echo "WRONG : CREATEFAIL does not name [Permission denied]. Without the fix it ends"
	echo "WRONG : at [with error code 1], as in the message below. The full output is in"
	echo "WRONG : stage1.outx if stage 5 below passed, and in stage1.out if it did not."
	$grep -E 'YDBENV-F-CREATEFAIL' stage1.out
endif
# Restore write permission so the framework can clean the subtest directory up afterwards.
chmod 755 noperm
echo

echo '# Stage 2 : "mkdir -p" of $ydb_tmp fails with ENOTDIR'
echo '# Command : touch notadir; sh ydbenv_mkdir_stderr-ydb1267.sh $cwd/notadir/tmp'
touch notadir
sh $setsh $cwd/notadir/tmp >&! stage2.out
set act = `$tst_awk '/^Exit status = /{print $4}' stage2.out`
if ("$act" == "237") then
	echo "PASS : exit status 237, which is the U237 CREATEFAIL error"
else
	echo "WRONG : expected exit status 237, got [$act] - see stage2.out"
endif
if (0 != `$grep -c -E 'YDBENV-F-CREATEFAIL.*Not a directory' stage2.out`) then
	echo "PASS : CREATEFAIL names [Not a directory]"
else
	echo "WRONG : CREATEFAIL does not name [Not a directory]. Without the fix it ends"
	echo "WRONG : at [with error code 1], as in the message below. The full output is in"
	echo "WRONG : stage2.outx if stage 5 below passed, and in stage2.out if it did not."
	$grep -E 'YDBENV-F-CREATEFAIL' stage2.out
endif
echo

echo '# Stage 3 : "mkdir -p" of $ydb_tmp succeeds, so ydb_env_set must still build an environment'
echo '# Command : mkdir stage3home; sh ydbenv_mkdir_stderr-ydb1267.sh $cwd/goodtmp $cwd/stage3home'
mkdir stage3home
sh $setsh $cwd/goodtmp $cwd/stage3home >&! stage3.out
set act = `$tst_awk '/^Exit status = /{print $4}' stage3.out`
if ("$act" == "0") then
	echo "PASS : exit status 0"
else
	echo "WRONG : expected exit status 0, got [$act] - see stage3.out"
endif
set act = `$grep -c -E '%YDB(ENV)?-[EF]-' stage3.out`
if ("$act" == "0") then
	echo "PASS : no error message was reported"
else
	echo "WRONG : expected 0 error messages, got $act - see stage3.out"
endif
if (-d goodtmp) then
	echo 'PASS : $ydb_tmp was created'
else
	echo 'WRONG : $ydb_tmp was not created - see stage3.out'
endif
# The $ydb_tmp caller of the "mkdir" label is the only one that passes a umask, so this is where a
# lost "umask 0;" prefix on the "mkdir -p" command would show. The exact mode is not fixed: it is
# drwxrwxrwx or drwxrwx--- depending on whether the installation restricts execution to a group. The
# group write bit is set either way, and is what a default umask of 022 would have cleared.
set act = `ls -ld goodtmp |& $tst_awk '{print substr($1,6,1)}'`
if ("$act" == "w") then
	echo 'PASS : $ydb_tmp is group writable, so the "umask 0" prefix survived'
else
	echo 'WRONG : expected the group write bit set on $ydb_tmp, got ['"$act"'] - see [ls -ld goodtmp]'
endif
echo

echo "# Stage 4 : no stage reported DEVICEWRITEONLY"
echo '# Command : grep -c DEVICEWRITEONLY stage1.out stage2.out stage3.out'
set act = `cat stage1.out stage2.out stage3.out | $grep -c DEVICEWRITEONLY`
if ("$act" == "0") then
	echo "PASS : no DEVICEWRITEONLY error"
else
	echo "WRONG : got $act DEVICEWRITEONLY errors - the PIPE device that carries the mkdir stderr"
	echo "WRONG : cannot be READ while its OPEN also specifies the writeonly deviceparameter"
endif

echo

echo "# Stage 5 : declare the errors stages 1 and 2 provoked, so the framework error scan expects them"
echo '# Command : $gtm_tst/com/check_error_exist.csh stage<N>.out CREATEFAIL SETECODE'
# Without this, com/errors.csh finds the CREATEFAIL that stages 1 and 2 asked for, plus the SETECODE
# in the $ZSTATUS line the %YDBENV error trap writes beside it, and fails the subtest on errors it
# was written to produce. The output of check_error_exist.csh quotes the lines it matched, and those
# carry the absolute path of the directory that could not be created, so it goes to a file rather
# than to the reference file. That file has to be named .logx and not .log: errors.csh scans *.out
# and *.log while skipping *.*x, and the quoted lines hold the very error text being declared here.
foreach stage (stage1 stage2)
	$gtm_tst/com/check_error_exist.csh $stage.out CREATEFAIL SETECODE >&! $stage-check_error.logx
	set act = $status
	if ("$act" == "0") then
		echo "PASS : CREATEFAIL and SETECODE in $stage.out are now declared expected"
	else
		echo "WRONG : check_error_exist.csh returned $act for $stage.out - see $stage-check_error.logx"
	endif
end

echo
echo "# Done"
