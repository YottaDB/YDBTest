#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# If we are running an older GT.M version (< V55000), there is no pinentry.m that GPG can talk to.
# Therefore, we opt for a simple script to follow GPG's agent protocol and return the default
# password in an unobfuscated form instead. Starting with V62002, the scripts allow PINENTRY to run
# in UTF-8 mode, but prior versions are not UTF-8 safe.
if (`expr $gtm_verno "<" "V62002"`) then
	set word = ""
	while (("$word" != "getpin") && ("$word" != "GETPIN"))
		echo "OK"
		set word = "$<"
	end
	echo "D ydbrocks"
	echo "OK"
else
	$gtm_dist/mumps -run $pinentry
	exit $?
endif
