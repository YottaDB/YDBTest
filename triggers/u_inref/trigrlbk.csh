#!/usr/local/bin/tcsh
$gtm_tst/com/dbcreate.csh mumps 2 512 10000 1024
$gtm_exe/mumps -run trigrlbk >&! trigrlbk.out
$gtm_tst/com/check_error_exist.csh trigrlbk.out SETINTRIGONLY TRIGTLVLCHNG
$gtm_tst/com/dbcheck.csh
