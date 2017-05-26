#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Requires triggers to use $ztwormhole
setenv gtm_test_trigger 1

$MULTISITE_REPLIC_PREPARE 2

set rand = `$gtm_exe/mumps -run rand 2`
if ( $rand ) then
	setenv INST1_dbcreate_extra_args "-stdnull"
	touch inst1_stdnull
else
	setenv INST2_dbcreate_extra_args "-stdnull"
	touch inst2_stdnull
endif

# due to -different_gld option, the gld layout will be different in INST1 and INST2
$gtm_tst/com/dbcreate.csh mumps 1 255 1024 1024,4096
$echoline

# Start replication
$MSR START INST1 INST2

# Load the IMPTP triggers to help the simulation (yes it's overkill, but it works with the test case)
$gtm_dist/mumps -run %XCMD 'if $ztrigger("file",$ztrnlnm("gtm_tst")_"/com/imptp.trg")' >&! imptp.trg.trigout

# This will cause a dbextract failure when converting from stdnull to gtmnull
$gtm_dist/mumps -run %XCMD 'set $ztwo=$C(5,5,5,6,1,0,1) set ^antp(2,$ztwo)=215'

# This will cause a dbextract failure when converting from gtmnull to stdnull
$gtm_dist/mumps -run %XCMD 'set $ztwo=$ZCH(255)_$C(0)_$ZCH(255)_$C(0,9,9,4,9) set ^antp(1,$ztwo)=419'

$echoline
$MSR SYNC ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2
