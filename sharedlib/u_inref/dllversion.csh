#! /usr/local/bin/tcsh -f

echo "to test old version of DLL with the new software, it should error out, but not bomb"
# Disable unicode if ICU >= 4.4 is detected, since support for it started with V54002 and this test require an older version.
if (($?gtm_chset) && ($?gtm_icu_version)) then
	if (("UTF-8" == $gtm_chset) && (1 == `echo "if ($gtm_icu_version >= 4.4) 1" | bc`)) then
		set save_chset = $gtm_chset
		$switch_chset "M" >&! switch_chset1.out
	endif
endif
# pick up list of versions to test
set gtm_test_shlib_versions = `$gtm_tst/com/random_ver.csh -type shlib_mismatch`
if ("$gtm_test_shlib_versions" =~ "*-E-*") then
	echo "No prior versions available: $gtm_test_shlib_versions"
	exit -1
endif
echo "$gtm_test_shlib_versions" > version_list.txt

set errcnt = 0
foreach ver ($gtm_test_shlib_versions)
	$gtm_tst/$tst/u_inref/dllversion_oneversion.csh $ver >&! $ver.log
	set stat = $status
	if ($stat) then
		echo "-------------------------------------------------------------"
		echo "TEST-E-DLLVERSION version $ver returned $stat status."
		echo "Please check the output at $ver.log"
		@ errcnt = $errcnt + 1
		echo "-------------------------------------------------------------"
	endif
	# check output
	$gtm_tst/com/check_reference_file.csh $gtm_tst/$tst/outref/dllversion_oneversion.txt $ver.log
	set stat = $status
	if ($stat) then
		echo "-------------------------------------------------------------"
		echo "TEST-E-DLLVERSION FAIL from dllversion for version $ver"
		echo "Please check $ver.diff"
		@ errcnt = $errcnt + 1
		echo "-------------------------------------------------------------"
	endif
end
if (0 == $errcnt) then
	echo "PASS"
	$tst_gzip V*.log
else
	echo "FAIL"
endif
if ($?save_chset) then
	$switch_chset $save_chset >&! switch_chset2.out
endif
