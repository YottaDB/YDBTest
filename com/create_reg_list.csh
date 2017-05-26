#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2014 Fidelity Information Services, Inc	#
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
	$gtm_tst/com/v4gde_create_reg_list.csh
	exit
endif

$gtm_tst/com/get_reg_list.csh > reg_list.txt
$convert_to_gtm_chset reg_list.txt	# needed on OS390 because this is going to be read by M programs like changecurtn.m
