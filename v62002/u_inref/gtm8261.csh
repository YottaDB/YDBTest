#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# test that switching NOFULL_BOOLEAN off and on does not cause an assert
unsetenv gtm_side_effects
$GTM <<GTM_EOF
for bool="full_boolean","nofull_boolean","full_boolean" view bool zlink "gtm8261.m"
GTM_EOF
echo "Done gtm8261"
