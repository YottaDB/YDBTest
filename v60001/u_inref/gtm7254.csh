#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

# HP-UX scheduler is seen to be not as fair as the other so we have lower expectation
# MREP <unfair_lock_gtm7254>
if ($HOSTOS == "HP-UX") then
    set thr = 50
else if ($HOSTOS == "SunOS") then
    set thr = 75
else
    set thr = 95
endif

$MUPIP set -file mumps.dat -flush_time=5:0:0 # Prevent interruptions from flush timers

$gtm_exe/mumps -run %XCMD "do gtm7254^gtm7254($thr)"

# Check if .mjo files have 100 'o's (i.e. all attempted locks were eventually successfully obtained)
foreach file (*procout.mjo*)
	if (`$grep -E -q 'o{100}' $file`) then
		echo "$file does not have proper /o{100}/ output"
		set fail
	endif
end
if !($?fail) echo "TEST-I-PASS All mjo files have proper output"

$gtm_tst/com/dbcheck.csh
