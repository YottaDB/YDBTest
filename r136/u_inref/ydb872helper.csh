#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This is a helper script only invoked by r136/u_inref/ydb872.csh
# Implements the helper.csh part of https://gitlab.com/YottaDB/DB/YDB/-/issues/872#description

@ cnt = 0
while ($cnt < 25)
        if (-e STOP) then
		# Some other process encountered an error. No point continuing further. Stop this process too.
                break
        endif
	# Run empty M program to trigger auto relink logic that will open/close relinkctl file in a short-lived process
        $ydb_dist/yottadb -run tmp
        if ($status) then
		# This process encountered an error. Stop the helper script.
                touch STOP
                break
        endif
        @ cnt = $cnt + 1
end

