#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# $1 - directory to check
# $2 - log file to create
# $3 - Host name
set dir_name = $1
set log_file = $2
set host_name = $3
set ipcsfile = $4
$lsof |& $grep "$dir_name" |& $tst_awk '{if ($1 ~ /dse|mumps|mupip|gdb|dbx|gtcm/) print}' >&! $log_file
if !(-z $log_file) then
	set lsof_err = 1
	echo "SUBTEST-E-LSOF some processes are still accessing files in $dir_name"
	echo "Check $log_file and $tst_general_dir/subtest.pslist. The test will exit."
	if (!($?tst_dont_send_mail)) then
		echo "Subtest directory not cleaned. Keep this in context when analyzing failures" >& to_mail.logx
		cat $log_file >>& to_mail.logx
		cat to_mail.logx | mailx -s \
		"SUBTEST-E-LSOF processes are still accessing files in $dir_name. Check at $host_name" $mailing_list
		rm to_mail.logx
	endif
else
	\rm $2
	# If there are no processes running, check if there are any ipcs left over
	$gtm_tst/com/check_ipcs.csh all $ipcsfile
endif
