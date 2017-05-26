#!/usr/local/bin/tcsh -f
set log=crea_$$_`date +%H_%M_%S`.log
echo DBCREATE >>& $log
\rm -f mumps.gld	# make sure we don't have a left over global directory
$gtm_tst/com/dbcreate.csh mumps $1 >>& $log
echo MUPIP SET -JOURNAL >>& $log
$MUPIP set -journal=enable,on,before -reg "*" >>& $log
echo DATABASE FILES >>& $log
ls -l *.dat  *.mjl |& $tst_awk '{print($1,$NF);}' | tee -a $log
# dbcheck.csh is called by callers of this script.
