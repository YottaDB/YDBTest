#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# portno_acquire.csh -- returns the next available portno to use (to be sourced)
#
# --- in case this script is not called from testsuite ---
source $gtm_tst/com/set_specific.csh
set hostn = $HOST:r:r:r
# --- go find the port ---
# A different start number of different servers, to minimize cross connection with left over source servers of multi-host test <portno_conflict>
# gtmtest user's upper limit will be below 36000 until server #77. So its okay to start with 36000 for non-gtmtest user.
# If the gtmtest range increase later, revisit the logic below
# Do not use port numbers 49152 to 65535 as it is the range of ephemeral ports configured on our linux machines
# Check discussion about "ephemeral ports" and src server using port reserved for rcvr server in <portno_conflict>
set port_upperlimit = "49000"
if ("gtmtest" == "$user") then
	set port_start = `expr 16384 + $gtm_test_port_range \* 512`
	set port_max = `expr $port_start + 512`
else
	set port_start = `expr 36000 + $gtm_test_port_range \* 128`
	set port_max = `expr $port_start + 128`
endif
set portno = `echo "" | $tst_awk '{srand () ; print int(rand()*10) + '$port_start'}'`
# Set increment to a random number between 1 and 20
set increment = 1
if !($?test_subtest_name) then
	# There is a chance that this is sourced outside a subtest
	set test_subtest_name = "NOSUBTEST"
endif
set logfile=port_${testname}.txt_${test_subtest_name}
set nstat = 0
echo "###### Acquire Port ######"			 > $logfile
while ( ($nstat == 0) && ($portno < $port_upperlimit ) )
        @ portno = $portno + $increment
	echo `date` "# test $portno..."			>> $logfile
	set port_reservation_file = /tmp/test_${portno}.txt
	if (-e $port_reservation_file) then
		echo `date` "# The port reservation file for $portno already exists"	>> $logfile
		if ($?second_round) then
			# If it is a second attempt, add debug information about who holds the port reservation file
			cat $port_reservation_file					>>& $logfile
		endif
		if ( !($?second_round) && ($portno >= $port_max) ) then
			echo `date` "# An attempt from $port_start to $port_max failed" 			>> $logfile
			echo `date` "# Trying again from $port_start and will go beyond $port_max if required"	>> $logfile
			@ portno = $port_start
			set second_round = 1
		endif
		continue
	endif
	echo "$$ $tst_working_dir $test_subtest_name" >>! $port_reservation_file
	$gtm_tst/com/is_port_in_use.csh $portno $logfile
	set nstat = $status
	if (0 == $nstat) then  ## port is in use
		# Since there will be processes from multiple machines which will use the
		# current machine as a remote host, there can be cases where two or more processes can find the port file to be non existent.
		# One of them will create the file, choose the port and start the receiver/source processes.
		# The other one will see the port in use in the netstat and delete the file without checking if the current process grabbed it.
		# Thus the reservation file is deleted though the port is being used.
		# For a future attempt to grab a port, this port can be shown as not in use incorrectly.
		# This is possible since there is a gap between choosing a port and actually starting primary and secondary processes on it.
		# Also during the course of lots of tests replication start and stop will happen,
		# so there is a good chance of a port being shown as unused incorrectly. Hence introduce the below check
		# Regarding $head bypass : most scripts which use MSR.. expect to just keep going in most cases even if there is
		# an error, so we can't use $head which can fail.
		head -n 1 $port_reservation_file |& $grep "^$$ $tst_working_dir" > /dev/null	# BYPASSOK $head
		if !($status) then
			rm $port_reservation_file
		else
			echo `date` "# Someone else got the port file $port_reservation_file, Not deleting the file" >> $logfile
		endif
		echo `date` "# $portno is in use..." >> $logfile
	else
		# unused port, check if it was me who grabbed the reservation file
		head -n 1 $port_reservation_file |& $grep "^$$ $tst_working_dir" > /dev/null	# BYPASSOK $head
		if ($status) then
			#oops, it was someone else who got it first
			set nstat = 0
			echo `date` "# $portno oops, someone else got it. Let it go..." >> $logfile
		endif
	endif
end
if ($portno >= $port_upperlimit) then
	echo `date` "# Will not try beyond $port_upperlimit. Exiting now."		>> $logfile
	echo -1
	# copy the debugging information to a central repository
	cat $logfile >>&! $gtm_test_debuglogs_dir/${testname}_${test_subtest_name}_port.txt
	exit 1
endif
echo `date` "# picked $portno @ $hostn" >> $logfile
# -- pass it out through an evnironment variable
setenv portno $portno
# add logic for multihost scenario. # save the original working_dir name
setenv save_working_dir $tst_working_dir
if !(-d $tst_working_dir) then
	setenv tst_working_dir `pwd`
endif
(echo "PORTNO chosen is: $portno"; date ; $netstat) >>& $tst_working_dir/netstat_portno_acquire.out
echo "$port_reservation_file" >&! $tst_working_dir/portno_${portno}.txt
if ($tst_org_host:r:r:r:r != $hostn) then
	$rcp $tst_working_dir/portno_${portno}.txt "$tst_org_host:r:r:r:r":$save_working_dir/portno_${portno}.txt_$hostn
endif

# copy the debugging information to a central repository
cat $logfile >>&! $gtm_test_debuglogs_dir/${testname}_${test_subtest_name}_port.txt

echo $portno
