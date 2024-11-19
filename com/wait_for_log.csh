#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Usage:
# $gtm_tst/com/wait_for_log.csh -log <logfile> -message <message> -duration <duration> [-waitcreation|-nowaitcreation] [-vrb] [-useE] [-count <count>] [-sleepinc <sleepinc>]
# To wait for a message to appear in a given logfile.
# waits upto <duration> seconds for <message> to appear in <logfile>, otherwise returns error
# if duration is 0, that means no wait was requested (i.e. just check the file)
# vrb prints the progress messages
# Note : waitcreation is the default. Not need to explicitly specify it.
set opt_array      = ("\-log"   "\-message" "\-duration" "\-grep" "\-waitcreation" "\-nowaitcreation" "\-vrb" "\-useE" "\-count" "\-sleepinc" "\-any")
set opt_name_array = ("logfile" "mess"      "duration"   "grepit" "waitcreation"   "nowaitcreation"   "vrb"   "useE"   "count"    "sleepinc"  "any"  )

source $gtm_tst/com/getargs.csh "$argv"
set begdate = `date`
if (! $?sleepinc) set sleepinc = 1	# default sleep increment for each loop
if (! $?duration) then
	if ("HOST_LINUX_ARMVXL" == $gtm_test_os_machtype) then
		set duration = 300	# default wait time is 300 secs on ARMV6L.
	else
		set duration = 120	# default wait time is 120 secs.
	endif
endif
set sleeptime = $duration
# Unless -nowaitcreation is explicitly specified, make -waitcreation the default
if !($?nowaitcreation) setenv waitcreation

foreach file ($logfile)
	if ((! $?waitcreation) && (! -e $file)) then
		echo "TEST-E-LOGFILE $file does not exist."
		exit 1
	endif
end

set maskoutput = ">& /dev/null"
if ($?grepit) set maskoutput = ""
set flags =""
if ($?count) set flags="$flags -c"
if ($?useE) set flags="$flags -E"

set todologfiles=($logfile)

while ((($sleeptime > 0) || ($duration == 0)) && ($#todologfiles > 0))
	set retrylogfiles=()
	foreach file ($todologfiles)
		if (-e $file) then
			if (! $?mess) then
				if ($?vrb) then
					echo "GOT THE GO"
					ls -l
				endif
				continue 	# was only waiting for the file to get created
			endif
			if ($?count) then
				@ grepcount = `$grep $flags "$mess" $file`
				@ grepstat = ( $grepcount >= $count )
			else
				eval '@ grepstat = { $grep $flags "${mess:q}" $file } '"$maskoutput"
			endif
			if ($grepstat == 0) then
				if ($?vrb) then
					echo "MESSAGE NOT FOUND"
					date
				endif
				set retrylogfiles=($retrylogfiles $file)
			else if ($?any) then
				# Message found in at least one file. Exit.
				set retrylogfiles=()
				break
			else
				continue
			endif
		else
			if ($?vrb) then
				echo "FILE NOT FOUND YET"
				ls -l
			endif
			set retrylogfiles=($retrylogfiles $file)
		endif
	end
	if (($sleeptime > -$sleepinc) && ($#retrylogfiles > 0)) then
		sleep $sleepinc
		@ sleeptime = $sleeptime - $sleepinc
	endif
	set todologfiles=($retrylogfiles)
end

set enddate = `date`
if ($sleeptime  == 0) then
	set durationmsg = "after $duration secs"
	if (0 == $duration) then
		set durationmsg = ""
	endif
	foreach file ($todologfiles)
		if (! -e $file) then
			echo "TEST-E-NOTFOUND file $file not found $durationmsg"
		else if ($?mess) then
			echo "TEST-E-NOTFOUND message $mess not found in $file $durationmsg"
		endif
	end
	if ($duration) then
		echo "Waited from: $begdate"
		echo "         to: $enddate"
	endif
	exit 1
else
	exit 0
endif
