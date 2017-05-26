#!/usr/local/bin/tcsh -f
#Check if LKS value in zshow "G" is right

$gtm_tst/com/dbcreate.csh mumps

echo "# Launching gtm7510..."
$gtm_exe/mumps -run gtm7510
echo "# gtm7510 completed."
echo "# Checking the mjo files for LKS value..."
foreach file (locker_gtm7510.mjo*)
    if (2 != `$grep -c "LKS:100" $file`) then
	echo "TEST-E-FAIL $file does not show the correct LKS value."
	set fail=1
    endif
end
if(! $?fail) then
    echo "TEST-I-PASS All mjo files have the correct LKS value."
endif
$gtm_tst/com/dbcheck.csh
