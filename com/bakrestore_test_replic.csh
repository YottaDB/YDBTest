#!/usr/local/bin/tcsh -f

if ($?test_replic) then
	setenv bak_test_replic $test_replic
	unsetenv test_replic
	exit
endif

if ($?bak_test_replic) then
	setenv test_replic $bak_test_replic
	unsetenv bak_test_replic
	exit
endif
