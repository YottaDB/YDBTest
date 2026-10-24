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

echo "#-------------------------------------------------------------#"
echo "# [YDB#1314] A SIGSEGV is reported when the stack cannot grow #"
echo "#-------------------------------------------------------------#"
echo
echo "# YottaDB installs its signal handlers with SA_ONSTACK, but used to install an alternate signal stack"
echo "# only when the process already had one that was smaller than 256 KB, such as the 32 KB one that the"
echo "# Go runtime sets up. In a process with no alternate signal stack, a SIGSEGV because the stack cannot"
echo "# grow then had no stack for the YottaDB handler to run on, so the kernel killed the process with the"
echo "# default action of SIGSEGV, and the process reported nothing. YottaDB now installs its own alternate"
echo "# signal stack when there is none."
echo "#"
echo "# ydb1314_nogrow.c restores the default action of SIGSEGV and disables any alternate signal stack, which"
echo "# an ASAN build installs, initializes YottaDB with ydb_set_s(), limits its stack to 8 MiB, then recurses"
echo "# until the stack cannot grow."
echo

echo "# Stage 1 : build ydb1314_nogrow.c"
echo "# Before the fix, this stage passed, with the output below"
set file = ydb1314_nogrow
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_dist $gtm_tst/$tst/inref/$file.c >& ${file}_cc.out
set ccstat = $status
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
if ((0 == $ccstat) && (0 == $status) && (-x $file)) then
	echo "PASS : $file was built"
else
	echo "WRONG : $file was not built - see ${file}_cc.out and $file.map"
	cat ${file}_cc.out $file.map
endif
echo

echo "# Stage 2 : run ydb1314_nogrow"
echo "#           expect the YottaDB SIGSEGV handler to run and report KILLBYSIGSINFO1 and SIGMAPERR, instead"
echo "#           of the kernel killing the process with the default action of SIGSEGV (exit status 139)"
echo '# Command : ./ydb1314_nogrow'
echo "# Before the fix, the process was killed by the default action of SIGSEGV with no message, so the two"
echo "# lines below were WRONG lines, one for its exit status, followed by its output, and one for the"
echo "# missing messages"
# Run it in a subshell that also saves its exit status. With a second command, the subshell does not just exec
# the program, so the "Segmentation fault" message of the shell that sees it killed by the signal goes to
# ${file}_shell.logx and not to the reference file.
(./$file >& $file.out ; echo $status >&! $file.status) >& ${file}_shell.logx
set rc = `cat $file.status`
if (139 == $rc) then
	echo "WRONG : the process was killed by the default action of SIGSEGV (exit status 139). Its output follows."
	cat $file.out
else if (0 == $rc) then
	echo "WRONG : the process exited with status 0. Its output follows."
	cat $file.out
else
	echo "PASS : the process was not killed by the default action of SIGSEGV"
endif
$grep -q '^FAIL' $file.out
if (0 == $status) then
	echo "WRONG : the program reported a failure. Its output follows."
	cat $file.out
endif
# The messages hold the pid and addresses, so keep the check's output out of the reference file
$gtm_tst/com/check_error_exist.csh $file.out KILLBYSIGSINFO1 SIGMAPERR >& check_error_exist.logx
if ($status) then
	echo "WRONG : no %YDB-F-KILLBYSIGSINFO1 and %YDB-F-SIGMAPERR messages from the process - see check_error_exist.logx"
else
	echo "PASS : the process reported %YDB-F-KILLBYSIGSINFO1 and %YDB-F-SIGMAPERR"
endif
echo

echo "# Stage 3 : keep any core and YDB_FATAL_ERROR file from the process out of the check for unexpected ones"
ls -1 core* >& /dev/null
if (0 == $status) then
	foreach corename (core*)
		mv $corename hidden_expected_$corename
	end
endif
ls -1 YDB_FATAL_ERROR* >& /dev/null
if (0 == $status) then
	foreach fatalname (YDB_FATAL_ERROR*)
		mv $fatalname hidden_expected_$fatalname
	end
endif
echo
echo "# Done"
