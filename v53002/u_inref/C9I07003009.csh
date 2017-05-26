#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2008, 2014 Fidelity Information Services, Inc	#
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
$grep -c "Error in GT.M help utility" C9I07003009.outx
$grep c003009 C9I07003009.outx

echo ""
echo "# End of test"
