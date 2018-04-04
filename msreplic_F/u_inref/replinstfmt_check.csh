#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
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

set supplarg = "$gtm_test_qdbrundown_parms"
if (2 == "$test_replic_suppl_type") set supplarg = "$supplarg -supplementary"

echo "# Create the replication instance files"
$MSR RUN INST1 "$MUPIP replic -instance_create $supplarg -name=$gtm_test_msr_INSTNAME1"
$MSR RUN INST2 "$MUPIP replic -instance_create $supplarg -name=$gtm_test_msr_INSTNAME2"
$MSR RUN INST3 "$MUPIP replic -instance_create $supplarg -name=$gtm_test_msr_INSTNAME3"

echo "# Get the endian information and the GT.M platform size"
$MSR RUN INST1 'setenv msr_dont_trace ; source $gtm_tst/com/set_gtm_machtype.csh ; echo set gtm_endian1=$gtm_endian ; echo set gtm_platform_size1=$gtm_platform_size' >>&!  endian_gtmplatform.csh
$MSR RUN INST2 'setenv msr_dont_trace ; source $gtm_tst/com/set_gtm_machtype.csh ; echo set gtm_endian2=$gtm_endian ; echo set gtm_platform_size2=$gtm_platform_size' >>&!  endian_gtmplatform.csh
$MSR RUN INST3 'setenv msr_dont_trace ; source $gtm_tst/com/set_gtm_machtype.csh ; echo set gtm_endian3=$gtm_endian ; echo set gtm_platform_size3=$gtm_platform_size' >>&!  endian_gtmplatform.csh

source endian_gtmplatform.csh

echo "# Try cross endian replication instance file testing"
set crossendian_test = 1
if ("$gtm_endian1" != "$gtm_endian2") then
	# Instance1 and Instance2 are opposite endians.
	set endianinst1 = INST1 				; set endianinst2 = INST2
	set e1 = "`echo $gtm_endian1 | sed 's/_ENDIAN//'`" 	; set e2 = "`echo $gtm_endian2 | sed 's/_ENDIAN//'`"
	set p1 = $gtm_platform_size1 				; set p2 = $gtm_platform_size2
else if ("$gtm_endian1" != "$gtm_endian3") then
	# Instance1 and Instance3 are opposite endians.
	set endianinst1 = INST1 				; set endianinst2 = INST3
	set e1 = "`echo $gtm_endian1 | sed 's/_ENDIAN//'`" 	; set e2 = "`echo $gtm_endian3 | sed 's/_ENDIAN//'`"
	set p1 = $gtm_platform_size1 				; set p2 = $gtm_platform_size3
else if ("$gtm_endian2" != "$gtm_endian3") then
	# Instance2 and Instance3 are opposite endians.
	set endianinst1 = INST2 				; set endianinst2 = INST3
	set e1 = "`echo $gtm_endian2 | sed 's/_ENDIAN//'`" 	; set e2 = "`echo $gtm_endian3 | sed 's/_ENDIAN//'`"
	set p1 = $gtm_platform_size2 				; set p2 = $gtm_platform_size3
else
	echo "# None of the instances have a cross-endian combination. The test case will be skipped"
	set crossendian_test = 0
endif

if (1 == $gtm_test_forward_rollback) then
	# If gtm_test_forward_rollback is set to 1, backup_for_mupip_rollback.csh which is called by SRC.csh
	# would not be able to read replication instance file and would throw TEST-E-ERROR
	set rollback_err = "E-REPLINSTNAME"
else
	set rollback_err = ""
endif
set error_status = 0
if ($crossendian_test) then
	echo "# Use instances $endianinst1 and $endianinst2 to test cross endian replication instance file copying test case"
	$MSR RUN $endianinst1 'mv mumps.repl mumps.repl.bak'
	$MSR RUN SRC=$endianinst1 RCV=$endianinst2 '$gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/mumps.repl __SRC_DIR__/mumps.repl' >&! transfer_remote_endian.out
	$MSR STARTSRC $endianinst1 $endianinst2
	get_msrtime
	# Check for the presence of YDB-E-REPLINSTFMT and ENDIAN mismatch message
	# Check excacly the right Expected and Found Endian, stored in $e1 and $e2 respectively
	$MSR RUN $endianinst1 'set msr_dont_chk_stat ; '"$msr_err_chk START_$time_msr.out" 'E-REPLINSTFMT "Expected '$e1'. Found '$e2'" '$rollback_err''
	if ($status) then
		# The expected error isn't seen
		echo "TEST-E-REPLINSTFMT expected but not found. Crossendian test failed."
		set error_status = 1
	endif
	# move the last msr_execute's output to outx since it will have message about presence of YDB-E-REPLINSTFMT
	mv $msr_execute_last_out ${msr_execute_last_out}x
	# If gtm_custom_errors is set , we will se the same error in replication enabling commands too. So filter them out
	unset filterjnlerror
	if ($?gtm_custom_errors) then
		if ("" != "$gtm_custom_errors") set filterjnlerror = 1
	endif
	if ($?filterjnlerror) then
		$MSR RUN $endianinst1 "set msr_dont_chk_stat ; $msr_err_chk START_'$time_msr'.out JNL_ON.E-MUPIP"
		mv $msr_execute_last_out ${msr_execute_last_out}x
		$MSR RUN $endianinst1 "set msr_dont_chk_stat ; $msr_err_chk  jnl.log JNL_ON.E-MUPIP E-REPLINSTFMT E-MUNOFINISH"
		mv $msr_execute_last_out ${msr_execute_last_out}x
	endif
	$MSR RUN $endianinst1 'mv mumps.repl.bak mumps.repl'
	$MSR RUN $endianinst2 '$gtm_tst/com/portno_release.csh'
