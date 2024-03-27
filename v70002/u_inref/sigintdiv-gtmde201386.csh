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

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTMDE-201386 - Test the following release note
*****************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637465)

> GT.M appropriately detects divide by zero; previously
> there were some unusual combinations of calculations
> which produced a SIGINTDIV (SIG-8), which could not
> be trapped and therefore terminated the process.

See also:
  https://gitlab.com/YottaDB/DB/YDBTest/-/issues/580
CAT_EOF
echo ""

setenv ydb_msgprefix "GTM"
$gtm_dist/mumps -run sigintdiv^gtmde201386
