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
endif
