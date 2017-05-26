#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# We've seen some basic issues with tcsh and had to upgrade/downgrade tcsh to get them fixed
# Some issues would cause test failues or (even worse) result in false positives
# This tool checks if the current tcsh is good for our framework, by verifying various tcsh issues we've seen

# This tool should be sourced from check_setup_dependencies.csh (which already would have set $error)

### 1) $status inside backquote should be preserved ###
# Lets assume N0n-ExIstIng_c0mmand won't be a valid command
set backquotestat = `N0n-ExIstIng_C0mmand >&! /dev/null ; echo $status`
if (0 == "$backquotestat") then
	# In a good shell, $status would be non-zero and that would be sent to $backquotestat
	# In a bad shell, $status would be zero
	echo "TEST-E-TCSH : dollar_status inside backquotes does not work in this tcsh version - $version"
	@ error++
endif
