#!/usr/local/bin/tcsh -f
#
# transbig2:  test that in tp update, the threshold of write-set for number global buffers is not crossed

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"
alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

BEGIN "Create the database with maximum block size(1008) and with limit of more than 32K number of global buffers"
setenv gtmgbldir mumps.gld
setenv test_specific_gde $gtm_tst/$tst/u_inref/gblbufflimit.gde
$gtm_tst/com/dbcreate.csh mumps 1
END

BEGIN "Test the write-set limit of 32K number of blocks, for number of global buffers in one transaction, is not violated"
$gtm_exe/mumps -run dbwrite2^transtoobig
END
$gtm_tst/com/dbcheck.csh
