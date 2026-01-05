#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# cur_jnlseqno.csh [RESYNC|REGION] [number_to_subtract_in_decimal]
# If no  parameter is passed, "REGION" and "0" are used
#

$gtm_tst/com/is_v4gde_format.csh
if ($status == 1) then
	# it is pre-V5 gde format. use the corresponding script that understand this old gde format.
	$gtm_tst/com/v4gde_cur_jnlseqno.csh "$1" "$2"
	exit
endif

setenv gtm_test_parm_to_gtm $2
if ("" == "$gtm_test_parm_to_gtm") setenv gtm_test_parm_to_gtm 0
#
echo "Current Time:`date +%H:%M:%S`" >>&! cur_jnlseqno.out
if ("RESYNC" == "$1") then
	#$grep -E "Resync Seqno"  df.out | $tst_awk '{printf("%s\n",$3);}' >>&! allseqno.out
	$MUPIP replic -editinstance -show $gtm_repl_instance >&! instancefile.out
	set resync_seqno = `$grep "Resync Sequence Number" instancefile.out | $tst_awk '{print $8}'`
	@ retval = $resync_seqno - $gtm_test_parm_to_gtm
	echo $retval
else	#i.e. "REGION"
	$gtm_tst/com/get_reg_list.csh >&! gde_reg.out
	if ($status) then
		echo "GET_DSE_DF-E-XCMD : Error while getting list of regions. <cat gde_reg.out> output follows"
		cat gde_reg.out
	endif

	echo "Regions found:"	>>&! cur_jnlseqno.out
	cat gde_reg.out		>>&! cur_jnlseqno.out
	foreach region (`cat gde_reg.out`)
		$DSE << DSE_EOF >&! df.out
		find -REG=$region
		d -f
DSE_EOF
		$grep "Region Seqno"  df.out | $tst_awk '{print $6}' >>&! allseqno.out
	end
	$convert_to_gtm_chset allseqno.out
	$GTM << \GTM_EOF >>&! cur_jnlseqno.out
	do ^maxrsno("allseqno.out",$ztrnlnm("gtm_test_parm_to_gtm"),"cur_jnlseqno.txt")
	halt
\GTM_EOF
	setenv ctime `date +%H_%M_%S`
	\mv allseqno.out allseqno_${ctime}.out
	cat cur_jnlseqno.txt
endif
