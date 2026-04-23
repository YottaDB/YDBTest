#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
####################################
### instream.csh for socket test ###
####################################
#------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#
# C9H04002843 [smw]	READ * with values above 127
# chkbroksock [estess]	Test for C9L06-003423 verifying WRITE /mnemonic fixes
# soczshowdleak [smw]	GTM-6996 zshow "D" on socket memory leak
# ipv6		[zouc]	GTM-7500 ipv6 test
# unixdomain 	[zouc]  Test for unix domain sockets
# gtcm_ipv6	[zouc]  Test for ipv6 support for gtcm
# dollarp	[duzang] Test socket as $principal
# waittimeout	[duzang] Test socket wait timeout
# lsocbasic	[smw]	socbasic using LOCAL sockets
# ltsockzintr	[smw]	v52000/C9G04002779 using LOCAL sockets
# lsocmemleak	[smw]	socmemleak using LOCAL sockets
# lsocparms	[smw]	LOCAL sockets specific device parameters
# lsoczshow	[smw]	LOCAL sockets ZSHOW device
# waitmultiple	[smw]	GTM-3731/GTM-7929 WRITE /WAIT improvments
# lsocpass	[duzang] PASS/ACCEPT sockets over LOCAL sockets
# lsocpassmulti	[duzang] PASS/ACCEPT multiple socket sequentially over a LOCAL socket
# zsocket	[smw]	GTM-7735 $ZSOCKET function
# tsocerrors	[smw]	GTM-7418 WRITE /TLS config and errors
# splitp	[duzang] Test different sockets on stdin/stdout
# mwebserver	[smw]	GTM-8302 TLS access to M Web Server
#------------------------------------------------------------------------------------
echo "SOCKET test Starts..."
setenv subtest_list_common ""
setenv subtest_list_common "$subtest_list_common socbasic"
setenv subtest_list_common "$subtest_list_common dic"
setenv subtest_list_common "$subtest_list_common clntsrvr"
setenv subtest_list_common "$subtest_list_common C9H04002843"
setenv subtest_list_common "$subtest_list_common socmemleak"
setenv subtest_list_common "$subtest_list_common chkbroksock"
setenv subtest_list_common "$subtest_list_common soczshowdleak"
setenv subtest_list_common "$subtest_list_common lsocbasic"
setenv subtest_list_common "$subtest_list_common lsocmemleak"
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic unixdomain"
setenv subtest_list_non_replic "$subtest_list_non_replic gtcm_ipv6"
setenv subtest_list_non_replic "$subtest_list_non_replic dollarp"
setenv subtest_list_non_replic "$subtest_list_non_replic waittimeout"
setenv subtest_list_non_replic "$subtest_list_non_replic ltsockzintr"
setenv subtest_list_non_replic "$subtest_list_non_replic lsocparms"
setenv subtest_list_non_replic "$subtest_list_non_replic lsoczshow"
setenv subtest_list_non_replic "$subtest_list_non_replic waitmultiple "
setenv subtest_list_non_replic "$subtest_list_non_replic lsocpass"
setenv subtest_list_non_replic "$subtest_list_non_replic lsocpassmulti"
setenv subtest_list_non_replic "$subtest_list_non_replic zsocket"
setenv subtest_list_non_replic "$subtest_list_non_replic splitp"
setenv subtest_list_non_replic "$subtest_list_non_replic tsocerrors"
setenv subtest_list_non_replic "$subtest_list_non_replic mwebserver"
setenv subtest_list_replic ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

if ($LFE == "E") then
	setenv subtest_list "$subtest_list socdevice"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list ""

if ("TRUE" != "$gtm_test_tls") then
	# The below subtests need TLS setup
	setenv subtest_exclude_list "$subtest_exclude_list tsocerrors mwebserver"
endif

# Filter out tests requiring specific gg-user setup, if the setup is not available
if ($?gtm_test_noggusers) then
	setenv subtest_exclude_list "$subtest_exclude_list lsocparms"
endif

$gtm_tst/com/submit_subtest.csh
echo "SOCKET test DONE."

#
##################################
###          END               ###
##################################
