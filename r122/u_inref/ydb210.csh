#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

#This random value (1 or 0)  will determine if the errors are generated before or after closing
#the terminal that the DB was created in
setenv terminalNoKill `$gtm_tst/com/genrandnumbers.csh`

setenv src_srvr_stdin_is_terminal 1 # Needed by SRC.csh to ensure source server has terminal as stdin/stdout/stderr (to test #210)

#This will supress the ocassional %YDB-I-SHMREMOVED that is output when changing STDNULLCOLL settings
unsetenv gtm_db_counter_sem_incr

echo "RANDOM SETTING: "
if ($terminalNoKill == 1) then
	echo '# Tests will be run within the DBs original terminal'
else
	echo '# Tests will be run after closing the DBs original terminal'
endif
echo ''

#Run each error test and move their files to their respective subdirectories
foreach testDir ("NULLCOLLtest" "REPLOFFJNLONtest" "REPLINSTNOHISTtest" "SECNOTSUPPLEMENTARYtest")
	# Used by runcmd.exp
	setenv errorTest "$testDir"".csh"
	# Used by $errorTest to store output
	setenv outputFile "$testDir"".logx"

	echo "RUNNING $testDir.csh IN A NEW TERMINAL"
	echo "----------------------------------------------------------"
	set cmd='echo "Running: $errorTest"; '
	set cmd="$cmd"'$errorTest; '

	(expect -d $gtm_tst/com/runcmd.exp "$cmd" > expect.out) >& expect.dbg

	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status"
		echo "		      ydb210.exp calling $errorTest"
	endif
	perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out

	# cat $outputFile to record it in ydb210.log
	cat $outputFile

	# Create $testDir and move files there
	mkdir $testDir

	#Rename SRC log files to logx files to avoid redundant error checking by test framework
	foreach file (`ls`)

		if($file =~ "SRC_*.log") then
			mv $file ./$file"x"
		endif
	end

	#Move all of this error tests respective files to $testDir
	foreach file (`ls`)
		#directories and the main log remain in the top directory
		if ( !( -d $file) && !($file == "ydb210.log") && !($file == "start_time_syslog.txt") ) then
			mv ./$file $testDir/
		endif
	end
end
