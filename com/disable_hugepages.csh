#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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

# This script is to disable the environment variables related to huge pages testing
# This script should be "source"d in test/subtests that requires the feature to be disabled

unsetenv HUGETLB_SHM
unsetenv HUGETLB_VERBOSE
unsetenv gtm_hugetlb_shm
unsetenv ydb_hugetlb_shm

