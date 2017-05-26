#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Verify that older generation journal files are renamed with the current system time rather than the time of last update.

# Create 3 regions
$gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate.out

# Create (or switch to) newer journal files
$MUPIP set -journal=enable,on,nobefore -reg "*"	>&! jnl_switch1.out

# Do an update in each region
$gtm_exe/mumps -run %XCMD 'set (^a,^b,^c)=1'

# Note down the current time in journal switch timestamp notation
set timebeg = `date +%Y%j%H%M%S`

# Sleep for a second for verification purposes
sleep 1

# Switch to new journal files.
$MUPIP set -journal=enable,on,nobefore -reg "*"	>&! jnl_switch2.out

# Sleep for a second for verification purposes
sleep 1

# Get a post switch reference timestamp
set timeend = `date +%Y%j%H%M%S`

# Get the timestamp portion of the last journal file in each regions
set timearr
foreach jnlfile (a.mjl b.mjl mumps.mjl)
	set prevjnlfile = `$gtm_tst/com/jnl_prevlink.csh -f $jnlfile`
	set timestamp = `echo $prevjnlfile | cut -d_ -f2`
	set timearr = ($timearr[*] $timestamp)
end
echo "$timebeg $timearr $timeend" >&! times.txt

# Now, verify
set prevtime = ""
foreach eachtime ($timearr)
	# First verify that all entries in $timearr are the same
	if (($prevtime != "") && ($prevtime != $eachtime)) then
		echo "FAIL, timestamp portion in all the prev generation journal files should be the same : $prevtime vs $eachtime"
		exit 1
	endif
	# Each timestamp should be strictly between $timebeg and $timeend
	if (!(`expr "$timebeg" "<" "$eachtime"` && `expr "$eachtime" "<" "$timeend"`)) then
		echo "FAIL, $eachtime falls outside the beginning and end timestamps. See times.txt"
		exit 1
	endif
	set prevtime = $eachtime
end
echo "PASS"
$gtm_tst/com/dbcheck.csh	>&! dbcheck.out
