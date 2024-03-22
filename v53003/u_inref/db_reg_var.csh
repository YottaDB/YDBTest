#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
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
$MUPIP backup -dbg '*' dummybackup >& dummybackup.log
set count=1
set reglist = `grep "Temp file name" dummybackup.log | sed 's,.*//,,;s/_.*//;'`
foreach i ( $reglist )
	set var1 = "reg$count"
	set var2 = "db$count"
	set var3 = "dbname$count"
	switch ($i)
	case "AREG":
		set $var1 = "AREG"
		set $var2 = "a.dat"
		set $var3 = "a"
		breaksw
	case "BREG":
		set $var1 = "BREG"
		set $var2 = "b.dat"
		set $var3 = "b"
		breaksw
	case "DEFAULT":
	default:
		set $var1 = "DEFAULT"
		set $var2 = "mumps.dat"
		set $var3 = "mumps"
		breaksw
	endsw
	@ count++
end
