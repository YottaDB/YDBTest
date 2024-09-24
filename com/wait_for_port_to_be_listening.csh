#!/usr/local/bin/tcsh -f
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

# Waits (in increments of 0.1 seconds) until an input port (TCP or UDP) becomes a LISTENING port
#
set portno = $1

while (1)
	# Need space after "$portno" below to ensure we don't get false matches with substring port numbers
	# (e.g. a listening port "1234" will falsely satisfy the grep for port 123 if the search pattern was just ":123")
	set is_listening = `$ss -tuln | $grep ":$portno "`
	if ("$is_listening" != "") then
		break
	endif
	sleep 0.1
end

