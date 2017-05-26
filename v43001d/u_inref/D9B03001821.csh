#!/usr/local/bin/tcsh -f

# test key report from mupip integ
#
$GDE exit
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
$GTM << xyz
Set ^x=1
xyz
$DSE << xyz
change -block=4 -tn=100000
xyz
$MUPIP integ mumps.dat


