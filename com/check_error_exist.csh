#!/usr/local/bin/tcsh
# Usage: check_error_exist.csh <logfile> <errors>
# This script helps in managing error messages in log files and protects from spurious catches in errors.csh.
# moves the original log file into .logx in order to protect from error checking catching this expected error.
#
# can handle multi-word errors as well, such as:
# check_error_exist.csh logfile.log "error1 multiple words" error2

if (2 > $#) then
	echo "TEST-E-CHECK_ERROR_EXIST wrong arg count"
	exit 1
endif
set logfile = $1
shift
set exit_status = 0
while ("" != "$1")
	set errmessage = "$1"
	if ($?maskarg) then
		set maskarg = "${maskarg}|$errmessage"
	else
		set maskarg = "$errmessage"
	endif
	$grep -E "$errmessage" $logfile >& /dev/null
	set grepstat = $status
	if ($grepstat) then
		echo "-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-"
		echo "-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-"
		echo "TEST-E-ERRORNOTSEEN $errmessage was expected in $logfile"
		if (2 == $grepstat) then
			echo "TEST-E-FILENOTFOUND log file $logfile does not exist"
			exit $grepstat
		endif
		echo "-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-"
		echo "-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-X-"
		set exit_status = 1
	else
		echo "----------"
		echo "Error $errmessage seen in $logfile as expected:"
		$grep -E "$errmessage" $logfile	#this is the safest, since ensures the error message will be printed.
		echo "----------"
	endif
	shift
end
if (! $exit_status) then
	foreach lgfile ($logfile)
		if (-e ${lgfile}x) then
			set time_stamp = ""
			while (-e ${lgfile}x${time_stamp})
				set time_stamp = "_"`date +%Y%m%d_%H%M%S`
			end
			mv ${lgfile}x ${lgfile}x${time_stamp}
		endif
		mv $lgfile ${lgfile}x
		$grep -vE "$maskarg" ${lgfile}x > $lgfile
	end
endif
exit $exit_status
