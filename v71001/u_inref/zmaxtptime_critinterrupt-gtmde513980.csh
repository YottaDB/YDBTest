#!/usr/local/bin/tcsh -f
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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE340950 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE513980)

GT.M correctly executes the ETRAP/ETRAP/ZTRAP exception handler at the time of expiry of \$ZMAXTPTIME when
the process holds a database critical section. Previously, due to a regression in V7.0-001, the \$ZMAXTPTIME timer
did not execute ETRAP/ETRAP/ZTRAP exception handler until the process released all database critical sections
which could allow a transaction to materially exceed the specified \$ZMAXTPTIME. (GTM-DE513980)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo '# Set gtm_tpnotacidtime to a value higher than the hang time of 15 seconds, i.e. 30 seconds, to avoid a TPNOTACID message in the below routine'
setenv gtm_tpnotacidtime 30
echo '# Run a gtmde5139800 to do a trestart until execution reaches the final retry. Then, while holding crit, hang for 15 seconds.'
echo '# Set $zmaxtptime to 2 seconds. And so we expect a TPTIMEOUT error to kick in the middle of the hang 15 when 2 seconds have elapsed.'
echo '# Prior to v71001, no TPTIMEOUT error would be issued.'
$gtm_dist/mumps -r gtmde513980

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
