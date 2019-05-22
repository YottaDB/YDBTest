#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
######################################################################
# sudo_start.csh                                                     #
# all subtests in this test are automated, but won't run as part of  #
# the daily/weekly cycle. The tests here will be started manually in #
# a controlled fashion, e.g. during the regression testing phase for #
# a major release. All of these tests require 'sudo' to run.         #
######################################################################
#
# sourceInstall		[mmr]		Test that ydbinstall.sh when sourced will give an error then exit
# diffDir		[mmr]		Test that ydbinstall.sh when called from anothre directory will still install properly
#
setenv subtest_list_common "sourceInstall diffDir "
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic"
setenv subtest_list_replic ""

setenv subtest_list "$subtest_list_common $subtest_list_non_replic $subtest_list_replic"

# EXCLUSIONS
setenv subtest_exclude_list ""

$gtm_tst/com/submit_subtest.csh
echo "sudo tests DONE."
