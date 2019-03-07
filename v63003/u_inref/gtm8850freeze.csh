#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Helper script for gtm885, turns freeze on and off until signalled to stop
#
while (1)
	set rand = `$gtm_tst/com/genrandnumbers.csh 1 0 1`
	echo $rand
	set mod =""
	if ($rand) then
		set mod="noautorelease"
	else
		set mod="autorelease"
	endif
        $ydb_dist/mupip freeze -online -on -$mod "*"
        sleep 1
        $ydb_dist/mupip freeze -off "*"
        if (-e test.STOP) then
		# foreground script gtm8850.csh has signaled us to STOP.
                break
        endif
end
