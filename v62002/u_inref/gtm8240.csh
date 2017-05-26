#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/bin/local/tcsh -f

# Verfiy that setting $gtm_autorelink_ctlmax changes maximum number of autorelink routines

setenv gtmroutines ".* $gtmroutines"
setenv gtm_linktmpdir `pwd`
set hostn = $HOST:r:r:r

cat <<EOF > maxchange.m
maxchange
    write "# Going "_\$zcmdline,!
    if \$zsigproc(\$job,9)
EOF

if (("liza" != $hostn) && ("inti" != $hostn)) then
	set syslog_start = `date +"%b %e %H:%M:%S"`
	env gtm_autorelink_ctlmax=16000001 $gtm_exe/mumps -run maxchange "above the maximum allowed limit"
	$gtm_tst/com/getoper.csh "$syslog_start" "" syslog1.txt "" ARCTLMAXHIGH

	# This should still set the maximum entires to 16000000
	$MUPIP rctldump . |& $grep "# of routines / max"

	$MUPIP rundown -relinkctl >>& rundown.out
endif

set syslog_start = `date +"%b %e %H:%M:%S"`
env gtm_autorelink_ctlmax=999 $gtm_exe/mumps -run maxchange "below the minimum allowed limit"
$gtm_tst/com/getoper.csh "$syslog_start" "" syslog2.txt "" ARCTLMAXLOW

# This should still set the maximum entires to 1000
$MUPIP rctldump . |& $grep "# of routines / max"

echo "# Running down to set to the default value"
$MUPIP rundown -relinkctl >>& rundown.out

$MUPIP rctldump . |& $grep "# of routines / max"
