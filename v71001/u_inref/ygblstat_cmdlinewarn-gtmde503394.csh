#!/usr/local/bin/tcsh
#################################################################
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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE503394)

%YGBLSTAT warns about incorrect command line usage. Previously, the utility silently ignored command lines containing errors. (GTM-DE503394)
CAT_EOF

setenv ydb_msgprefix "GTM"
echo "# Run %YGBLSTAT with an unrecognized option '-badop' to trigger an error"
foreach option ("badop" "-badop" "--badop" "---badop")
	foreach argument ("" " 1" "=1")
		$gtm_dist/mumps -run %YGBLSTAT $option$argument >>& mumps.out
	end
end
echo "# Confirm a YGBLSTAT-F-INVALID error was reported and %YGBLSTAT usage is output."
echo "# Note that there is no output for options of the formats --option and ---option,"
echo "# even though these also should issue a YGBLSTAT-F-INVALID error."
echo "# Previously, running with an unrecognized option would result in no output in all cases."
