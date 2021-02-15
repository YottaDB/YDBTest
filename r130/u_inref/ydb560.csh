#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that MUPIP STOP (SIG-15) and SIG-4 terminates an M program running an indefinite FOR loop"
echo
echo "# Create simple test M programs test1.m, test2.m and test3.m"
# Note, these 3 test programs are purposely testing fast tight loops. Since they only run for a short time
# before being killed by signal (max one second but generally less), these should not cause a problem. Note
# we put '\t' at the beginning of all strings but most importantly, at the front of the createiamrunning
# string because if it is only a space, command substitution loses that preceding space then writing the
# line in column 1 which doesn't work.
set createiamrunning = '\tset running="iamalive.txt" open running:new use running write $job,! close running'
echo $createiamrunning         >& test1.m
echo '\tfor  quit:$data(^pid)' >> test1.m
echo $createiamrunning         >& test2.m
echo '\tfor  set x=1'          >> test2.m
echo $createiamrunning         >& test3.m
echo '\tfor i=1:1  set y=2'    >> test3.m

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps

foreach sig (15 4)
	foreach file (test*.m)
		echo "# Running : [yottadb -run $file:r] in the background"
		rm -f iamalive.txt # Remove process alive file flag
		($ydb_dist/yottadb -run $file:r < /dev/null > $file.$sig.out & ; echo $! >&! $file.$sig.pid) >& $file.$sig.err
		echo "# Sleep until we see iamalive.txt created to indicate process is running"
		$ydb_dist/yottadb -run waitforfilecreate iamalive.txt 60
		set savestatus = $status
		if (0 != $savestatus) then
		    echo "TEST-E-BACKGRNDSTART Back ground process did not start in 60 seconds - waitforfilecreate.csh failed with rc $savestatus"
		    exit $savestatus
		endif
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
