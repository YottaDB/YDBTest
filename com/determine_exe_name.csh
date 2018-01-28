#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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

ps -p $1 | tail -n 1 >! $2	# BYPASSOK ps/tail : used by tools scripts
set pname = ""
foreach exe_name ( mumps mupip dbcertify dse ftok geteuid gtcm_gnp_server gtcm_pkdisp gtcm_play gtcm_server gtcm_shmclean gtmsecshr libyottadb.so libgtmshr.so lke semstat2)
	grep $exe_name $2 >& /dev/null # BYPASSOK grep : used by tool scripts
	if (! $status) then
		set pname = "$gtm_exe/$exe_name"
		break
	endif
end
echo $pname
