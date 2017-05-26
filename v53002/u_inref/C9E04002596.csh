#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2008, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9E04-002596 Test multiple gld mapping regions to the same physical file
#

$gtm_tst/com/dbcreate.csh mumps 8 -rec=8000
#to test multiple global directories, copy the gld file
foreach no (0 1 2 3 4 5 6 7)
	cp mumps.gld mumpssec$no.gld
end

$GTM <<GTM_EOF
	do ^c002596
GTM_EOF

$gtm_tst/com/dbcheck.csh
