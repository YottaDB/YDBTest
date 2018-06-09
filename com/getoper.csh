#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017,2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
################################################################################################################
# This script captures the syslog information for a given test in its test directory.
# It will just call syslog.awk and since this can be called even from remote hosts to log their syslog information
# we decided to keep this wrapper executing the awk.
################################################################################################################
if ( 1 > $# ) then
	echo "TEST-E-SYSLOGINFO error. cannot proceed to capture syslog information,pls. provide the following"
	echo "timeframe - beginning and end in format like Nov 16 10:11:39"
	echo "output file to write the log is optional.If not provided it writes to syslog.txt in the current dir"
	echo "syslog_file to search is optional.If not provided it takes the default syslog on that host"
	echo "message (optional): If provided, the script will wait for a maximum duration of 300 seconds "
	echo "(900 seconds on ARM Linux) for the message to appear in the syslog"
	echo "Sample Usage:"
	echo "$gtm_tst/com/getoper.csh time_before time_after <output_file> <syslog_file> <message> <count>"
	exit 1
endif
if (5 <= $# && "" != "$5") set message = "$5"

if (6 == $#) then
	set count = $6
else
	set count = 1
	set message = `$ydb_dist/mumps -run ^%XCMD 'write $$^%RANDSTR(32)'`
endif

if ( "" == $3 ) then
	set output_file=syslog.txt
else
	set output_file=$3
endif
# identify the syslog file for that host
set syslog_host=$HOST:ar
if ( "" == $4 ) then
	set syslog_file=`$tst_awk '$1 == "'${syslog_host}'" {print $8}' $gtm_test_serverconf_file`
else
	set no_prev_search
	set syslog_file=$4
endif

if (-X journalctl) then
	set datefmt = "%Y-%m-%d %H:%M:%S"
	set has_journalctl
	set no_prev_search
	# Convert date to journalctl compatible format
	set time_before = `date -d "$1" +"$datefmt"`
	if ("$2" == "") then
		set time_after = ""
	else
		# Advance by a second because journalctl does not include the messages encountered at --until timestamp
		# On top of a second advance one more because we have seen one second delay between syslog message's timstamp and systemd journal wallclock timestamp
		# Total of +2 seconds
		@ time_after = `date +"%s" -d "$2"` + 2
		set time_after = `date -d "@${time_after}" +"$datefmt"`
	endif
	if ("" == "$time_after") then
		# going the alias route, since setting a variable with "" value and passing it to journalctl command like ... --since="$time_before" "$until_time" does not work
		# and not enclosing $until_time within double quotes (like the above) does not work if it has a valid time
		alias getlog_journalctl 'journalctl -a --no-pager --since="'$time_before'"'
	else
		# Pass the --until parameter only if the end time is specified.
		alias getlog_journalctl 'journalctl -a --no-pager --since="'$time_before'" --until="'$time_after'"'
	endif
else
	set datefmt = "%b %e %H:%M:%S"
	set time_before = "$1"
	set time_after = "$2"
endif

if ("" == "$time_after") then
	set a = '$ZSYSLOG("'$message'")'
	$ydb_dist/mumps -run ^%XCMD "set y=$a"
	set sleepinc = 5
	set found = 0
	set end_time = "$time_after"
	set nowtime = `date +%s`
	set starttime = $nowtime
	if ("HOST_LINUX_ARMVXL" != $gtm_test_os_machtype) then
		set maxwait = 300
	else
		# Linux on ARM has been seen to be slow (IO, CPU etc.) so give it more time for syslog message to show up
		set maxwait = 900
	endif
	@ timeout = $starttime + $maxwait
	while ($nowtime <= $timeout)
		set nowtime = `date +%s`
		set end_time = `date +"$datefmt"`
		if (-f $output_file) \rm -f $output_file
		## START - PREVIOUS GENERATION SYSLOG SEARCH
		if (! ($?no_prev_search)) then
			set search_prev_syslog = `$tst_awk -f $gtm_tst/com/get_time.awk -v before="$time_before" --source '{first_entry = get_time($1" "$2" "$3); search_start_time = get_time(before); print (search_start_time <= first_entry); exit}' $syslog_file`
			if ($search_prev_syslog) then
				if (! ($?prev_syslog_path)) then
					set prev_syslog_path = (`ls -t ${syslog_file}?*`)
					set prev_syslog_path = $prev_syslog_path[1]
					set gzip_comm = "cat"
					if ("gz" == ${prev_syslog_path:e}) set gzip_comm = "gzip -cd"
				endif
				# If the path isn't readable, skip reading for now. The script's default timeout controls how long this will wait
				if (-r $prev_syslog_path) then
					$gzip_comm $prev_syslog_path | $tst_awk -f $gtm_tst/com/get_time.awk -f $gtm_tst/com/syslog.awk -v before="$time_before" -v after="$end_time" >&! $output_file
				endif
			endif
		endif
		## END - PREVIOUS GENERATION SYSLOG SEARCH
		if ($?has_journalctl) then
			getlog_journalctl >>&! $output_file
		else
			$tst_awk -f $gtm_tst/com/get_time.awk -f $gtm_tst/com/syslog.awk -v before="$time_before" -v after="$end_time" $syslog_file >>&! $output_file
		endif
		$grep -E "$message" $output_file >>&! wait_for_syslog_message.outx
		if (! $status) then
			if ((1 == $count) || ($count <= `$grep -E -c "$message" $output_file`)) then
				set found = 1
				break
			 endif
		else
			echo "`date +'$datefmt'` : '$message' not found in syslog at end_time = $end_time"	>>&! wait_for_syslog_message.outx
		endif
		sleep $sleepinc
	end
	if (1 == $found) then
		exit 0
	else
		echo "GETOPER-E-NOTFOUND : `date +'$datefmt'` '$message' NOT found in syslog between $time_before and $end_time after waiting for $maxwait seconds."
		echo "TEST-W-GGSERVERS, $gtm_test_serverconf_file indicates syslog file is $syslog_file. Check if this is correct for this system."
		exit 1
	endif
else
	## START - PREVIOUS GENERATION SYSLOG SEARCH
	if (! ($?no_prev_search)) then
		set search_prev_syslog = `$tst_awk -f $gtm_tst/com/get_time.awk -v before="$time_before" --source '{first_entry = get_time($1" "$2" "$3); search_start_time = get_time(before); print (search_start_time <= first_entry); exit}' $syslog_file`
		if ($search_prev_syslog) then
			if (! ($?prev_syslog_path)) then
				set prev_syslog_path = (`ls -t ${syslog_file}?*`)
				set prev_syslog_path = $prev_syslog_path[1]
				set gzip_comm = "cat"
				if ("gz" == ${prev_syslog_path:e}) set gzip_comm = "gzip -cd"
			endif
			if (-r $prev_syslog_path) then
				$gzip_comm $prev_syslog_path | $tst_awk -f $gtm_tst/com/get_time.awk -f $gtm_tst/com/syslog.awk -v before="$time_before" -v after="$time_after" >&! $output_file
			else
				echo "GETOPER-W-NOREAD : $prev_syslog_path was unreadable - possible file rotation conflict"
				ls -l $prev_syslog_path
			endif
		endif
	endif
	## END - PREVIOUS GENERATION SYSLOG SEARCH
	if ($?has_journalctl) then
		getlog_journalctl >>&! $output_file
	else
		$tst_awk -f $gtm_tst/com/get_time.awk -f $gtm_tst/com/syslog.awk -v before="$time_before" -v after="$time_after" $syslog_file >>&! $output_file
	endif
endif
