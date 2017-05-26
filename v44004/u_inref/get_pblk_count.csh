#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2004, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# In case freeze is on due to fake ENSOPC, MUPIP journal -extract will issue DBCOLLREQ warning and move on to journal extract.
# If we don't do this, we get a disruptive SETEXTRENV error.
setenv  gtm_extract_nocol 1
$MUPIP journal -extract -detail -fence=NONE -forward mumps.mjl |& $grep -v DBCOLLREQ
set pblk = `$grep PBLK mumps.mjf | wc -l `
echo $pblk >! pblk.txt
if ("PRI" == "$1") then
	#expecting only a couple, since set noop optimization is enabled
	if (3 < $pblk) then
		echo "TEST-E-TOOMANY PBLK's on primary $pblk"
	else
		echo "PBLK count is as expected. OK."
	endif
else
	# SEC == $1
	#expecting more than 50, since set noop optimization is not enabled
	# although there were 100 updates to the DB, due to a slow system, multiple updates might
	# show up together, so let's keep a safety net of 50%
	if (50 < $pblk) then
		echo "PBLK count is as expected. OK."
	else
		echo "TEST-E-TOOFEW PBLK's on secondary: $pblk"
	endif
endif

