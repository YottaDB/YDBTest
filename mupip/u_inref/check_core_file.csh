#! /usr/local/bin/tcsh -f
if ("os390" == "$gtm_test_osname") then
	if (-f gtmcore) then
		if ("" != $3) echo "TEST-E-FAIL"
		mv gtmcore $1gtmcore$2
		@ corecnt += 1
	endif
else
	if (-f core) then
		if ("" != $3) echo "TEST-E-FAIL"
		mv core $1core$2
		@ corecnt += 1
	endif
endif
