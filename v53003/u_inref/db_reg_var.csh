#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# MUPIP BACKUP backups regions in FTOK order we make a dummy call to MUPIP BACKUP and use the output to create variables
# dynamically.
# We create variables reg1 reg2 reg3 with region names in ftok order. E.g AREG BREG DEFAULT
# We create variables db1 db2 db3 with database file names in ftok order. E.g. a.dat b.dat mumps.dat
# We create variables dbname1 dbname2 dbname3 with database file names in ftok order. E.g. a b mumps
mkdir dummybackup
chmod 777 dummybackup
$MUPIP backup '*' dummybackup >& dummybackup.log
set count=1
set dblist = `grep BACKUPDBFILE dummybackup.log | sed 's,.*dummybackup/,,;'`
foreach i ( $dblist )
	set name="db""$count"
	set $name=$i
	set name="dbname""$count"
	set $name=$i:r
	set tr="$i:r"
	set name1="reg""$count"
	if ("$tr" == "a") then
		set $name1=AREG
	else
		if ("$tr" == "b") then
			set $name1=BREG
		else
			set $name1=DEFAULT
		endif
	endif
	@ count++
end
