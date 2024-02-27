#!/usr/local/bin/tcsh -f
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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE201305 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637290)

When the Database segment to file mapping uses an environment variable, and the environment variable is not defined, MUPIP BACKUP
uses the environment variable name itself in constructing the file name, as does MUPIP CREATE. Previously MUPIP CREATE created
database with undefined environment variable name as the database name, but MUPIP BACKUP failed to backup that existing database.
(GTM-DE201305)

CAT_EOF

setenv ydb_msgprefix "GTM"
echo '# Create GLD File with default segment file change to $TEST.dat'
$GDE >& gde.out << GDE_EOF
change -segment DEFAULT -file=\$TEST.dat
GDE_EOF
echo ""
echo "# Create database file"

$MUPIP create
echo ""
echo "# Do MUPIP backup (This fails in YottaDB r2.00 with a TEST: Undefined variable error but succeeds in YottaDB r2.02)"
mkdir bak
$MUPIP backup DEFAULT bak
