#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2003, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Continuously run this (in a loop) for 90 seconds
set runtime = 0
set format="%Y %m %d %H %M %S %Z"
set time1=`date +"$format"`
set counta = 1
date
while ($runtime < $c002134_runtime)
	echo "count : $counta ; time : `date`"
	mumps -run c002134
	@ counta = $counta + 1
	set time2=`date +"$format"`
	echo $time1 " " $time2 >& time_diff.txt
	@ runtime =`$tst_awk -f $gtm_tst/com/diff_time.awk time_diff.txt`
end
date >&! done.$1
