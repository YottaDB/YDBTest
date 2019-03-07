#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
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

# GTM-7291 Add test for GDINVALID error that it prints the .. syntax
# GTM-7291 primarily was changes to MUPIP JOURNAL -ROLLBACK -FORWARD. This is tested in the "forw_rollback" test.

$GTM << GTM_EOF
	set \$zgbldir="\$gtm_dist/libyottadb.so"
GTM_EOF
