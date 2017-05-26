#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# ===== BEGIN REORG UPGRD DWNGRD ====="
echo "#PID  ""$$" >& mu_reorg_upgrd_dwngrd.pid
\touch ./MUPIP_UPGDWNG.TXT_$$
echo $$ >! reorg_upgrd_dwngrd.pid

while(1)
	date
	if (-f MUPIP_UPGDWNG.END) then
		break
	endif
	echo "# ==================================================================================="
	@ rand = `$gtm_exe/mumps -run rand 4`
	@ sleep_rand = `$gtm_exe/mumps -run rand 31`
	echo "# `date` : rand=$rand ; sleep_rand=$sleep_rand"
	if (0 == $rand) then
		echo "# Do MUPIP SET VERSION=V4  and sleep for random(30) seconds."
		$MUPIP set -version=V4 -region "*"
		set mupip_stat = $status
		date
		echo "# sleeping for $sleep_rand seconds"
		sleep $sleep_rand
	else if (1 == $rand) then
		echo "# Do MUPIP SET VERSION=V6 and sleep for random(30) seconds."
		$MUPIP set -version=V6 -region "*"
		set mupip_stat = $status
		date
		echo "# sleeping for $sleep_rand seconds"
		sleep $sleep_rand
	else if (2 == $rand) then
		echo "# Do MUPIP REORG UPGRADE"
		$MUPIP reorg -upgrade -region "*"
		set mupip_stat = $status
	else
		echo "# DO MUPIP REORG DOWNGRADE"
		$MUPIP reorg -downgrade -region "*"
		set mupip_stat = $status
	endif
	if ($mupip_stat) then
		echo "# TEST-I-MUPIP_STAT mupip returned $mupip_stat, will exit"
		date
		#  this could happen if the process was crashed deliberately, so it is not necessarily an error
		\rm -f ./MUPIP_UPGDWNG.TXT_$$
		exit
	endif
end
echo "# `date` : mupip upgrd_dwngrd loop is complete"
\rm -f ./MUPIP_UPGDWNG.TXT_$$
