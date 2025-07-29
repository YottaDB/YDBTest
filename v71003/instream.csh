#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------
# noconsumer_passivesrc-gtmf228991	[nars]	Test no journal pool writes happen if the only source server is passive
# noconsumer_jnlfileonly-gtmf228991	[nars]	Test no journal pool writes happen if the only source server is -JNLFILEONLY
# jnlwritereserve_order-gtmf228991	[nars]	Test t_end() calls jnl_write_reserve() before it takes the instance lock
# srcrecserver_redirdevnull-gtmde201175		[jon]	Test source and receivers servers start with input redirected to /dev/null
# dollarstorage-gtmde540134	[jon]	Test $STORAGE attempts to be more useful
# statsdb_exclinstfrz-gtmde551455	[jon]	Test statsdb excluded from Instance Freeze
# ztimeoutdefer_zinterrupt-gtmde376113		[jon]	Test $ZTIMEOUT deferred during $ZINTERRUPT
# pattalterr_memleak-gtmde559768	[jon]	Test YottaDB frees memory associated with a pattern alternation when encountering an error in compiling it
# tlsreneg_msg-gtmde567908		[jon]		Test the GT.M TLS plugin library exposes an external call interface providing cipher suite and version information
#----------------------------------------------------------------------------------------------------------------------------------

echo "v71003 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic noconsumer_passivesrc-gtmf228991"
setenv subtest_list_non_replic	"$subtest_list_non_replic srcrecserver_redirdevnull-gtmde201175"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollarstorage-gtmde540134"
setenv subtest_list_non_replic	"$subtest_list_non_replic ztimeoutdefer_zinterrupt-gtmde376113"
setenv subtest_list_non_replic	"$subtest_list_non_replic pattalterr_memleak-gtmde559768"
setenv subtest_list_replic	""
setenv subtest_list_replic	"$subtest_list_replic noconsumer_jnlfileonly-gtmf228991"
setenv subtest_list_replic	"$subtest_list_replic jnlwritereserve_order-gtmf228991"
setenv subtest_list_replic	"$subtest_list_replic statsdb_exclinstfrz-gtmde551455"
setenv subtest_list_replic	"$subtest_list_replic tlsreneg_msg-gtmde567908"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

if ("TRUE" != $gtm_test_tls) then
	# The below test requires TLS to be enabled, so exclude the test if TLS is disabled
	setenv subtest_exclude_list "$subtest_exclude_list tlsreneg_msg-gtmde567908"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# Disable the below subtest because it is a white-box test that sets gdb breakpoints on
	# functions that are only reliably resolvable in a debug build.
	setenv subtest_exclude_list "$subtest_exclude_list jnlwritereserve_order-gtmf228991"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v71003 test DONE."
