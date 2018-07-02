#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Helper script for gtm8850, starts mumps, does a couple updates and halts in a loop to verify
# it halts without hanging while an online freeze on/off command is concurrently running.
#
while (1)
        $ydb_dist/mumps -run ^%XCMD 'set ^x($j)=$j kill ^x($j)'
        if (-e test.STOP) then
		# foreground script gtm8850.csh has signaled us to STOP.
                break
        endif
end
