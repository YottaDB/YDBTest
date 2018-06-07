#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

## ## multisite_replic/max_connections			###3###Kishore
cat << EOF
##             INST1
##             |
## -------------------------------	... ---------
## |      |     |      ...  |		...  |      |
## v      v     v      ...  v		...  v      v
## INST2  INST3 INST4  ...  INST17	...  INST19 INST20
##                          |		     (at a different time)
## 		            v
## 		            INST18
EOF
## - $MULTISITE_REPLIC_PREPARE 20
## - Start 16 receiver servers, all connected to INST1:
##   START INST1 INST2 RP
##   START INST1 INST3 RP
##   START INST1 INST4 RP
##   ...
##   START INST1 INST17 RP

# When this test runs on 1-CPU systems, which are usually low on system memory too, in multi-host mode or single-host mode,
# use 1MB receivepool and jnlpool (the minimum value) and cut down the number of global buffers to 64. This is to reduce
# the chances of the test taking a long time to run (we have seen it take 15 hours on an armv6l box) due to a memory crunch.
setenv gtm_test_msr_smallenvironment
set global_buffers = ""
if ($gtm_test_singlecpu) then
	setenv tst_buffsize  1048576
	set  global_buffers = "-global_buffers=64"
endif
$MULTISITE_REPLIC_PREPARE 20
# SSL/TLS support in the framework allows only for INSTANCE1 - INSTANCE16. INSTANCE17 is higher than that. So, set the below env.
# variable to allow to fallback to plaintext without issuing an error whenever possible.
setenv gtm_test_plaintext_fallback
# To avoid trivial diff regarding SSL renegotiations showing up in the log files, disable SSL renegotiation.
setenv gtm_test_tls_renegotiate 0
$gtm_tst/com/dbcreate.csh mumps $global_buffers >&! msr_dbcreate.out
foreach i (2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17)
	$MSR START INST1 INST$i RP
end

# if there is a system error such as SYSTEM-E-ENO12 or SYSTEM-E-ENO28 indicating a space issue then exit
if (`$grep -c SYSTEM-E-ENO max_connections.log`) then
	echo ""
	echo 'Exiting max_connections early due to space problem'
	echo ""
	$gtm_tst/com/dbcheck.csh
	exit 1
endif

cat << EOF
## - Try starting the 17th receiver connected to INST1 - should error out nicely.
##   START INST1 INST18 RP
##   	--> We expect a SRCSRVTOOMANY error.
## - Start a receiver server, INST18, connected to INST17.
EOF
##   START INST17 INST18 PP

$MSR STARTRCV INST1 INST18 RP
$MSR STARTSRC INST1 INST18 RP
get_msrtime
$msr_err_chk $gtm_test_msr_DBDIR1/START_$time_msr.out SRCSRVTOOMANY REPLINSTSECNONE
if ($status) then
	# For whatever reason if the source did not exit with SRCSRVTOOMANY shut it down to avoid a lingering source server
	$MSR STOPSRC INST1 INST18
endif
$MSR STOPRCV INST1 INST18
$MSR START INST17 INST18 PP

## - Make some updates on INST1 (imptp.csh for 30 seconds)
## - Disconnect INST2 and INST3
##   STOP INST1 INST2
##   STOP INST1 INST3

setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 1
$MSR RUN INST1 '$gtm_tst/com/imptp.csh >>&! imptp.out'
sleep 10
$MSR RUN INST1 '$gtm_tst/com/endtp.csh >>&! imptp.out'
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3

## - Make some simple updates on INST1
##   SYNC ALL_LINKS
## - Check the backlog
cat << EOF
##   for x (all instances 2 to 17)
## 	  RUN INST1 '\$MUPIP replic -source -showbacklog -instsecondary=x'
## 	--> This should report:
## 	    - 0 for the active instances (INST4 through INST17),
## 	    - SRCSRVNOTEXIST for INST2 and INST3
##   Also check the backlog for all instances with one command:
EOF
##   RUN INST1 '$MUPIP replic -source -showbacklog'
##   	--> This should report the backlog information for all servers.

