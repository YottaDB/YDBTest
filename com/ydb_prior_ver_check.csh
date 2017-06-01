#!/usr/local/bin/tcsh -f

if ($?ydb_environment_init) then
	# This is not a GG setup. And so versions prior to V63000A have issues running in UTF-8 mode (due to icu
	# library naming conventions that changed). So disable UTF8 mode testing in case the older version is < V63000A.
	if (`expr "V63000A" \> "$prior_ver"`) then
		if ($?gtm_chset) then
			if ("UTF-8" == $gtm_chset) then
				unsetenv gtm_chset
			endif
		endif
	endif
endif
if ($?gtm_test_temporary_disable) then
	# With encryption enabled, we get a CRYPTKEYFETCHFAILED error currently (hash mismatch).
	# Temporarily disable encryption until this issue is fixed.
	if ("ENCRYPT" == "$test_encryption" ) then
		if (`expr "V63000A" \> "$prior_ver"`) then
			setenv test_encryption NON_ENCRYPT
		endif
	endif
endif
