#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test:
# This is to test activating and deactivating the source servers.
# We need three instances.

# Layout:
# INST1 --> INST2 --> INST3

$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh . 1
$MSR START INST1 INST2 RP
$MSR START INST2 INST3 PP

$echoline
echo "#- Try to activate a source server from INST1 to INST3 (but there is no source server at all)"
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -activate -instsecondary=__RCV_INSTNAME__ -secondary=__RCV_HOST__:1234' >& log1.log
echo "#  	--> We expect a REPLINSTSECNONE error since there is no source server running to INST3."
$gtm_tst/com/check_error_exist.csh log1.log REPLINSTSECNONE
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out REPLINSTSECNONE > /dev/null
	# I don't care about that output, since I already saw my error, but I want to "clean" $msr_execute_last_out
	# so error checking does not report the error I was expecting
echo "log1.log:"; cat log1.log


$echoline
echo "#- Try to de-activate a non-existing passive source server on INST1 (to INST3)"
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_chk_stat; $MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__' >& log2.log
echo "#  	--> We expect a REPLINSTSECNONE error since there is no source server running to INST3."
$gtm_tst/com/check_error_exist.csh log2.log REPLINSTSECNONE
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out REPLINSTSECNONE > /dev/null
echo "log2.log:"; cat log2.log

$echoline
echo "#- deactivate and then activate the source server on INST1"
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -deactivate -instsecondary=__RCV_INSTNAME__' >& log3.log
echo "#   	--> We expect a PRIMARYISROOT error since -propagateprimary will be implicitly assumed"
$gtm_tst/com/check_error_exist.csh log3.log PRIMARYISROOT
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out PRIMARYISROOT > /dev/null
echo "log3.log:"; cat log3.log

echo ""
$MSR RUN SRC=INST1 RCV=INST2 '$MUPIP replic -source -rootprimary -deactivate -instsecondary=__RCV_INSTNAME__' >& log4.log
echo "#  	--> This should succeed. Note this does not make it a secondary, it is still the rootprimary."
echo "log4.log:"; cat log4.log

echo ""
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_chk_stat; $MUPIP replic -source -propagateprimary -activate -instsecondary=__RCV_INSTNAME__ -secondary=__RCV_HOST__:__RCV_PORTNO__' >& log5.log
echo "#  	--> We expect a PRIMARYISROOT error since this is not the propagating primary, but only a deactivated rootprimary."
$gtm_tst/com/check_error_exist.csh log5.log PRIMARYISROOT
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out PRIMARYISROOT > /dev/null
echo "log5.log:"; cat log5.log

echo "some updates on INST1"
$gtm_tst/com/simpleinstanceupdate.csh 10

$echoline
echo "# activate it again:"
setenv time_stamp `date +%H_%M_%S`
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_trace; set echo; $MUPIP replic -source -rootprimary -activate -instsecondary=__RCV_INSTNAME__ -secondary=__RCV_HOST__:__RCV_PORTNO__ -log=$PRI_SIDE/SRC_activated_'${time_stamp}'.log' > log6.log
echo "#  	--> This should succeed."
$MSR CHECKHEALTH INST1 INST2 SRC

$echoline
echo "#- deactivate and then activate the active source server on INST2."
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -propagateprimary -deactivate -instsecondary=__RCV_INSTNAME__ >& log_7.tmp ; cat log_7.tmp'
echo "#  	--> This should succeed."
echo "#  	--> Verify it is in "passive" mode (checkhealth will report active/passive information now)."
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -instsecondary=__RCV_INSTNAME__ -checkhealth >& checkhealth_7.tmp ; cat checkhealth_7.tmp' >& checkhealth_7.log
$grep PASSIVE checkhealth_7.log
if ($status) then
	echo "TEST-E-FAIL source server did not transition to PASSIVE mode!"
endif
echo "some updates on INST1"
$gtm_tst/com/simpleinstanceupdate.csh 10

$echoline
echo "# activate it again:"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_chk_stat; set msr_dont_trace; set echo; $MUPIP replic -source -activate -instsecondary=__RCV_INSTNAME__ -secondary=__RCV_HOST__:__RCV_PORTNO__ >& log8.tmp ; cat log8.tmp' >& log8.log
echo "#  	--> We expect a ACTIVATEFAIL error since -rootprimary will be assumed, and there are more processes attached to the journal pool than only one passive source server."
$gtm_tst/com/check_error_exist.csh log8.log ACTIVATEFAIL
$gtm_tst/com/check_error_exist.csh $msr_execute_last_out ACTIVATEFAIL


$echoline
setenv time_stamp `date +%H_%M_%S`
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_trace; set echo; $MUPIP replic -source -propagateprimary -activate -instsecondary=__RCV_INSTNAME__ -secondary=__RCV_HOST__:__RCV_PORTNO__ -log=$PRI_SIDE/SRC_activated_'${time_stamp}'.log >& log9.tmp ; cat log9.tmp' > log9.log
echo "#  	--> This should succeed."
echo "some updates on INST1:"
$gtm_tst/com/simpleinstanceupdate.csh 10

echo "# Wait for activated source server to send a history record across before attempting dbcheck.csh"
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log SRC_activated_'${time_stamp}'.log -message "New History Content"'

echo "# Now that we are sure INST2 source server is replicating, we are guaranteed the passive to active transition"
echo "# is complete and so we can safely run dbcheck.csh without risk of a RFSYNC-I-PASSIVEMODE error"
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3
#=====================================================================
