#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# test compiled obj files across versions
#
cp $gtm_tst/$tst/inref/objformt.x objformt.m
#
# Disable unicode if ICU >= 4.4 is detected, since support for it started with V54002 and this test require an older version.
if (($?gtm_chset) && ($?gtm_icu_version)) then
	if (("UTF-8" == $gtm_chset) && (1 == `echo "if ($gtm_icu_version >= 4.4) 1" | bc`)) then
		set save_chset = $gtm_chset
		$switch_chset "M" >&! switch_chset1.out
	endif
endif
setenv version_list `$gtm_tst/com/random_ver.csh -type obj_mismatch`
if ("$version_list" =~ "*-E-*") then
	echo "No prior versions available: $version_list"
	exit -1
endif
echo "$version_list" > version_list.txt

# The default prompt is "GTM>" for versions < r1.00 and "YDB>" for other versions.
# Since we want a deterministic reference file, and it is not possible to get pre r1.00 versions to
# display a "YDB>" prompt, keep the prompt at "GTM>" even in post-r1.00 versions.
setenv gtm_prompt "GTM>"

# check_versions.csh uses env. variable "version_list" for the list of old versions to iterate in the loop
$gtm_tst/com/check_versions.csh objswitch objswitch
#
if ($?save_chset) then
	$switch_chset $save_chset >&! switch_chset2.out
endif
