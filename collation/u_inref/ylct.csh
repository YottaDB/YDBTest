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
#
# This test verifies that setting various local collation parameters (collation itself, ncol, and nct)
# works as expected, both via VIEW command directly and the %LCLCOL utility. Also verify that the
# 'sorts after' operator correctly responds to the nct mode switches.

source $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 1

echo "Test that just setting various local collation options works"
$gtm_dist/mumps -run setparm^ylct
echo

echo "Test that setting the above fails if there are some local data stored"
$gtm_dist/mumps -run setparmwithlcl^ylct
echo

echo "Test that 'sorts after' operator works as expected, first with no local collation"
$gtm_dist/mumps -run sortsafterwithoutcol^ylct
echo

echo "Then using a local collation"
$gtm_dist/mumps -run sortsafterwithcol^ylct
echo

echo "Then with nct enabled, but no local collation in use"
$gtm_dist/mumps -run sortsafterwithoutcolwithnct^ylct
echo

echo "And finally with nct on and local collation in use"
$gtm_dist/mumps -run sortsafterwithcolwithnct^ylct
echo

echo "Test that UNDEF errors are issued correctly with local collations"
$gtm_dist/mumps -direct <<EOF
	write !,\$\$set^%LCLCOL(1)
	write !,a]]b
	write !,\$\$set^%LCLCOL(0)
	write !,a]]b
EOF
