#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# White-box-test for gtm-7811: simulate MUPIP STOP when about to throw a restart in tp_unwind(). In
# v60002 and earlier, this resulted in a sig-11 because we re-enabled interrupts BEFORE resetting
# dollar_tlevel. Now the order is fixed but this test should tell if it ever gets broken again.
#
setenv gtm_test_trigger 1
setenv test_specific_trig_file "$gtm_tst/$tst/inref/gtm7811.trg"
$gtm_tst/com/dbcreate.csh .
#
# Enable white box test
#
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 46
#
$gtm_dist/mumps -run gtm7811
#
$gtm_tst/com/dbcheck.csh
