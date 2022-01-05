#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2008, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                     #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9I07-003009 test that a zhelp error leaves $ecode=""
#

echo 'C9I07-003009 test that a zhelp error leaves $ecode as the empty string'
echo ""

$gtm_exe/mumps -run c003009 > & C9I07003009.outx
$grep -c "Error in GT.M help utility" zhelp.out
$grep c003009 C9I07003009.outx

echo ""
echo "# End of test"
