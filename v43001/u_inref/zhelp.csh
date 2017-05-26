#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#C9710-000276
echo "Entering ZHELP subtest"
unsetenv gtmgbldir
$GTM <<xyz >& zhelp.out
zhelp "About_GTM"
xyz
# If the GREP succeeds there will be a reference file DIFF
$grep "Error in GT.M help utility" zhelp.out || echo PASS
echo "Leaving ZHELP subtest"
