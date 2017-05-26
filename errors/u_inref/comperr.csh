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
#
# Test an invalid statement form in direct mode. Prior to this post-V62001 fix, this statement
# caused an assert failure in m_do.c. This test is to make sure that issue stays gone and that
# an appropriate error is raised in both pro and dbg builds.
#
$gtm_dist/mumps -dir << EOF
Do @lbl+@n^artn(arg)
EOF
