#!/usr/local/bin/tcsh -f
#################################################
# C9H09002900 Test case for $VIEW error which occurred right after changing the $zgbldir,
# where the $VIEW did not reflect the new global directory until after a global variable access

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1     # will create mumps.dat and a.dat and a two-region mumps.gld
# Create an "other" gld and associated .dat file
#
# Make gtm$gbldir point to other.gld
setenv gtmgbldir other.gld
$gtm_exe/mumps -run GDE << GDE_EOF
rename -region DEFAULT other
rename -segment DEFAULT other
ch -s other -f="other"
exit
GDE_EOF
if("ENCRYPT" == $test_encryption) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$gtm_exe/mupip create
#
setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run ^c002900
$gtm_tst/com/dbcheck.csh
