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

# Waits (in increments of 0.1 seconds) until an input Unix Domain Socket file becomes used as a LISTENING port
#
set unix_socket_filename = "$1"

while (1)
	# Need space around "$unix_socket_filename" below to ensure we don't get false matches with substring file names
	set is_listening = `$ss -xln | $grep " $unix_socket_filename "`
	if ("$is_listening" != "") then
		break
	endif
	sleep 0.1
end

