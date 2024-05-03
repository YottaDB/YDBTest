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
GTM-DE294187 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-003_Release_Notes.html#GTM-DE294187)

Reading from \$ZKey works as expected. Previously under rare circumstances, an access of \$ZKey could
result in a segmentation violation (SIG-11). This was only seen in development and not reported by a
customer. (GTM-DE294187)

--------------------------------------------------------------------------------------------
See https://gitlab.com/YottaDB/DB/YDBTest/-/issues/595#note_1892151349 for details on the code fix.
The test case should cause \$ZKEY to return a list of at least 2 sockets in order to exercise the buggy code path.
Therefore, the M program gtmde294187.m jobs off 2 children each of which open a socket that connects to a listening
socket opened by the parent (2 listening sockets in total that the parent creates). The parent never does a READ
but does a lot of WRITE /WAIT and then accesses \$ZKEY to ensure \$ZKEY is not an empty string. It does this a lot
of times to ensure stringpool churn happens.

With this test case, GT.M V7.0-002 produces a SIG-11 whereas GT.M V7.0-003 does not.
Although YottaDB r2.00 does not have the GT.M V7.0-003 fixes, it does not produce a SIG-11 like V7.0-002.
But if one does an ASAN build of YottaDB r2.00 one can see a "AddressSanitizer: heap-use-after-free" error
confirming the same issue. This error does not show up in the master branch which has the GT.M V7.0-003 fixes.

Note though that this test does not fail all the time with V7.0-003 or with an ASAN build of YottaDB r2.00.
It fails 40% of the time or so. That is considered good enough of a test case.

--------------------------------------------------------------------------------------------
CAT_EOF

source $gtm_tst/com/portno_acquire.csh >>& portno1.out	# Acquire port 1
setenv portno1 $portno
source $gtm_tst/com/portno_acquire.csh >>& portno2.out	# Acquire port 2
setenv portno2 $portno

echo "# Running [mumps -run gtmde294187]"
echo "# Expecting no SIG-11 or heap-use-after-free error (in an ASAN build)"
echo "# Expecting to see zkey(10000) set to a list of 2 socket devices that are ready for READ"
$gtm_dist/mumps -run gtmde294187

cp portno1.out portno.out
$gtm_tst/com/portno_release.csh	# Release port 1
cp portno2.out portno.out
$gtm_tst/com/portno_release.csh	# Release port 2

