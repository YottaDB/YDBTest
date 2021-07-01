#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Note: This test does not use test framework scripts dbcreate.csh (and dbcheck.csh) as it is not straightforward to
# create AUTODB regions (needed by this test) using those scripts. Hence the explicit mupip create commands below.

setenv ydb_gbldir yottadb.gld
foreach cmdtype ("recover" "rollback")
	echo "# ---------------------------------------------------------------------------------------------------"
	if ("rollback" == "$cmdtype") then
		set replcmd = "-replic=on"
		echo "################ Testing MUPIP JOURNAL ROLLBACK ######################"
		# Create replication instance file (needed by rollback)
		setenv ydb_repl_instance yottadb.repl
		$ydb_dist/mupip replicate -instance -name=INSTA
		set notallmsg = "NOTALLREPLON"
		# Remove database files from prior iteration as Case 1 expects no .dat files to exist.
		# Not doing so will also cause NOTALLREPLON message to not show up in Case 2 of this iteration
		rm -f *.gld *.dat *.mjl*
	else
		set replcmd = ""
		echo "################ Testing MUPIP JOURNAL RECOVER  ######################"
		set notallmsg = "NOTALLJNLEN"
	endif
	echo "# ---------------------------------------------------------------------------------------------------"

	echo "# Case 1 : 2 region GLD where AREG is AutoDB and a.dat does not exist, DEFAULT region is not AutoDB and yottadb.dat exists"
	$echoline
	$ydb_dist/yottadb -run GDE << GDE_EOF
	change -segment DEFAULT -file=yottadb.dat
	add -name a -region=areg
	add -region areg -dyn=aseg -autodb
	add -segment aseg -file=a.dat
GDE_EOF
	$ydb_dist/mupip create
	$ydb_dist/mupip set -journal="enable,on,before" $replcmd -reg "*"
	echo "# Verify only yottadb.dat exists. Not a.dat"
	ls -1 *.dat
	echo "# [mupip journal -$cmdtype -backward *] should $cmdtype DEFAULT region and skip missing AREG region but not complain"
	$ydb_dist/mupip journal -$cmdtype -backward "*"
	echo ""

	echo "# Case 2 : 2 region GLD where AREG is AutoDB and a.dat does exist and is not journaled, DEFAULT region is same as Case 1"
	$echoline
	echo "# Create a.dat by referencing a global in AREG"
	$ydb_dist/yottadb -run %XCMD 'if $data(^a)'   # this creates a.dat
	echo "# Verify both yottadb.dat and a.dat exist"
	ls -1 *.dat
	echo "# [mupip journal -$cmdtype -backward *] should $cmdtype DEFAULT region and skip AREG region with a $notallmsg warning"
	$ydb_dist/mupip journal -$cmdtype -backward "*"
	echo ""

	echo "# Case 3 : 2 region GLD where AREG is AutoDB and a.dat does exist and has before image journaling on, DEFAULT region is same as Case 1"
	$echoline
	$ydb_dist/mupip set -journal="enable,on,before" $replcmd -reg AREG
	echo "# Verify both yottadb.dat and a.dat exist"
	ls -1 *.dat
	echo "# [mupip journal -$cmdtype -backward *] should $cmdtype DEFAULT and AREG regions with no warning/error messages"
	$ydb_dist/mupip journal -$cmdtype -backward "*"
	echo ""

	echo "# Case 4 : 2 region GLD where AREG and DEFAULT are AutoDB and a.dat and yottadb.dat both do not exist"
	$echoline
	echo "# Change DEFAULT region to AUTODB in gld"
	$ydb_dist/yottadb -run GDE "change -region DEFAULT -autodb"
	echo "# Remove a.dat and yottadb.dat"
	rm -f a.dat yottadb.dat
	echo "# [mupip journal -$cmdtype -backward *] should issue NOREGION error because none of regions have an existing db file"
	$ydb_dist/mupip journal -$cmdtype -backward "*"
	echo ""

	echo "# Case 5 : 2 region GLD where 2 regions are AutoDB and db file for both regions do exist (but don't have journaling on)"
	$echoline
	$ydb_dist/yottadb -run %XCMD 'set x=$data(^a),y=$data(^x)'	# this recreates a.dat and yottadb.dat
	echo "# Verify both yottadb.dat and a.dat exist"
	ls -1 *.dat
	echo "# [mupip journal -$cmdtype -backward *] should issue $notallmsg and MUNOACTION errors because no region has journaling on"
	$ydb_dist/mupip journal -$cmdtype -backward "*"
end
