#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#                                                               #
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
# sn_jnl1	[sopini]	Verify that the new limits are enforced on various database and journaling configurations.
# sn_jnl2	[sopini]	Verify that autoswitch occurs as expected when non-spanning globals are used.
# sn_jnl3	[sopini]	Verify that both spanning and non-spanning globals can be all journaled and properly restored from journal files.
# sn_jnl4	[sopini]	Verify that autoswitch occurs when expected when either spanning or non-spanning globals are used.
# sn_jnl5	[sopini]	Verify that the new logic that takes care of journal buffer size validation and auto-adjustment works as intended.
# sn_repl1	[sopini]	Verify that spanning and non-spanning instances receive updates correctly through replication channels.
# sn_repl2	[sopini]	Verify that replication instances communicate properly so long as the key sizes of updates do not exceed the limits.
# sn_repl3	[sopini]	Verify that replication instances communicate properly so long as the record sizes of updates do not exceed the limits.
# sn_repl4	[sopini]	Verify that replication works for a randomized configuration of two instances.
# sn_repl5	[sopini]	Verify no post-V60000 regression when handling on the receiving end of a replication pipe such conditions that currently qualify as REC2BIG, KEY2BIG, and GVSUBOFLOW errors.
# basic		[base]		Tests basic features of spanning nodes (involves some GDE testing).
# trigger	[base]		Triggers with spanning nodes.
# dse		[base]		Verify that DSE displays #SPAN tags properly.
# threeen	[base]		A stress test for DSE.
# gtm6941	[zouc]		Allow maximum record size to be 1,048,576 and key size larger than 255.
# loadextract	[base]		Verify MUPIP load/extract works properly with spanning nodes.
# dsezwr	[bahirs]	Verify that spanning node is represented as multiple set $extract() commands.
# spaninteg	[bahirs]	Verify that spanning node INTEG checks are properly issued in case of damaged spanning node.
# sn_key_flags	[bahirs]	Verify that 'Spanning Node Absent' and 'Maximum Key Size Assured' flags are correctly set during mumps operation and
#				MUPIP INTEG reset it appropriately.
# setexklo	[base]		Does various sets, extracts, and kills, verifies loaded values match MUPIP EXTRACT output.
# binloaderrors	[maimoneb]	Verify that binary load properly handles errors in the extract
#
#-------------------------------------------------------------------------------------

echo "spanning_nodes test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "sn_jnl1 sn_jnl2 sn_jnl3 sn_jnl4 sn_jnl5 basic trigger dse threeen gtm6941 loadextract"
setenv subtest_list_non_replic "$subtest_list_non_replic dsezwr spaninteg sn_key_flags setexklo binloaderrors"
setenv subtest_list_replic     "sn_repl1 sn_repl2 sn_repl3 sn_repl4 sn_repl5"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	if ("dbg" == "$tst_image") then
		# We do not have dbg builds of versions [V53000,V55000] needed by the below subtest so disable it.
		setenv subtest_exclude_list "$subtest_exclude_list sn_jnl5"
	endif
endif

if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "trigger"
endif

# Disable gtmcompile, including the -dynamic_literals qualifer, since prior versions complain. See comment in switch_gtm_version.csh
unsetenv gtmcompile

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "spanning_nodes test DONE."
