#! /usr/local/bin/tcsh -f
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
#Usage:
# $gtm_tst/com/wait_for_n_jnl.csh <number of jnl files> <max time to wait> <polling interval>
set opt_array = ("\-lognum" "\-duration" "\-poll")
set opt_name_array = ("jnl_count"	"duration"	"polltime")

source $gtm_tst/com/getargs.csh $argv
set begdate = `date`
if (! $?duration) set duration = 120    # default wait time is 120 secs.
if (! $?polltime) set polltime = 2
set sleeptime = $duration
set mjl_pattern = "*.mjl*"
while ($sleeptime)
	# nonocount prevents expansion of wildcards with no match
	set nonocount ; set mjl_files=($mjl_pattern) ; unset nonocount
	if ("$mjl_files" == "$mjl_pattern")  then
		@ mjl_count = 0
	else
		@ mjl_count = $#mjl_files
	endif
	echo $mjl_count >& mjnl_count.logx
	if ($jnl_count <= $mjl_count) break
	if ($sleeptime > $polltime) then
		sleep $polltime
		@ sleeptime = $sleeptime - $polltime
	else
		sleep 1
		@ sleeptime = $sleeptime - 1
	endif
end
set enddate = `date`
if ($sleeptime  == 0) then
	echo "TEST-E_NOTFOUND Did not find $jnl_count journal files in the directory. The count is: $mjl_count"
	if ($duration) then
		echo "Waited from: $begdate"
		echo "         to: $enddate"
	endif
	exit 1
else
	exit 0
endif
