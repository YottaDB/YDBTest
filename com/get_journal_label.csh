#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# Script to determine the Journal file label
#
# Input:
# 		$gtm_dist
# Output:
# 		If ${1:h}/inc/jnl.h does not exist, report UNSUPPORTED.
# 		Otherwise AWK should find a value.
#
# NOTE: There is only one caller of test/com_u/get_journal_label.csh,
# test/64bittn/u_inref/upgrade_and_start_repl.csh. If this script is run
# outside of the usual FIS environment, both versions under test will see the
# same journal version, UNSUPPORTED. As such the test will skip checking for
# YDB-E-JNLBADLABEL.
#
# However, if the external testing environment has attempted to set up GT.M
# development style builds, there is no telling how this test will operate.

if !( -e ${1:h}/inc/jnl.h ) then
	echo "UNSUPPORTED"
	exit 1
endif

$tst_awk '/.define JNL_LABEL_TEXT/{gsub(/"/,"");print $3;exit}' ${1:h}/inc/jnl.h

