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
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-DE297205)

GT.M processes shut down gracefully when they receive a MUPIP STOP while preforming an OPEN of a SOCKET
device. Previously, these conditions could cause a GT.M process to issue a GTMASSERT2 error. (GTM-DE297205)

CAT_EOF

setenv ydb_msgprefix "GTM"   # So can run the test under GTM or YDB

echo '# Details of test at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/608#note_2014313187'
echo '# Run [mumps -run gtmde297205] in the background'
echo '# This M program does SOCKET OPEN and CLOSE:(DESTROY) in an indefinite FOR loop'
($gtm_dist/mumps -run gtmde297205 & ; echo $! >&! bg.pid) >&! bg.out

echo '# While the SOCKET OPEN is running in the background, send a MUPIP STOP to the M program'
echo '# We do not expect to see any GTMASSERT2 messages below'
echo '# GT.M V7.0-003 PRO build used to terminate abnormally with such messages 10% of the time'

set bgpid = `cat bg.pid`
$gtm_dist/mupip stop $bgpid

echo '# Wait for M program in the background to stop'
$gtm_tst/com/wait_for_proc_to_die.csh $bgpid

echo '# Examine the output of the M program to make sure no unexpected/fatal/GTMASSERT2 errors'
cat bg.out

# Rename bg.out to bg.outx to avoid test framework from again catching -F-FORCEDHALT (we have already "cat" it above)
mv bg.out bg.outx

