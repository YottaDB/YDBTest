#!/usr/local/bin/tcsh -f
#################################################################
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
#
# Test runtime behavior after PATNOTFOUND compile-time error
#

cp $gtm_tst/$tst/inref/patnotfound*.m .

foreach file (patnotfound*.m)
	echo " --> Running test with $file <---"
	$gtm_dist/mumps -run $file:r
	echo ""
end
