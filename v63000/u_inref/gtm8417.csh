#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/relink/u_inref/enable_autorelink_dirs.csh
$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate.log
$gtm_dist/mumps -run init^gtm8417
$gtm_dist/mumps -run gtm8417
$gtm_tst/com/dbcheck.csh >&! dbcheck.log
