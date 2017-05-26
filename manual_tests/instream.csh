#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ------------------------------------------------------------------------------------------------------------
# The following is a list of the manual tests that need to be RUN MANUALLY and OUTPUT VERIFIED MANUALLY.
# Please see the inref directory  for instructions on how to run each test and verify results.
# ------------------------------------------------------------------------------------------------------------
# C9H10002916		[smw]	  Lost socket when it is $PRINCIPAL
# C9K05003274		[smw]	  ctrl-c and non terminal $principal blocks events
# ------------------------------------------------------------------------------------------------------------

set manual_subtest_list = "ctrlc terminal C9H10002916 C9K05003274"
echo "The following is a list of the manual tests."
echo "Please see the <testname>.txt in the inref directory for instructions"
echo "on how to run and verify results."
echo "Manual tests:"
echo "$manual_subtest_list"
echo " "
echo "inref/ScriptsforsimulatingCrash.txt explains how to perform a simulated crash as called for by some tests."

# echo "run $gtm_tst/manual_tests.csh manually."
#
# ------------------------------------------------------------------------------------------------------------
# Temporarily disabled tests
# ------------------------------------------------------------------------------------------------------------
# tty.m                 [dincern] - re-enable this test once the TR C9C05-002001 is fixed.
# intrpt_recov_A        [nars]    - enable when C9D08-002382 is fixed. Also test for 1 release and disable afterwards.
# intrpt_recov_B        [nars]    - tests interrupted recovery. ideminter_rolrec does a good job. So this is not needed.
# C9C07002088.txt       [nars]    - tests interrupted recovery. ideminter_rolrec does a good job. So this is not needed.
# recov_standalone      [nars]    - This test is not considered worthy enough for periodic manual testing. Better to automate this.
# C9D07002353           [zhouc]   - This test is not worthy enough to test manually periodically.
# C9E10002641           [vinu]    - Journal pool fields must be updated by secshr_db_clnup for errors during commit
#                                 - [nars] This has been tested for at least 2 releases. Manual testing no longer considered worthy.
# D9E06002468           [vinu]    - Source server JNLFILOPN and GTMASSERT error at ING UK
#                                 - [nars] This has been tested for at least 1 release. Manual testing no longer considered worthy.
# D9E09002493           [vinu]    - File descriptor leak while reading from journal files in source server
#                                 - [nars] This has been tested for at least 1 release. Manual testing no longer considered worthy.
# C9E12002693.txt       [malli]   - Possible sig-11 if ACT/NCT and first local subscript to be processed is ""
#                                 - [nars] This has been tested for at least 1 release. Manual testing no longer considered worthy.
# D9C05002119.txt       [smw]     - D9C05-002119 TCP device not recognised from inetd
#                                 - [nars] This has been tested for at least 1 release. Manual testing no longer considered worthy.
# ------------------------------------------------------------------------------------------------------------
# Tests that have been automated
# ------------------------------------------------------------------------------------------------------------
# rx0.txt               [xli]     Test of read x:0
# D9F05002548           [kishore] M Read Editing for UNIX.
# ctrlc.txt             [nars]    Test of ctrl-c
# terminal.m            [dincern] Test of Terminal
