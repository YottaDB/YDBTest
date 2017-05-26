#!/usr/local/bin/tcsh -f
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# recreate_instance		[parentel] <Test that an instance file create by a previous GT.M version need to be recreate before it can be used.> 
# supp_ordering			[parentel] <Check ordering of updates in supplementary instance group.>
# supplementary			[parentel] <Test basic supplementary replication.>
# updateresync			[parentel,kishore] <Test -updateresync qualifier usage error.>
# overwrite_stream_info		[parentel,kishore] <Test overwriting of stream info by updateresync.>
# reuse				[parentel] <Test the -REUSE qualifier.>
# dup_hist_rec			[parentel] <Test that history records are written twice if the same instance file is used more than once with updateresync.>
# wronginsync			[parentel,kishore] <Test that LMS logic incorrectly considers two instances in sync when they are not.>
# instinfoprop			[parentel] <Validate instance information propagation with backlog.>
# rest_back_inst		[parentel] <Test restart from a backup which includes an instance file.>
# failovers_with_supp		[parentel] Test that non-supplementary failovers do not affect supplementary instance as long as rollback is not needed. 
# noresync			[parentel,kishore] <Test the new -noresync qualifier.>
# same_start_seqno		[parentel,kishore] <Test that MULTIPLE history records with the SAME start_seqno but different stream_seqno are handled properly.>
# supplementary_err		[parentel,kishore] <Test invalid supplementary scenarios.>
# nogroupmix			[parentel] <Test that two non-supplementary group can not talk to each other.>
# epochcheck			[kishoreh] Test that 16 strm_seqnos are dumped in EPOCH record as part of detailed journal extract
# multiple_streams		[kishoreh] Test if mixing of multiple streams in the same receive pool is prevented
# updateresync_pp		[kishoreh] Test of -updateresync on a supplementary propagating primary instance.
# fetchresync_nosupplsupplgroup	[bahirs] <Test fetchresync rollback between nonsupplementary and supplementary group>
# fetchresync_supplgroup	[bahirs] <Test fetchresync rollback supplementary group member>
# instance_recreate		[bahirs] <Test basic recreation of instance file on Q, Q will get the knowledge about A through P>
# multiple_switchover		[bahirs] <Test the multiple switchover between supplementary and non-supplementary instances.>
# noresync_1			[bahirs] <Test noresync qualifier for receiver start-up.>
# noresync_2			[bahirs] <Test noresync qualifier for receiver start-up.>
# resync_seqno			[bahirs] <Test correctness of rollback with strm_seqno and strm_no.>
# supplgrouprepl		[bahirs] <Test robustness of P->Q replication in case of multiple switch-ver between A and B>
# upgrade_inst1			[bahirs] <Test the upgrade of P(non-supplementary instace) from B(supplementary instance)
# upgrade_inst			[bahirs] <Test the upgrade of P(non-supplementary instace) from B(supplementary instance)>

echo "supplementary_instances test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_replic	"recreate_instance supplementary updateresync wronginsync overwrite_stream_info reuse dup_hist_rec instinfoprop "
setenv subtest_list_replic	"$subtest_list_replic rest_back_inst failovers_with_supp noresync same_start_seqno supplementary_err epochcheck multiple_streams updateresync_pp "
setenv subtest_list_replic	"$subtest_list_replic fetchresync_nosupplsupplgroup fetchresync_supplgroup instance_recreate multiple_switchover noresync_1 noresync_2 resync_seqno supplgrouprepl upgrade_inst1 upgrade_inst "

if ($?test_replic == 1) then
	# Setting Encryption Related environment for remote hosts
	$gtm_tst/com/multihost_encrypt_settings.csh >&multihost_encrypt_settings.out

	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Randomization of replication type is disable since it is all handled by the subtests.
setenv test_replic_suppl_type 0

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "supplementary_instances test DONE."
