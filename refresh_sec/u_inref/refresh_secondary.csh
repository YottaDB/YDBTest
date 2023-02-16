#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh # This test refreshes secondary from a primary backup and so disable -trigupdate

$gtm_tst/$tst/u_inref/refresh_secondary_base.csh >&! refresh_secondary_base.log
grep -v "shmpool lock preventing" refresh_secondary_base.log >& refresh_secondary_base1.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk refresh_secondary_base1.log

# The filter_64bittn.awk is just a copy from 64bittn test. This particular subtest was moved from 64bittn. For now we will have a copy of the awk here
