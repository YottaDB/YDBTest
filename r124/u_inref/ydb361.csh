#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that Receiver Server does not issue REPLINSTNOHIST error on restart after first A->P connection"
echo ""

echo "# Set replication type to be A->P"
setenv test_replic_suppl_type 1		# A->P

echo "# Create database file"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo '# Wait for "Received REPL_WILL_RESTART_WITH_INFO message" to show up in Receiver Server log'
setenv start_time `cat start_time`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log -message 'Received REPL_WILL_RESTART_WITH_INFO message' -duration 300"

echo '# Now shut down Receiver Server to try shut it before "New History Content" shows up in Receiver Server log'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"

echo "# Restart Receiver Server"
sleep 1	# To avoid start_time and start2_time from being identical (second granularity)
setenv start2_time `date +%H_%M_%S`
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno $start2_time < /dev/null "">&!"" $SEC_SIDE/RCVR_${start2_time}.out"

echo "# Do dbcheck.csh"
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif
