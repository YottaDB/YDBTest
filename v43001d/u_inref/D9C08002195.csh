#! /usr/local/bin/tcsh -f

# test mupip set with a region list
#
$GDE << xyz
add -name temp -region=temp
add -region temp -dyn=temp
add -segment temp -file=temp
xyz
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create |& sort -f 
$MUPIP set -region -access=bg DEFAULT,TEMP
