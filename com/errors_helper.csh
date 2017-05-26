#################################################################
#								#
#	Copyright 2007, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#errors_catch.txt is a list of the expresssions we want to catch
#errors_ignore.txt is a list of the expresssions we want to allow
if (-e $log_out_file) then
	if ("$log_out_file:t" != $suppr) then
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
			$grep -f $gtm_tst/com/errors_catch.txt $log_out_file | $grep -v -f $gtm_tst/com/errors_ignore.txt
		endif
	endif
else
	# The log file we wanted to search for errors does not even exist. Need to make sure the subtest output directory
	# is NOT cleaned up so we have more debug information.
	echo "TEST-E-FILE $log_out_file does not exist"
endif
