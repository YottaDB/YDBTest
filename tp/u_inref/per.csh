#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# test of string pool garbage collect during journaled transaction
\rm -f mumps.mjl
setenv sub_test bimg6
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,buff=2308,file=mumps.mjl mumps.dat
$GTM << GTM_EOF
w "do ^per2607f",! do ^per2607f
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
$MUPIP journal -recover -backward mumps.mjl
if($?test_replic) unsetenv test_replic
$gtm_tst/com/dbcheck.csh -nosprgde
if($?save_test_replic) setenv test_replic save_test_replic
\rm mumps.dat
$MUPIP create
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
$MUPIP journal -recover -forward mumps.mjl
if($?test_replic) unsetenv test_replic
$gtm_tst/com/dbcheck.csh -nosprgde
if($?save_test_replic) setenv test_replic save_test_replic
# test of journal value pointer system
\rm -f mumps.mjl
setenv sub_test bimg7
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,buff=2308,file=mumps.mjl mumps.dat
$GTM << GTM_EOF
w "do ^per2607g",! do ^per2607g
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
$MUPIP journal -recover -backward mumps.mjl
if($?test_replic) unsetenv test_replic
$gtm_tst/com/dbcheck.csh -nosprgde
if($?save_test_replic) setenv test_replic save_test_replic
\rm mumps.dat
$MUPIP create
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
$MUPIP journal -recover -forward mumps.mjl
if($?test_replic) unsetenv test_replic
$gtm_tst/com/dbcheck.csh -nosprgde
if($?save_test_replic) setenv test_replic save_test_replic

setenv sub_test per3050
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 500 1024 50 1024
$GTM << GTM_EOF
w "do ^per3050",! d ^per3050
w "do ^per3050a",! d ^per3050a
w "do ^per3050b",! d ^per3050b
w "do ^per3050c",! d ^per3050c
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test per3158
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 500 1024 50 1024
$GTM << GTM_EOF
w "do ^per3158",! do ^per3158
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test per3184
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 500 1024 500 1024
$GTM << GTM_EOF
w "do ^per3184",! do ^per3184
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test d001231
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 2 125 500 1024 500 1024
$GTM << GTM_EOF
w "do ^d001231",! do ^d001231
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test c001149
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 1000 1024 500 1024
$GTM << GTM_EOF
w "do ^c001149",! do ^c001149
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test c001266
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 1000 1024 500 64
$GTM << GTM_EOF
w "do ^c001266",! do ^c001266
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test
