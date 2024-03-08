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
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE201380 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637457)

USE SOCKET handles the ATTACH, DETACH, CONNECT, SOCKET and ZLISTEN deviceparameters appropriately; previously, certain arguments
for these deviceparameters could cause a segmentation violation(SIG-11). (GTM-DE201380)

CAT_EOF
echo ''
setenv ydb_prompt "GTM>"
setenv ydb_msgprefix "GTM"
echo 'deviceparameter longer than 127 will cause a %GTM-F-KILLBYSIGSINFO1 error (killed by a signal 6) except for ZLISTEN on'
echo 'release build and will cause %GTM-F-ASSERT error on debug build in version prior to V7.0-002'
echo ''
echo 'For ZLISTEN, deviceparameter longer than 127 will will cause a %GTM-E-ADDRTOOLONG with garbage output on release build'
echo 'and will cause %GTM-F-ASSERT error on debug build in version prior to V7.0-002 like the others.'
echo ''
echo "Test for ATTACH"
$GTM << GTM_EOF
	do ATTACH128^gtmde201380
GTM_EOF
echo ""
echo "Test for DETACH"
$GTM << GTM_EOF
	do DETACH128^gtmde201380
GTM_EOF
echo ""
echo "Test for CONNECT"
$GTM << GTM_EOF
	do CONNECT128^gtmde201380
GTM_EOF
echo ""
echo "Test for SOCKET"
$GTM << GTM_EOF
	do SOCKET128^gtmde201380
GTM_EOF
echo ""
echo "Test for ZLISTEN"
$GTM << GTM_EOF
	do ZLISTEN128^gtmde201380
GTM_EOF
