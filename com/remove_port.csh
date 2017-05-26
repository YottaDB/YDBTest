#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#################################################################################################################
# This script is to remove the text files in the /tmp directory that are meant to reserve ports for replication
# we will have msr tests called with multisite options that leads to /tmp/test_xxx.txt created on multiple hosts
# so we will get to the correct host and then remove those files
#################################################################################################################
if ( 0 == $#argv ) then
	echo "TEST-E-REMOVE_PORT usage error.Pls. specify the portno to remove"
	echo "source \$gtm_tst/com/remove_port.csh 5678 [instance name]"
	exit 1
endif
if !($?test_subtest_name) then
	# There is a chance that this is sourced outside a subtest
	set test_subtest_name = "NOSUBTEST"
endif
set logfile=$gtm_test_debuglogs_dir/port_${testname}_${test_subtest_name}.txt
if ! (-e $logfile) set logfile = port_${testname}_${test_subtest_name}.txt

set filepath = $PWD
while ("$testname" != "$filepath:t")
	set filepath = $filepath:h
	if ("" == "$filepath") then
		echo "testname:$testname not found in PWD:$PWD - Not running remove_port.csh from a standard directory."
		exit 1
	endif
end
set rmportsfile = $filepath/$test_subtest_name/delete_reserved_portfiles.csh
echo 'echo "###### Release ports ######"' >> $rmportsfile

setenv rm_portfile "test_$1"
set ins_file = $tst_working_dir/msr_instance_config.txt
# determine the shell (host) we need to remove the port reservation file from , this is the safest way
if ( "" == $2 ) then
	set rmt_ins=`$tst_awk '/PORTNO:[ 	]*'$1'$/ {print $1}' $ins_file`
	if ( 1 < $#rmt_ins ) then
		# More than one SRC-RCVR using the same ports.
		# Check if they are different Hosts. If yes, then it is okay to continue
		set rmt_host_list=""
		foreach ins ($rmt_ins)
			set rmt_host=`$tst_awk '/'$ins'	HOST:/ {print $3}' $ins_file`
			echo $rmt_host_list | $grep "$rmt_host" >&! /dev/null
			if !($status) then
				# It means the HOST rmt_host is already in the list of hosts rmt_host_list
				# It is a clash scenario. Error out
				echo "TEST-E-TSSERT portno is clashing. $1 is being used by $rmt_ins"
				echo "Check whether the test is running on multiple hosts"
				echo "After this point onwards test output will be suspectful"
				exit 1
			else
				set rmt_host_list="$rmt_host_list $rmt_host"
			endif
		end
	endif
	set rmt_ins_list="$rmt_ins"
else
	set rmt_ins_list=$2
endif
foreach rmt_ins ($rmt_ins_list)
	if ("" != $rmt_ins) then
		set rmt_host=`$tst_awk '/'$rmt_ins'	HOST:/ {print $3}' $ins_file`
		# value could be anything like ssh or bin/rsh etc. so take out everything
		set rmt_shell=`$tst_awk '/'$rmt_host'	SHELL:/ {gsub(/^.*SHELL:	/,"",$0);print $0}' $ins_file`
	else
		# sometimes there are failed MSR attempts in which case portno wouldn't have found its way inside config file
		# let's make use of sec_shell prepared by msr scripts in such cases.
		set rmt_shell="$sec_shell"
	endif
	echo "$rmt_shell 'rm /tmp/$rm_portfile.txt'"					>>&! $rmportsfile
	echo 'echo "`date` # portno : '$1' released @ '$rmt_shell' (from $HOST:r:r:r)"' >>&! $rmportsfile
end
#
