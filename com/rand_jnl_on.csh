#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#################################################

$gtm_tst/com/is_v4gde_format.csh
if ($status == 1) then
	# it is pre-V5 gde format. use the corresponding script that understand this old gde format.
	$gtm_tst/com/v4gde_rand_jnl_on.csh "$1" "$2"
	exit
endif

# do not create journal files at /*.mjl if $1 is null, use . then
set jnldir = "$1"
if ("$jnldir" == "") set jnldir = "."

if (("$2" != "-replic=on")&&("$2" != "")) then
 echo "Arguments not understood $2"
 exit
endif

setenv GDE "$gtm_exe/mumps -run GDE"
$GDE << GDE_EOF>&! gde.out
show -map
quit
GDE_EOF

echo "####################################################################" >>&! jnl.log
date >>&! jnl.log
echo "--------------------" >>&! jnl.log
echo "JOURNAL OPTIONS: $tst_jnl_str" >>&! jnl.log
# ':' is a sign of GT.CM region (oscar:/testarea4/...)
foreach x (`$grep -v "GDE" gde.out | grep "FILE = " | sed 's/^.*= //g' | awk -F. '{print $1}'| $tst_awk -F/ '{print $NF}' | sort -u`)
	sleep 1
	set num = `date | $tst_awk '{srand(); print (1 + int(rand() * 3))}'`
	if ($num == 2) then
		echo $MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}_curr.mjl $2 >>&! jnl.log
		$MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}_curr.mjl $2 >>&! jnl.log
	endif
end
