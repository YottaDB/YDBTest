#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2008-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9I02-002956 MUPIP INTEG does not report DBINVGBL integrity error
#
# Run three different tests and ensure that in each case, mixing global names shows up in MUPIP INTEG as a DBINVGBL error.
# Test cases where LEFTMOST leaf block as well as non-LEFTMOST leaf blocks have the DBINVGBL error.
# This is why we create a global with 3 leaf blocks and induce the error in each leaf block one after the other.
#
# The dse restore command below will print an additional line about renaming jnl file, if journaling is enabled
# so, let's not randomly enable journaling in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
foreach value (1 2 3)
	$gtm_tst/com/dbcreate.csh mumps -block_size=1024
	$GTM <<GTM_EOF
		do test${value}^c002956
GTM_EOF
	# The above test would have created TWO global variables.
	# The first one would use blocks 3 (leaf) and 4 (index).
	# The second one would use blocks 7,8,5 (leaf) and 6 (index).
	# Restore the leaf block 3 from the first GVT onto any leaf block from the second GVT.
	# This will induce a DBINVGBL integrity error.
	cp mumps.dat bak${value}.dat
	foreach leaf (7 8 5)
		echo "---------------------------------------------------------------------------------------------"
		echo "Running test$value^c002956 : Leaf Block 3 is pasted onto leaf block $leaf"
		echo "---------------------------------------------------------------------------------------------"
		cp bak${value}.dat mumps.dat
		$DSE << DSE_EOF
			save -bl=3
			restore -bl=$leaf -from=3 -ver=1
DSE_EOF
		sleep 1	# necessary to ensure the mupip.err_* files created by dbcheck dont overlap between multiple iterations
		# overlapping files cause reference file headaches
		$gtm_tst/com/dbcheck.csh
	end
end
