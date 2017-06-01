#!/usr/local/bin/tcsh -f

if ($?gtm_test_temporary_disable) then
	# With encryption enabled, we get a CRYPTKEYFETCHFAILED error currently (hash mismatch).
	# Temporarily disable encryption until this issue is fixed.
	if ("ENCRYPT" == "$test_encryption" ) then
		if (`expr "V63000A" \> "$prior_ver"`) then
			setenv test_encryption NON_ENCRYPT
		endif
	endif
endif
