#!/usr/local/bin/tcsh -f

source $gtm_tst/com/dbcreate.csh mumps 1

$gtm_exe/mumps -run overflow > overflow.out

if ("" == "`$grep added overflow.out`") then
	echo "No trigger added."
else
	cat overflow.out
endif

$gtm_tst/com/dbcheck.csh -extract
