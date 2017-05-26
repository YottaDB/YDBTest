#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a helper script for gtm8494.csh, called by gtm8494_sec.csh that does dse crit -seize and -release

# prepare the dse commands
cat > dse_crit.cmd << CAT_EOF
crit -seize
spawn "sleep 1"
crit -release
crit -seize
spawn "sleep 2"
crit -release
crit -seize
spawn "sleep 3"
crit -release
CAT_EOF

# Wait for the backups to start
while (! -d bak_1)
	sleep 1
end

# Do until asked to stop
@ cnt = 1
while ( (! -e test.end) && (50 >= $cnt) )
	echo "`date` : dse crit round $cnt"
	$DSE < dse_crit.cmd
	@ cnt++
end

echo "`date` : gtm8494_dsecrit.csh ended at round : $cnt"	>>&! dsecrit.end
