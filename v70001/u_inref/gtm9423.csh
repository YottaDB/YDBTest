#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-9423 - Verify MUPIP DUMPFHEAD recognizes the -FLUSH parameter
#
echo '# Release note:'
echo '#'
echo '# MUPIP DUMPFHEAD -FLUSH -REGION performs a database file header flush for the'
echo '# specified region(s) before displaying the database file header fields. If the'
echo '# database file header flush fails, MUPIP DUMPFHEAD -FLUSH produces the BUFFLUFAILED'
echo '# warning. The qualifier makes the command considerably more heavy weight, and, in'
echo '# most cases, does not provide material benefit, but there may be cases where it'
echo '# addresses a need. Previously, MUPIP DUMPFHEAD provided no option to flush the'
echo '# database file header fields. (GTM-9423)'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Drive main routine gtm9423'
$gtm_dist/mumps -run gtm9423
echo
echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
