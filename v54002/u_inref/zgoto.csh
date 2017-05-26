#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Run basic zgoto test
#
$gtm_dist/mumps -run zgoto1
#
# ZGoto a non-existent label in an existing routine (expect error)
#
$gtm_dist/mumps -dir <<EOF
Write "ZGoto a non-existent label in an existing routine (expect error)",!
ZGOTO \$ZLevel:Next99^zgoto1
EOF
#
# ZGoto a non-existent routine (expect error)
#
$gtm_dist/mumps -dir <<EOF
Write "ZGoto a non-existent routine (expect error)",!
ZGOTO \$ZLevel:^zgoto99
EOF

echo ""
$gtm_exe/mumps -run zgoto5
