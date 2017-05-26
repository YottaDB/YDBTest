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

@ tnum = 1
while ($tnum < 13)
	echo "Running test : $gtm_exe/mumps -run gtm7963 test${tnum}"
	$gtm_exe/mumps -run gtm7963 test${tnum}
	echo ""
	@ tnum = $tnum + 1
end
