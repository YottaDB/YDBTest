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
# This is a helper process concurrently invoked by gtm9410.csh to test GDE invocations that modify the gld file.
#
@ iteration = 1
while ($iteration < 1000)
	if (-e bg.stop) then
		break
	endif
	# Use .outx extension (not .out) as it can contain %SYSTEM-E-ENO2 errors and we don't want test framework to see it.
	$GDE "change -segment DEFAULT -file=mumps.dat" < /dev/null >& bg_${index}_$iteration.outx
	if ($status) then
		touch bg.stop	# Signal other background [gtm9410_helper.csh] processes to also stop
	endif
	@ iteration = $iteration + 1
end

