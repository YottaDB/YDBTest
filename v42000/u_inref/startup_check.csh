#! /usr/local/bin/tcsh -f
#!
#
unsetenv test_replic   
unsetenv gtm_exe
unsetenv gtm_dist
$GTM << aaa
W "Testing GT.M Startup check ...",!
aaa
find . -type f -a \( -name 'core*' -o -name 'gtmcore*' \) -print >& CORE.list
if !($status) then
	if (-z CORE.list) then
		echo "TEST PASSED"
	else
		echo "TEST FAILED"
		echo "Core found"
		cat CORE.list
	endif
endif
