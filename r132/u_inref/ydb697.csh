#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This test checks that CONVNEG^%CONVBASEUTIL produces the correct output for octal input from 1 to 10 digits."
echo "# Due to a bug introduced in upstream version V6.3-009, CONVNEG would produce incorrect output if the first 2"
echo "# octal digits were not zero and all remaining digits (if any) were zero which caused a rare failure in the"
echo "# %DO with negative input section of v63009/gtm5574. This test generates random octal values from 1 to 10 digits"
echo "# and tests each of those numbers. It also pads the random numbers with zeroes and tests these numbers up to 10"
echo "# digits. All random octal numbers are generated with digits of 1-7 so no numbers will be repeated."
$ydb_dist/mumps -r ydb697
