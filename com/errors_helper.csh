#################################################################
#								#
#	Copyright 2007, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#errors_catch.txt is a list of the expresssions we want to catch
#errors_ignore.txt is a list of the expresssions we want to allow
if (! $?suppr) then
	# "suppr" variable (expected by this script) is not defined. If caller did not define it, set it to empty string.
	# That would let this script run on the "$log_out_file" file without treating it as a suppressed file name.
	set suppr = ""
endif

if (-e $log_out_file) then
	if ("$log_out_file:t" != "$suppr") then
		$grep -f $gtm_tst/com/errors_catch.txt $log_out_file | $grep -v -f $gtm_tst/com/errors_ignore.txt >& /dev/null
		if (! $status) then
			# the seperator requires reference file updates, since there are some expected errors
			#echo "################################################################"
			if (($?test_replic) || ("GT.CM" == $test_gtm_gtcm)) then
				echo ${HOST:r:r:r}:$log_out_file
			else
				echo $log_out_file
			endif
			echo $log_out_file >>&  err_file_names.logx
			if ($suppr == "") then
				# This means the caller is "com/gtm_test_sendresultmail.csh". In this case, include
				# line numbers as it will help provide more context in the failure email.
				set grepflag = "-n"
			else
				# This means the caller is "com/errors.csh". In this case, do not include line numbers
				# as otherwise we would need to update potentially hundreds of reference files which
				# will now have a line number before patterns like "-E-" (which were caught by the test
				# framework from various *.out files etc. and ended up being part of the reference file).
				set grepflag = ""
			endif
			$grep $grepflag -f $gtm_tst/com/errors_catch.txt $log_out_file | $grep -v -f $gtm_tst/com/errors_ignore.txt
		endif
	endif
else
	# The log file we wanted to search for errors does not even exist. Need to make sure the subtest output directory
	# is NOT cleaned up so we have more debug information.
	echo "TEST-E-FILE $log_out_file does not exist"
endif
