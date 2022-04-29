#!/usr/local/bin/tcsh -f
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
# Script to drive the chosen test script

set user = "$1"
set script = "$2"
set ydbdist = "$3"
if (("" == "$user") || ("" == "$script") || ("" == "$ydbdist")) then
    echo "Missing parameters 'uid script ydbdist'"
    exit 1
endif

set scriptfn = `basename $2`
set pwd = `pwd`

setenv ydb_dist ${ydbdist}
# Do some per-test setup while we still have root privs (root privs disappear inside the script we drive)
switch ("$scriptfn")
case "testZGBLDIRACC.sh":
    # Hide the global directory to cause ZGBLDIRACC message
    mv mumps.gld mumps.gld.nofind
    breaksw
case "testDBPRIVERR.sh":
    # Set DB for read/only access to cause DBPRIVERR message
    chmod 444 mumps.dat
    breaksw
case "testSETZDIR.sh":
    breaksw
default:
    echo "TEST-E-UNKNOWN Unknown test id"
    exit 1
endsw
# Since the alternate id (ydbtest3) won't have access to $gtm_tst/$tst/u_inref, copy the test script over now.
cp -pr $gtm_tst/$tst/u_inref/${scriptfn} .
# Switch to test userid to see what it generates (may be the current userid running the test or may be alternate id).
sudo su - $user >& drivescript_${scriptfn}_${user}.logx << EOF
cd ${pwd}
${script} ${ydbdist}
exit
EOF
# Do any per-test cleanup we need to do with root privs
switch ("$scriptfn")
case "testZGBLDIRACC.sh":
    # Put the global directory back the way it needs to be
    mv mumps.gld.nofind mumps.gld
    breaksw
case "testDBPRIVERR.sh":
    # Set DB back to RW access
    chmod 644 mumps.dat
    breaksw
case "testSETZDIR.sh":
    breaksw
endsw
exit $status