$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 2"
$MSR SYNC ALL_LINKS
foreach i (2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17)
	$MSR RUN INST1 'set msr_dont_chk_stat; $MUPIP replicate -source -showbacklog -instsecondary=INSTANCE'$i' >&! showbacklog_INST'$i'.out'
	if (3 < $i) then
		$grep -v "sequence number of last transaction" showbacklog_INST$i.out
		# we expect errors in INSTANCE2 and 3
	endif
end
$msr_err_chk showbacklog_INST2.out SRCSRVNOTEXIST
$msr_err_chk showbacklog_INST3.out SRCSRVNOTEXIST

$MSR RUN INST1 '$MUPIP replicate -source -showbacklog' >&! showbacklog_all_1.out
$grep -i backlog showbacklog_all_1.out

## - Connect INST19 and INST20 to INST1
##   START INST1 INST19 PP
##   START INST1 INST20 PP
## - Disconnect INST4
##   STOP INST1 INST4
## - Deactivate INST5
##   RUN SRC=INST1 RCV=INST5 '$MUPIP replic -source -deactivate -rootprimary -instsecondary=__RCV_INSTNAME__'
##   	--> This should succeed.
##   CHECKHEALTH INST1 INST5
##   	--> Verify source server is alive and in PASSIVE mode (checkhealth will report active/passive information now).

$MSR START INST1 INST19 RP
$MSR START INST1 INST20 RP

# if there is a system error such as SYSTEM-E-ENO12 or SYSTEM-E-ENO28 indicating a space issue then exit
if (`$grep -c SYSTEM-E-ENO max_connections.log`) then
	echo ""
	echo 'Exiting max_connections early due to space problem'
	echo ""
	$gtm_tst/com/dbcheck.csh
	exit 1
endif

$MSR STOP INST1 INST4
$MSR RUN SRC=INST1 RCV=INST5 "$MUPIP replicate -source -deactivate -rootprimary -instsecondary=__RCV_INSTNAME__"
$MSR REFRESHLINK INST1 INST5
$MSR CHECKHEALTH INST1 INST5 SRC
get_msrtime
# limit output to just check server alive in PASSIVE mode
$grep PASSIVE checkhealth_${time_msr}.out

cat << EOF
## - Make some simple updates on INST1
## - SYNC ALL_LINKS # to make the output of the next step deterministic
## - Check backlog for all instances, for INST2 and INST3, we expect a REPLINSTSECNONE error because their slots would be
##   reused for INST19 and INST20.
##   RUN INST1 '\$MUPIP replic -source -showbacklog'	# for all active connections
##   	--> This should succeed with with output for the active connections (INST6, 7,... 17, 19, 20)
##   for x (all instances 2 to 20 (skip 18))
## 	  RUN INST1 '\$MUPIP replic -source -showbacklog -instsecondary=x'
## 	--> This should report:
## 	    - 0 for the active instances (INST6 through INST20),
## 	    - REPLINSTSECNONE error for INST2 and INST3 (since their slots would be reused)
## 	    - "WARNING - Source Server is in passive mode, transactions are not being replicated" -- for the other deactivated and stopped instances (INST4, INST5)
EOF

$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 10"
$MSR SYNC ALL_LINKS
#The next two -showbacklog commands are supposed to run in INST1. Let us not use $MSR RUN INST1, since
#	a) we know we are in INST1 now
#	b) we expect 3 of the commands to fail. why worry about greping it later. Anyway the command prints it out directly
#	c) 20 MSR RUNs are an unnecessary overhead
echo ""
echo "executing mupip replic -source -showbacklog to see the backlog information"
echo ""
$MUPIP replicate -source -showbacklog >&! showbacklog_all_2.out
$grep -i backlog showbacklog_all_2.out
echo ""
echo "Doing the same in a loop for all instances 2 to 20 (skip 18) with -instsecondary option"
echo ""
foreach i (2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 19 20)
	$MUPIP replicate -source -showbacklog -instsecondary=INSTANCE$i >&! showbacklog_instsecondary_INSTANCE$i.out
	if (4 < $i) then
		$grep -v 'sequence number' showbacklog_instsecondary_INSTANCE$i.out
		# We expect errors in INSTANCE2,3 and 4.
	endif
