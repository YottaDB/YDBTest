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
#
# Check that extract/brokentrans/losttrans files are not leftover if requested by caller test
# The temporary files have the region-name in them so *.*_<REGIONNAME> and not expect them.
set reglist = `$gtm_tst/com/get_reg_list.csh`
set pat = `echo $reglist | sed 's/ /|/g'`
ls -l | $grep -E '_('$pat')$' >& /dev/null
if (! $status) then
	echo "TEST-E-LEFTOVERFILES : mupjnl_check_leftover_files.csh found unexpected leftover files"
	echo "--------------------------------------------------------------------------------------"
	ls -l | $grep -E '_('$pat')$'
	echo "--------------------------------------------------------------------------------------"
	exit 1
endif
exit 0
