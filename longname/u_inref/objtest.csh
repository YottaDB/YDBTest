#!/usr/local/bin/tcsh -f
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
# check_versions.csh uses env. variable "version_list" for the list of old versions to iterate in the loop
$gtm_tst/com/check_versions.csh objswitch objswitch
#
if ($?save_chset) then
	$switch_chset $save_chset >&! switch_chset2.out
endif
