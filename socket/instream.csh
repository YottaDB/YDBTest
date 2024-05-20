#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
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
setenv subtest_list "socbasic dic clntsrvr C9H04002843 socmemleak chkbroksock soczshowdleak lsocbasic lsocmemleak"
setenv subtest_list_non_replic "unixdomain gtcm_ipv6 dollarp waittimeout ltsockzintr lsocparms lsoczshow waitmultiple lsocpass"
setenv subtest_list_non_replic "$subtest_list_non_replic lsocpassmulti zsocket splitp"
if ("TRUE" == "$gtm_test_tls") then
	# The below subtests need TLS setup
	setenv subtest_list_non_replic "$subtest_list_non_replic tsocerrors mwebserver"
endif
if ($LFE == "E") then
   setenv subtest_list "$subtest_list socdevice"
endif

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list $subtest_list_replic"
else
	setenv subtest_list "$subtest_list $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list ""

if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list unixdomain gtcm_ipv6"
endif

# For solaris 9,  a numeric host address string can only be a dotted-decimal IPv4 address
# or or an IPv6 hex address.
if("HOST_SUNOS_SPARC" == "$gtm_test_os_machtype") then
       setenv subtest_exclude_list "$subtest_exclude_list gtcm_ipv6"
endif
# No IPv6 or nanoinetd support on Tru64
if ("HOST_OSF1_ALPHA" == "$gtm_test_os_machtype") then
	setenv subtest_exclude_list "$subtest_exclude_list gtcm_ipv6 dollarp"
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
