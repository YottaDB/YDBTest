#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
		# Strip off "$gtm_exe/plugin/o($gtm_exe/plugin/r)" if present; assumption, it's at the end
		if ("$rtns[$rtncnt]" =~ "*/plugin/o*(*/plugin/r)") @ rtncnt--
		setenv gtmroutines "$rtns[-$rtncnt]"
		unset rtncnt
	else
		setenv gtmroutines "."
	endif
	unset rtns
endif

if (-e $gtm_tools/setactive.csh) then
	set setactive_parms=($1 $2); source $gtm_tools/setactive.csh
else
	# Not a GG environment. So simulate $gtm_tools/setactive.csh
	if (($2 == "p") || ($2 == "pro")) then
		set image = "pro"
	else if (($2 == "b") || ($2 == "bta")) then
		set image = "bta"
	else
		set image = "dbg"
	endif
	if (! -e $gtm_root/$verno/$image) then
		echo "VERSION-E-VERNOTEXIST : Directory $gtm_root/$verno/$image does not exist. Exiting..."
		exit -1
	endif
	setenv gtm_dist $gtm_root/$verno/$image
	setenv gtm_exe $gtm_dist
	if ($?gtmroutines) then
		setenv gtmroutines ". $gtm_dist $gtmroutines"
	else
		setenv gtmroutines ". $gtm_dist"
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
endif
