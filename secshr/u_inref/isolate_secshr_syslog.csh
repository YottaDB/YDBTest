#!/usr/local/bin/tcsh -f
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

# Helper script for the secshr/basic test to print the contents of the specified syslog file,
# excluding any messages specific to autorelink stuff.

@ autorelink_is_enabled = 0
if ($?gtm_test_autorelink_support) then
	if ($?gtm_test_autorelink_always) then
		@ autorelink_is_enabled = $gtm_test_autorelink_always
	endif

	if (! $autorelink_is_enabled) then
		echo "$gtmroutines" | $grep -q "*"
		if (! $status) then
			@ autorelink_is_enabled = 1
		endif
	endif
endif

if ($autorelink_is_enabled) then
	set shmids = `$grep shmid: rctldump$1.log | $tst_awk -F'(shmid: |  shmlen)' '{print $2}'`
	set shmids_grep = "("
	@ count = $#shmids
	@ i = 1
	while ($i <= $count)
		@ shmid = $shmids[$i]
		if ($i != 1) set shmids_grep = "${shmids_grep}|"
		set shmids_grep = "${shmids_grep}${shmid}"
		@ i++
	end
	set shmids_grep = "${shmids_grep})"
else
	set shmids_grep = "something improbable"
endif

if ("SunOS" == $HOSTOS) then
    $grep "\[client pid $1\]" $2 | $grep -vE "\($shmids_grep\)" | sed 's/\[ID [0-9]* user\.info\] //g'
else if ("AIX" == $HOSTOS) then
    $grep "\[client pid $1\]" $2 | $grep -vE "\($shmids_grep\)" | sed 's/user\:info //g'
else
    $grep "\[client pid $1\]" $2 | $grep -vE "\($shmids_grep\)"
endif
