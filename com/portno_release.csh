#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# portno_release.csh -- release the used portno
#
# --- in case this script is not called from testsuite ---
source $gtm_tst/com/set_specific.csh

if !($?test_subtest_name) then
	# There is a chance that this is sourced outside a subtest
	set test_subtest_name = "NOSUBTEST"
endif
set release_time = `date +%d_%b_%Y_%H_%M_%S`
set ports_debugfile=$gtm_test_debuglogs_dir/${testname}_${test_subtest_name}_port.txt
set hostn = $HOST:r:r:r
set delete_portnos = ""
set filepath = $PWD
while ("$testname" != "$filepath:t")
	set filepath = $filepath:h
	if ("" == "$filepath") then
		echo "testname:$testname not found in PWD:$PWD - Not running portno_release.csh from a standard directory."
		exit 1
	endif
end
set rmportsfile = $filepath/$test_subtest_name/delete_reserved_portfiles.csh

echo 'echo "###### Release ports ######"' >> $rmportsfile
if ("" != "$1") then
	# If a specific port is asked to be released, do only that and exit
	# For now, this is used to release only the supplementary port.
	if ($?SEC_SIDE) then
		if (-e $SEC_SIDE/portno) then
			set portno = `cat $SEC_SIDE/portno`
			if ("$1" == "$portno") then
				mv $SEC_SIDE/portno  $SEC_SIDE/portno_released_$release_time
			endif
		endif
		if (-e $SEC_SIDE/portno_supp) then
			set portno_supp = `cat $SEC_SIDE/portno_supp`
			if ("$1" == "$portno_supp") then
				mv $SEC_SIDE/portno_supp  $SEC_SIDE/portno_supp_released_$release_time
			endif
		endif
	endif
	# Even if $SEC_SIDE/portno or $SEC_SIDE/portno_supp does not exist (if portno_acquire.csh is called manually by the test), unconditionally remove the port reservation
	set delete_portnos = "$delete_portnos $1"
else
	# Release all ports
	# Release secondary portno
	if ($?SEC_SIDE) then
		if (-e $SEC_SIDE/portno) then
			set portno = `cat $SEC_SIDE/portno`
			mv $SEC_SIDE/portno  $SEC_SIDE/portno_released_$release_time
			set delete_portnos = "$delete_portnos $portno"
		endif
		if (-e $SEC_SIDE/portno_supp) then
			set portno_supp = `cat $SEC_SIDE/portno_supp`
			mv $SEC_SIDE/portno_supp  $SEC_SIDE/portno_supp_released_$release_time
			set delete_portnos = "$delete_portnos $portno_supp"
		endif
	endif
	# Release local portno
	if (-e portno.out) then
		set portno = `cat portno.out`
		mv portno.out portno_released_$release_time.out
		set delete_portnos = "$delete_portnos $portno"
	endif
	# Release GT.CM portno
	if ($?tst_general_dir) then
		if (-e $tst_working_dir/portno.txt) then
			set portno = `cat $tst_working_dir/portno.txt`
			mv $tst_working_dir/portno.txt $tst_working_dir/portno_released_$release_time.txt
			set delete_portnos = "$delete_portnos $portno"
		endif
	endif
	# Another GT.CM portno
	if (-e gtcm_portno.txt) then
		set portno = `cat gtcm_portno.txt`
		mv gtcm_portno.txt gtcm_portno_$release_time.txt
		set delete_portnos = "$delete_portnos $portno"
	endif
endif

echo 'echo "`date` # ports :'$delete_portnos' released @ '$hostn'"' >> $rmportsfile
foreach rmport ($delete_portnos)
	echo "rm -f /tmp/test_${rmport}.txt"	>> $rmportsfile
end
