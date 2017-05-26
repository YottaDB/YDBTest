#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# instream.csh for test mm
# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
$gtm_tst/com/dbcreate.csh .

$GTM << zyx
Write "Do ^basicmm",!  Do ^basicmm
Do ^%G

*

Halt
zyx
$gtm_tst/com/dbcheck.csh
