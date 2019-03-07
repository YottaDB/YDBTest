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
# Waits until stty -a shows "-echo" i.e. ECHO is turned OFF
# Operates on tty name stored in "term_env.txt".
#
# This script is invoked when the expect script wants to be sure the mumps program has started
# executing a READ or READ * command. The only way to ensure this is by waiting for the terminal
# ECHO setting to be turned OFF (which is done only when the READ starts executing). Sending more
# data without waiting for this event could cause occasional test failures (for example due to
# input data getting displayed more than once because the ECHO setting is ON etc.).
#
set ttyname = `cat term_env.txt`
while (1)
	stty -a -F $ttyname | grep -q '\-\<echo\>'
	if (0 == $status) then
		break
	endif
	sleep 1
end
