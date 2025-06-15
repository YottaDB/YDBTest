#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cp $gtm_tst/$tst/inref/largefile.m .
echo "Compile M file"
$gtm_exe/mumps largefile.m
echo "Create shared library for largefile.o"
$gt_ld_m_shl_linker $gt_ld_m_shl_options -o largefile$gt_ld_shl_suffix largefile.o >& largefile.out
if ( $HOSTOS == "OS/390" ) then
	if (!(-f largefile.dll) || !(-f largefile.x)) then
		echo "Failed to create shared library"
	endif
else 	if ( !(-f largefile$gt_ld_shl_suffix)) then
		echo "Failed to create shared library"
	endif
endif

echo "End of the test"

