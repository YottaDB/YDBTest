#! /usr/local/bin/tcsh -f
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

# rm mumps* stop time* tmp*  # for use if run outside the test system
setenv acc_meth "BG"   # test uses before_image journaling
setenv iterations 1000
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_exe/mupip set -journal="enable,on,before" -reg "*"
$gtm_exe/mumps -run gtm8416
$gtm_tst/com/dbcheck.csh
