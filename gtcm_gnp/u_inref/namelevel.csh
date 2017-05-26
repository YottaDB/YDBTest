#!/usr/local/bin/tcsh -f
source $gtm_tst/com/dbcreate.csh mumps 2
# setenv gtmgbldir per2601
$GDE @$gtm_tst/$tst/inref/per2601.gde
setenv gtmgbldir local
if("ENCRYPT" == $test_encryption) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create -reg=DEFAULT
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
setenv gtmgbldir mumps
$gtm_exe/mumps -run ^per2601
source $gtm_tst/com/dbcheck.csh
