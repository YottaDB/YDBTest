#!/usr/local/bin/tcsh -f

# This script is used to (re)randomize test_replic_suppl_type if required
# Usage : source $gtm_tst/com/rand_suppl_type.csh [types to chose from]

if (0 == $#argv) then
	@ count = 3
	set a = 0
	set b = 1
	set c = 2
else
	@ count = $#argv
	set a = "$1"
	set b = "$2"
	set c = "$3"
endif

@ rand = `$gtm_exe/mumps -run rand $count`
if (0 == $rand) then
	setenv test_replic_suppl_type $a
else if (1 == $rand) then
	setenv test_replic_suppl_type $b
else
	setenv test_replic_suppl_type $c
endif

echo "# test_replic_suppl_type re-randomized by the subtest"	>> settings.csh
echo "setenv test_replic_suppl_type $test_replic_suppl_type"	>> settings.csh
