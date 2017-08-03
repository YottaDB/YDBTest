#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Helper script for the relink/rundown test. It attempts to run a MUMPS program, for which the relinkctl memory has been created but
# the rtnobj one not. It then removes the newly created rtnobj shared memory.

echo "User Name          : " `whoami`
echo "Version            : " $1
echo "Image              : " $2

setenv gtm_tst $4
source $gtm_tst/com/set_specific.csh
source $gtm_tst/com/remote_getenv.csh $3
if ( $?gtm_chset ) then
	echo $gtm_chset
else
	echo "gtm_chset is undefined"
endif

locale
source $gtm_tst/com/set_active_version.csh $1 $2
cd $3
setenv gtmgbldir "mumps.gld"
setenv gtmroutines ".*"

$gtm_dist/mumps -run a

$gtm_tst/$tst/u_inref/rundown_rctl_shms.csh . mupip_rctldump13a.logx rtnobj >&! remote_rundown.log
