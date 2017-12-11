#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This script just calls the stress runs. This script exists so that the callcan be backgrounded

if ("init" == "$1") then
$GTM << GTM_EOF
do init^concurr("$2","$3")
GTM_EOF

endif

@ exit_status = 0

if ("run" == "$1") then
$GTM << GTM_EOF
do run^concurr($2)
do verify^concurr
GTM_EOF

set exit_status = $status # run^concurr could return non-zero exit status through "zhalt 255" done in stress/inref/stress.m

endif

exit $exit_status
