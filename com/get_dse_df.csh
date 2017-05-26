#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/is_v4gde_format.csh
if ($status == 1) then
	# it is pre-V5 gde format. use the corresponding script that understand this old gde format.
	$gtm_tst/com/v4gde_get_dse_df.csh "$1"
	exit
endif

set msg = "$1"
if ("$2" == "newlog") then
	echo "Current Time:`date +%H:%M:%S`"	>&!  dse_df.log
else
	echo "Current Time:`date +%H:%M:%S`"	>>&! dse_df.log
endif
echo $msg 					>>&  dse_df.log
# dse all -dump -all works only from version V52000
if ( `expr $gtm_exe:h:t ">=" "V52000"` ) then
	$DSE all -dump -all			>>&! dse_df.log
else

	$gtm_tst/com/get_reg_list.csh > gde_reg.log
	if ($status) then
		echo "GET_DSE_DF-E-XCMD : Error while getting list of regions. <cat gde_reg.log> output follows"
		cat gde_reg.log
	endif

	echo "# Regions found:"			>>&! dse_df.log
	cat gde_reg.log 			>>&! dse_df.log
	echo ""					>    dse_df.cmd
	foreach region (`cat gde_reg.log`)
		echo "find -REG=$region"	>> dse_df.cmd
		echo "dump -file -all"		>> dse_df.cmd
	end

	$DSE < dse_df.cmd			>>&! dse_df.log
endif
