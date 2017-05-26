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
#

# test simple before imaged journaled transaction and both recoveries
setenv sub_test bimg1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,buff=2308,file=mumps.mjl mumps.dat
$GTM << GTM_EOF
tstart ():serial
s ^a="a"
s ^b="b"
tcommit
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

# test more complex before imaged journaled transaction and both recoveries
\rm -f mumps.mjl
setenv sub_test bimg2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,buff=2308,file=mumps.mjl mumps.dat
$GTM << GTM_EOF
tstart ():serial
f i=1,2,3 s ^a(i_\$j(i,240))=\$j(i,240)
f i=3,2,1 s ^b(i_\$j(i,240))=\$j(i,240)
f i=1,3,2 s ^c(i_\$j(i,240))=\$j(i,240)
tcommit
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
\rm -f mumps.mjl
setenv sub_test bimg3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,buff=2308,file=mumps.mjl mumps.dat
$GTM << GTM_EOF
tstart ():serial
f i=1,2,3 s ^a(i_\$j(i,240))=\$j(i,240)
f i=3,2,1 s ^b(i_\$j(i,240))=\$j(i,240)
f i=1,3,2 s ^c(i_\$j(i,240))=\$j(i,240)
f i=1,2,3 s ^d(i_\$j(i,240))=\$j(i,240)
f i=1,3,2 s ^e(i_\$j(i,240))=\$j(i,240)
k ^d
f i=2 k ^e(i_\$j(i,240))
tcommit
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
\rm -f mumps.mjl
setenv sub_test bimg4
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,buff=2308,file=mumps.mjl mumps.dat
$GTM << GTM_EOF
f i=1,2,3 s ^a(i_\$j(i,240))=\$j(i,240)
f i=1,2,3 s ^b(i_\$j(i,240))=\$j(i,240)
tstart ():serial
k ^a
f i=2 k ^b(i_\$j(i,240))
tcommit
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
\rm -f mumps.mjl
setenv sub_test bimg5
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,buff=2308,file=mumps.mjl mumps.dat
$GTM << GTM_EOF
tstart ():serial
f i=1,3,2 s ^a(i_\$j(i,240))=\$j(i,240)
f j=1:1:100 s ^a(i_\$j(i,240))=\$j(j,240)
tcommit
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
