#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# -------------------------------------------------------------------------------------
# for stuff fixed in V53004 (i.e. after V53003 and before V54000)
# -------------------------------------------------------------------------------------
# C9E10002648  [Narayanan] $O(^GBL(""),-1) gives incorrect result if ^GBL($C(255))) is defined
# D9J01002781  [SteveE]    $ZSYSTEM should give true return code rather than waitpid status word structure
# C9J03003102  [Narayanan] Pattern matching with umlaut in M-mode gives an unnecessary 'PATLIT' error
# C9905001119  [Narayanan] GT.M should handle first-time global reference (with nonzero out-of-date clue) when in final TP retry
# D9H01002639  [SteveJ]    Compiling a file that exists, but can't be opened gives "attempt to use before open" error
# C9J04003115  [Narayanan] Compiling EBCDIC M program in ASCII land causes SIG-11 & stack smash errors
# C9G09002804  [Hemani]    Below three subtests are part of C9G09-002804 Update process needs GVSUBOFLOW and REC2BIG checks
#				updkillsuboflow updsetrec2big updsetsuboflow
# C9I09003042  [Narayanan] Test repositioning logic happens only ONCE in gds_tp_hist_moved (see TR folder for details)
# D9J05002724  [Narayanan] Test that left side of the set is evaluated BEFORE the right side
# C9905001119A [Narayanan] Test that TP with WRITE-ONLY references to NOISOLATION globals causes negligible TP restarts
# C9J06003134  [Narayanan] GDE should print error if not able to source the .gde file (e.g. permissions)
# D9J06002725  [Narayanan] $NAME() should always place a value in the extended reference field
# C9J03003097  [SteveJ]    Test that failing opens don't forget to close the file descriptor
# C9J04003109  [Roger]     Provide gtm_prompt environment variable to initialize $ZPROMPT
# D9902001105  [Bill]      Close the disabling Control-C hole on Unix
# C9J06003139  [Narayanan] Journal file sizes on secondary should be the same as primary
# C9C12002191 [kishoreh]   Testing security related TRs [C9I10-003048 and C9C12-002191]
# D9G06002616 [s7kr] 	   Testing FOR statement with >= 127 expression
# -------------------------------------------------------------------------------------
#
echo "V53004 test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "updkillsuboflow updsetrec2big updsetsuboflow C9J06003139"
#
setenv subtest_list_non_replic "C9E10002648 D9J01002781 C9J03003102 C9905001119 D9H01002639 C9J04003115 C9I09003042 D9J05002724"
setenv subtest_list_non_replic "$subtest_list_non_replic C9905001119A C9J06003134 D9J06002725 C9J03003097 C9J04003109 C9C12002191 D9G06002616"

if (("OSF1" != $HOSTOS) && ("OS/390" !=  $HOSTOS)) then
	# The following subtest uses "expect" which is absent in Tru64 and z/OS therefore do not include the subtest.
	setenv subtest_list_non_replic "$subtest_list_non_replic D9902001105"
endif

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Filter out tests requiring specific gg-user setup, if the setup is not available
if ($?gtm_test_noggusers) then
	setenv subtest_exclude_list "$subtest_exclude_list C9C12002191"
endif
# If the platform/host does not have GG structured build directory, disable tests that require them
if ($?gtm_test_noggbuilddir) then
	setenv subtest_exclude_list "$subtest_exclude_list C9905001119A"
endif

$gtm_tst/com/submit_subtest.csh
echo "V53004 test DONE."
