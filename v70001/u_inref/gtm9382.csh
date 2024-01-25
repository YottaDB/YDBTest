#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9382 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9382)

GT.M appropriately handles symbolic links and relative paths in the $gtm_dist path. In V7.0-000,
GT.M issued a GTMSECSHRPERM or SYSCALL error when the first process attempting access to a previously
quiescent database file had read-only permissions to the file. Other actions that require gtmsecshr
(e.g., when dealing with processes or resources created or owned by a different user, such as waking
or checking for the existence, and removing or instantiating a resource, such as semaphores, shared
memory or socket files) could result in such error messages as well. The workaround was to avoid
symbolic links and relative paths for V7.0-000 (GTM-9382)

CAT_EOF

echo '# Create database mumps.dat'
$gtm_tst/com/dbcreate.csh mumps

echo '# Set read-only permission on mumps.dat'
chmod a-w mumps.dat

echo '# Set soft link from [./gtmdist] in current directory to [$gtm_dist] and reset [gtm_dist] env var to point to [./gtmdist]'
ln -s $gtm_dist gtmdist
unsetenv ydb_dist
unsetenv gtm_dist
setenv gtm_dist "./gtmdist"

echo '# Access database using [$gtm_dist/mumps] now that $gtm_dist is a soft link to the real $gtm_dist.'
echo '# We do not expect any error. With GT.M V7.0-000, we would see a %GTM-E-GTMSECSHRPERM error at this point.'
echo '# Note that with GT.M V7.0-001 and later versions, we do not see the %GTM-E-GTMSECSHRPERM error but do see a'
echo '# [gtmsecshr not named gtmsecshr] error. None of the YottaDB builds though issue this error (which is good).'
echo '# So while this test does not pass with GT.M V7.0-001, it does show a difference in behavior between V7.0-000'
echo '# and V7.0-001 and is therefore considered a good test.'
$gtm_dist/mumps -run %XCMD 'set x=$get(^a)'

echo '# Set read-write permission back on mumps.dat'
chmod a+w mumps.dat

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
