#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Part A of supplementary instances test - original suppl_inst test split into multiple tests for quicker run times of each test
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# recreate_instance		[parentel] <Test that an instance file create by a previous GT.M version need to be recreate before it can be used.>
# supp_ordering			[parentel] <Check ordering of updates in supplementary instance group.>
# supplementary			[parentel] <Test basic supplementary replication.>
# instinfoprop			[parentel] <Validate instance information propagation with backlog.>
# rest_back_inst		[parentel] <Test restart from a backup which includes an instance file.>
# same_start_seqno		[parentel,kishore] <Test that MULTIPLE history records with the SAME start_seqno but different stream_seqno are handled properly.>
# nogroupmix			[parentel] <Test that two non-supplementary group can not talk to each other.>
# epochcheck			[kishoreh] Test that 16 strm_seqnos are dumped in EPOCH record as part of detailed journal extract
# instance_recreate		[bahirs] <Test basic recreation of instance file on Q, Q will get the knowledge about A through P>

echo "Part A of supplementary instances test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_replic	"epochcheck instance_recreate instinfoprop recreate_instance rest_back_inst same_start_seqno supplementary "

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
# rest_back_inst copies mumps.repl across instances and starts source server. Since copying .repl file across endian, 32/64bit machines won't work.
if ("MULTISITE" == "$test_replic") then
	setenv subtest_exclude_list "$subtest_exclude_list rest_back_inst "
endif

# Randomization of replication type is disable since it is all handled by the subtests.
setenv test_replic_suppl_type 0

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "Part A of supplementary instances test DONE."
