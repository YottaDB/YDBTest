#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set verno = $1

# If we are switching to a version where autorelink is not supported (or, in case of V62000,
# gtmsrc.csh has problems dealing with $gtmroutines with asterisks), we sanitize $gtmroutines
# by removing all asterisks from it.
if ($?gtmroutines) then
	if ((`expr "V900" \> "$verno"`) && (`expr "V62000" \>= "$verno"`)) then
		setenv gtmroutines `echo "$gtmroutines" | sed -e "s|*||g"`
	endif

	# Rebuild gtmroutines while trying to preserve the old value
	set rtns = ($gtmroutines:x)
	if (0 < $#rtns) then
		@ rtncnt = $#rtns
		# Strip off "$gtm_exe/plugin/o($gtm_exe/plugin/r)" if present; assumption, it's last in the list
		if ("$rtns[$rtncnt]" =~ "*/plugin/o*(*/plugin/r)") @ rtncnt--
		# Strip off "$gtm_exe/plugin/o/_ydbposix.so" if present; assumption, it's last but one in the list
		if ("$rtns[$rtncnt]" =~ "*/plugin/o*/_ydbposix.so") @ rtncnt--
		setenv gtmroutines "$rtns[-$rtncnt]"
		unset rtncnt
	else
		setenv gtmroutines "."
	endif
	unset rtns
endif

@ ydbenv = 1
if ($?gtm_tools) then
	if (-e $gtm_tools/setactive.csh) then
		set setactive_parms=($1 $2); source $gtm_tools/setactive.csh
		@ ydbenv = 0
	endif
endif
if ($ydbenv) then
	# Not a GG environment. So simulate $gtm_tools/setactive.csh
	if (($2 == "p") || ($2 == "pro")) then
		set image = "pro"
	else if (($2 == "b") || ($2 == "bta")) then
		set image = "bta"
	else
		set image = "dbg"
		if ($?gtt_cc_shl_options) then
			# If using dbg image, make compilations of .c programs in test system also happen with
			# debugging information turned on (just like the YottaDB executable is compiled).
			# This helps debug test failures (e.g. SIG-11) in the C program.
			setenv gtt_cc_shl_options "$gtt_cc_shl_options -g"
		endif
	endif
	if (! -e $gtm_root/$verno/$image) then
		echo "VERSION-E-VERNOTEXIST : Directory $gtm_root/$verno/$image does not exist. Exiting..."
		exit -1
	endif
	setenv gtm_dist $gtm_root/$verno/$image
	setenv ydb_dist $gtm_root/$verno/$image	# needed at least by maskpass (e.g. set_tls_env.csh invocation for a different version)
	setenv gtm_exe $gtm_dist
	if ($?gtm_chset) then
		if ("$gtm_chset" != "UTF-8") then
			set objdir = $gtm_exe
		else
			set objdir = $gtm_exe/utf8	# so UTF-8 .o files are picked in $gtmroutines
		endif
	else
		set objdir = $gtm_exe
	endif
	if ($?gtmroutines) then
		setenv gtmroutines ". $objdir $gtmroutines"
	else
		setenv gtmroutines ". $objdir"
	endif
	setenv gtm_tools $gtm_root/$verno/tools
	setenv gtm_inc $gtm_root/$verno/inc
	setenv gtm_verno $verno
	setenv gtm_ver $gtm_root/$verno
	setenv gtm_obj $gtm_dist/obj
	setenv gtm_log $gtm_ver/log
	setenv gtm_pct_list $gtm_ver/pct
	setenv gtm_pct $gtm_pct_list
	setenv gtm_inc_list $gtm_ver/inc
	setenv gtm_inc $gtm_inc_list
	setenv gtm_vrt $gtm_ver
	setenv gt_cc_option_I "-I$gtm_inc"
	setenv ydb_xc_ydbposix $ydb_dist/plugin/ydbposix.xc
endif
