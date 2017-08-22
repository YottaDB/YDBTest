#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2001-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test is similar to rqtest04 except that this is for global variables
echo '# Test of reverse $query on global variable subtree that contains just the null subscript'

@ cnt = 1
foreach querydir (1 -1)
	foreach stdnullcoll (true false)
		mkdir $cnt
		cd $cnt
		$gtm_tst/com/dbcreate.csh mumps
		$gtm_dist/dse change -file -null=TRUE >& rqtest09_dse_$cnt.out
		$gtm_dist/dse change -file -stdnullcoll=$stdnullcoll >>& rqtest09_dse_$cnt.out
		$gtm_dist/mumps -run rqtest09 $querydir $stdnullcoll
		$gtm_tst/com/dbcheck.csh
		cd ..
		@ cnt = $cnt + 1
	end
end