end
$msr_err_chk showbacklog_instsecondary_INSTANCE2.out REPLINSTSECNONE
$msr_err_chk showbacklog_instsecondary_INSTANCE3.out REPLINSTSECNONE
$msr_err_chk showbacklog_instsecondary_INSTANCE4.out SRCSRVNOTEXIST

## - Test the undocumented new command:
##   MUPIP replic -source -jnlpool -show		>& dumppool_nodetail.out
##   MUPIP replic -source -jnlpool -show -detail	>& dumppool_detail.out
##   Forward the output of both commands into log files, and compare against a saved version (to keep reference file
##   easier to follow).

$MUPIP replicate -source -jnlpool -show >& dumppool_nodetail.outx
$MUPIP replicate -source -jnlpool -show -detail 	>& dumppool_detail.outx
$tst_awk -f $gtm_tst/$tst/u_inref/dumppool_filter.awk dumppool_nodetail.outx > dumppool_nodetail.out
$tst_awk -f $gtm_tst/$tst/u_inref/dumppool_filter.awk dumppool_detail.outx > dumppool_detail.out
diff $gtm_tst/$tst/outref/dumppool_nodetail.out dumppool_nodetail.out
diff $gtm_tst/$tst/outref/dumppool_detail.out dumppool_detail.out

## - Test all source server commands that require -instsecondary qualifier. Let's re-use a script we had written for
##   another test: $gtm_tst/$tst/u_inref/replic_source_commands.csh
##   $gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST3 ""-instsecondary=$gtm_test_msr_INSTNAME[3]""
##   	--> We expect a REPLINSTSECNONE from all of them.
## - shutdown all active links on INST1 using one command:
##   $MUPIP replic -source -shutdown -timeout=0 >& shutdown.log
##   	--> We expect all source servers to be shutdown at the end of this command since no -instsecondary was
## 	    specified. Check that the correct number of "Initiating SHUTDOWN" messages are seen in the log, and that
## 	    all those processes do dissappear.
## - Make sure all active connections have the same data at the end:
##   dbcheck -extract INST1 INST6 INST7 ... INST20
##

echo "############# Expect YDB-E-REPLINSTSECNONE in the next section of the script #############"
echo ""
$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST3 ""-instsecondary=$gtm_test_msr_INSTNAME3"" REPLINSTSECNONE needrestart
echo ""
echo "#############        usage of replic_source_commands.csh done       #############"

$MUPIP replic -source -shutdown -timeout=0 >& shutdown.log
set srv_count = `$grep "Initiating SHUTDOWN" shutdown.log | wc -l`
echo "The number of servers that the above shutdown command shut : $srv_count"
if ( 15 != $srv_count) then
	echo "TEST-E-SHUTDOWN. 15 servers were expected to be shutdown. Only $srv_count were shut."
endif
echo ""
echo "Expect NOJNLPOOL error next. It means the shutdown command indeed shut ALL the servers"
$MUPIP replic -source -checkhealth >&! checkhealth.out
$msr_err_chk checkhealth.out YDB-E-NOJNLPOOL
foreach i (5 6 7 8 9 10 11 12 13 14 15 16 17 19 20)
	$MSR REFRESHLINK INST1 INST$i
end
# The above REFRESHLINK is to update the MSR framework about the shutdown.
$gtm_tst/com/dbcheck.csh -extract INST1 INST6 INST7 INST8 INST9 INST10 INST11 INST12 INST13 INST14 INST15 INST16 INST17 INST18 INST19 INST20