else
	echo "REPLINSTFMT-I-ENDIAN Cross endian copy of replication instance file usage test not done"
endif

echo "# Try 32bit vs 64bit GT.M replication instance file testing"
set gtmplatform_test = 1
if ("$gtm_platform_size3" != "$gtm_platform_size2") then
	# Instance3 and Instance2 has the 32bit vs 64bit GT.M combination
	set platforminst1 = INST3 				; set platforminst2 = INST2
	set e1 = "`echo $gtm_endian3 | sed 's/_ENDIAN//'`" 	; set e2 = "`echo $gtm_endian2 | sed 's/_ENDIAN//'`"
	set p1 = $gtm_platform_size3 				; set p2 = $gtm_platform_size2
else if ("$gtm_platform_size3" != "$gtm_platform_size1") then
	# Instance3 and Instance1 has the 32bit vs 64bit GT.M combination
	set platforminst1 = INST3 				; set platforminst2 = INST1
	set e1 = "`echo $gtm_endian3 | sed 's/_ENDIAN//'`" 	; set e2 = "`echo $gtm_endian1 | sed 's/_ENDIAN//'`"
	set p1 = $gtm_platform_size3 				; set p2 = $gtm_platform_size1
else if ("$gtm_platform_size2" != "$gtm_platform_size1") then
	# Instance2 and Instance1 has the 32bit vs 64bit GT.M combination
	set platforminst1 = INST2 				; set platforminst2 = INST1
	set e1 = "`echo $gtm_endian2 | sed 's/_ENDIAN//'`" 	; set e2 = "`echo $gtm_endian1 | sed 's/_ENDIAN//'`"
	set p1 = $gtm_platform_size2 				; set p2 = $gtm_platform_size1
else
	echo "# None of the instances have 32bit vs 64bit GT.M combination. The test case will be skipped"
	set gtmplatform_test = 0
endif

if ($gtmplatform_test) then
	echo "# Use instances $platforminst1 and $platforminst2 to test 32 vs 64 bit replication instance file copying test case"
	$MSR RUN $platforminst1 'mv mumps.repl mumps.repl.bak'
	$MSR RUN SRC=$platforminst1 RCV=$platforminst2 '$gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/mumps.repl __SRC_DIR__/mumps.repl' >&! transfer_remote_platform.out
	$MSR STARTSRC $platforminst1 $platforminst2
	get_msrtime
	# Check for the presence of YDB-E-REPLINSTFMT AND one of the ENDIAN or 32-64bit mismatch
	# ENDIAN mismatch takes precedence over the 32-62bit mismatch. So check for both incase both of them varies
	$MSR RUN $platforminst1 'set msr_dont_chk_stat ; '"$msr_err_chk START_$time_msr.out" 'E-REPLINSTFMT "Expected '$p1'-bit. Found '$p2'-bit|Expected '$e1'. Found '$e2'" '$rollback_err''
	if ($status) then
		# The expected error isn't seen
		echo "TEST-E-REPLINSTFMT expected but not found. Cross platform test failed."
		set error_status = 1
	endif
	# move the last msr_execute's output to outx since it will have message about presence of YDB-E-REPLINSTFMT
	mv $msr_execute_last_out ${msr_execute_last_out}x
	# If gtm_custom_errors is set , we will se the same error in replication enabling commands too. So filter them out
	unset filterjnlerror
	if ($?gtm_custom_errors) then
		if ("" != "$gtm_custom_errors") set filterjnlerror = 1
	endif
	if ($?filterjnlerror) then
		$MSR RUN $platforminst1 "set msr_dont_chk_stat ; $msr_err_chk START_'$time_msr'.out JNL_ON.E-MUPIP"
		mv $msr_execute_last_out ${msr_execute_last_out}x
		$MSR RUN $platforminst1 "set msr_dont_chk_stat ; $msr_err_chk  jnl.log JNL_ON.E-MUPIP E-REPLINSTFMT E-MUNOFINISH"
		mv $msr_execute_last_out ${msr_execute_last_out}x
	endif
	$MSR RUN $platforminst1 'mv mumps.repl.bak mumps.repl'
	$MSR RUN $platforminst2 '$gtm_tst/com/portno_release.csh'
else
	echo "REPLINSTFMT-I-PLATFORM Cross platform copy of replication instance file usage test not done"
endif

exit $error_status
