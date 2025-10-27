#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Validate the encryption-related fields added in jnl and database file header
#
$gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -journal=enable,before -reg "*"

echo "THE DATABASE ENCRYPTION HEADER FIELDS ARE"

$DSE dump -f -all >&! dse_dump.outx
# Search for lines in the dse dump output that contain DB or Database.
# Make sure those show up as full words by searching for a space before and after those words.
# Or else we would match unrelated lines that contain say `DB` as a substring and cause false test failures.
$grep -E " (DB|Database) .*encr" dse_dump.outx

echo "THE JOURNAL FILE  ENCRYPTION HEADER FIELDS ARE"
$DSE dump -f |& $grep "Journal State"

$MUPIP journal -show=HEADER -forward -noverify mumps.mjl >&jnl.out

$grep -E " Journal file .*(crypt|hash|IV)" jnl.out

$gtm_tst/com/dbcheck.csh
