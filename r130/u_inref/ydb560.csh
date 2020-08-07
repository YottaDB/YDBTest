#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that MUPIP STOP (SIG-15) and SIG-4 terminates an M program running an indefinite FOR loop"

echo "# Create one line test M programs test1.m, test2.m and test3.m"
echo ' for  quit:$data(^pid)' >& test1.m
echo ' for  set x=1'          >& test2.m
echo ' for i=1:1  set y=2'    >& test3.m

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps

foreach sig (15 4)
	foreach file (test*.m)
		echo "# Running : [yottadb -run $file:r] in the background"
		($ydb_dist/yottadb -run $file:r < /dev/null > $file.$sig.out & ; echo $! >&! $file.$sig.pid) >& $file.$sig.err
		echo "# Sleep 1 second to give process some time to start"
		sleep 1
		echo "# Running : [kill -$sig] to backgrounded yottadb process"
		set bgpid = `cat $file.$sig.pid`
		kill -$sig $bgpid
		echo "# Waiting for backgrounded yottadb process to terminate"
		$gtm_tst/com/wait_for_proc_to_die.csh $bgpid
		if (4 == $sig) then
			# Check core file did get generated
			ls -1 core* >& /dev/null
			if (0 != $status) then
				echo " -> Core file expected but not found"
			else
				echo " -> Core file found as expected"
				set corename = `ls -1 core*`
				mv $corename hidden_expected_core_$file.$sig.$corename
			endif
			# Check fatal zshow dump file did get generated
			ls -1 YDB_FATAL_ERROR* >& /dev/null
			if (0 != $status) then
				echo " -> YDB_FATAL_ERROR zshow dump file expected but not found"
			else
				echo " -> YDB_FATAL_ERROR zshow dump file found as expected"
				set fatalfilename = `ls -1 YDB_FATAL_ERROR*`
				mv $fatalfilename hidden_expected_fatalfile_$file.$sig.$fatalfilename
			endif
			set message = "YDB-F-KILLBYSIGUINFO"
		else
			set message = "YDB-F-FORCEDHALT"
		endif
		$gtm_tst/com/check_error_exist.csh $file.$sig.err $message >& /dev/null
		if (0 == $status) then
			echo " -> $message seen in stderr as expected"
		else
			echo " -> $message expected in stderr but not found"
		endif
		mv $file.$sig.errx $file.$sig.outx	# rename as test framework only knows to skip errors in *.outx
		echo ""
	end
end

echo "# Invoke dbcheck"
$gtm_tst/com/dbcheck.csh
