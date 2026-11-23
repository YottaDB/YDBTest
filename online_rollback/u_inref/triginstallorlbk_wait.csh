#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Wait until a "mupip trigger" process that runs in the current directory has a database file open.
# Called by roller^triginstallorlbk before the first online rollback. An online rollback that finishes before
# "mupip trigger" opens the database file does not interrupt the trigger load with a DBROLLEDBACK error.
# Exits with status 0 once such a process is seen, and with status 1 if none is seen in 300 seconds.

set dir = `/bin/pwd -P`
@ tries = 0
while ($tries < 3000)
	foreach pid (`pgrep -x mupip`)
		if ("`readlink /proc/$pid/cwd`" != "$dir") continue
		tr '\0' ' ' < /proc/$pid/cmdline |& $grep -q ' trigger '
		if ($status) continue
		ls -l /proc/$pid/fd |& $grep -q '\.dat$'
		if (! $status) exit 0
	end
	sleep 0.1
	@ tries++
end
echo "TEST-E-FAIL : no mupip trigger process with a database file open seen in 300 seconds"
exit 1
