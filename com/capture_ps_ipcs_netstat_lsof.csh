#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Include -l option to have the "Process State" information. But not including it in the default $ps as it has some column issues
set ps = "${ps:s/ps /ps -l /}"  #BYPASSOK ps

foreach debugcmd ( '$ps' '$gtm_tst/com/ipcs -a' '$netstat' '$lsof -i' 'setenv' 'set' )
        echo "########################################################################"
	echo "Time = `date`"
        eval "echo '#' $debugcmd"
        echo "########################################################################"
        eval $debugcmd
        echo ""
end

