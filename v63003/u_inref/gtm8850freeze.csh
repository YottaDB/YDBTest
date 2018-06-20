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
#
#

rm -f test.STOP
while (1)
        $ydb_dist/mupip freeze -online -on -noautorelease "*"
        sleep 1
        $ydb_dist/mupip freeze -off "*"
        if (-e test.STOP) then
		echo "# Freeze process finished properly"
                break
        endif
end



