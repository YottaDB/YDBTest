#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# gtm8914  [jake]  Tests that $VIEW("GVSTATS",<region>) ZSHOW "G" and ZSHOW "T" append output with "?" for processes w/o access to the current shared statistics
# gtm8909  [jake]  Tests that <ctrl-c> within the help facility no longer leads to EN0256 error upon exit
# gtm8874  [jake]  Tests the VIEW command's [:<region list>] qualifier
# gtm8860  [jake]  Tests that journal extract removes additional / from journal and output file paths
# gtm8791  [jake]  Tests that <ctrl-z> no longer causes segmentation violation
# gtm8699  [jake]  Tests that $VIEW("STATSHARE",<region>) returns 1 if the process is sharing DB stats and 0 otherwise
# gtm8202  [jake]  Tests the functionality of the -SEQNO qualifier for the mupip journal -extract command
# gtm1042  [jake]  Tests the that env variable gtm_mstack_size sets the size of the M stack as expected
# gtm8891  [vinay] Tests that <side-effect-expression><pure-Boolean-operator>$SELECT(0:side-effect-expression)) sequence produces a SELECTFALSE runtime error
# gtm8894  [vinay] Tests that $zreldate outputs in the form YYYYMMDD 24:60
# gtm8643  [jake]  Tests that YDB no longer enforces queue depth limit of 5 for SOCKET devices.
# gtm8922  [jake]  Tests the functionality of VIEW keywords that take <region-list> expressions
# gtm8923  [jake]  Tests the READ * and WRITE * commands no longer produce errors or incorrect output for files or sockets with CHSET={UTF-16,UTF-16BE,UTF-16LE}
# gtm8903  [jake]  Tests $SELECT(1:,:) function call for errors when global references are present
# gtm3146  [jake]  Tests that changes to alias and path settings no longer disrupt system() calls within MUPIP BACKUP command calls
# gtm8777  [jake]  Test that QUIET and QCALL calls to %GCE, %GSE, %RCE, and %RSE only output results for globals/routines that contain a match
# gtm7483  [jake]  Test that MUPIP INTEG issues a DBKEYMX error in case of a long key name stored in the Directory Tree
# gtm8900  [jake]  Test the functionality of MUPIP SET -[NO]ENCRYPTABLE when GNUPGHOME and/or gtm_passwd are properly defined or not
# gtm5730  [jake]  Tests that the update process now logs record types with a corresponding, non-numerical, description
# gtm8906  [nars]  Test that MUPIP JOURNAL RECOVER/ROLLBACK handle large amounts of journal data (more than 55 million updates)
# gtm8916  [jake]  Tests that the reciever process always restarts properly after the update process is killed. Previously the reciever process would often hang.
# gtm8926  [quinn] Test that an external call from MUMPS will defer processing a flush timer until after the external process concludes.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63004 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8914 gtm8909 gtm8874 gtm8860 gtm8791 gtm8699 gtm8202 gtm1042 gtm8891 "
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8894 gtm8643 gtm8922 gtm8923 gtm8903 gtm3146 gtm8777 gtm7483 gtm8900"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8926"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic gtm5730 gtm8906 gtm8916"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
if ("dbg" == "$tst_image") then
	# gtm8906 subtest runs very slow with debug builds so run it only with pro.
	setenv subtest_exclude_list "$subtest_exclude_list gtm8906"
endif

if (("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) || ("HOST_LINUX_AARCH64" == $gtm_test_os_machtype)) then
	# gtm8906 subtest could take 1 hour or more on the slower (relative to x86_64) ARM boxes even with pro so disable it there.
	setenv subtest_exclude_list "$subtest_exclude_list gtm8906"
endif

if ($gtm_test_glibc_225_plus) then
	# Systems with glibc version > 2.25 cause the v63004/gtm8916 subtest to hang in the receiver server
	# in "pthread_cond_signal". The current suspicion is that it is a glibc issue with handling kill -9
	# of processes using pthread_mutex_*() and pthread_cond_*() calls. Temporarily disable this test in those boxes.
	setenv subtest_exclude_list "$subtest_exclude_list gtm8916"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63004 test DONE."
