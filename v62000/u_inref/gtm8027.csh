#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

$GTM << GTM_EOF
	write \$view("REGION","")	; test null string
	view "NOUNDEF"			; set NOUNDEF to test undefined local and global variables
	write \$view("REGION",x)	; test undefined local variable which also translates to null string
	write \$view("REGION",^x)	; test undefined global variable which also translates to null string
GTM_EOF

$gtm_tst/com/dbcheck.csh
