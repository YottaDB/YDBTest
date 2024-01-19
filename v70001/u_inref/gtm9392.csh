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
GTM-9392 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9392)

GT.M correctly maintains NOISOLATION characteristics for globals. Due to a regression in V6.3-003, the
application of NOISOLATION to globals may not have worked when there was a configuration difference
between a region's maximum key size in the Global Directory and the database file header. The
workaround was to ensure that the maximum key size settings are the same in the Global Directory
and the database file header. (GTM-9392)

CAT_EOF

echo '# Create gld and database both with max-key-size=64'
$gtm_tst/com/dbcreate.csh mumps -key_size=64

echo '# Change max-key-size in gld to be 40 (so it differs from db max-key-size of 64)'
$gtm_dist/mumps -run GDE change -region DEFAULT -key_size=40

echo '# Run [mumps -run gtm9392]'
$gtm_dist/mumps -run gtm9392

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
