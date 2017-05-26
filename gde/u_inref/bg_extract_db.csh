#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# A helper job to do extracts in the background since each extract takes a long time with encryption

set prefix = "$1"
@ i = $2
@ end = $3

while ($i <= $end)
	set fname = "$prefix$i"
	if (0 == $i) set fname = "mumps"
	$gtm_tst/com/extract_database.csh $fname tmp${fname} &
	@ i++
end
wait
