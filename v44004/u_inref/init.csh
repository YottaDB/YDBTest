#!/usr/local/bin/tcsh
# start afresh
rm -f *.dat *.mj* *.gld dbcreate*.out* >&! /dev/null
$gtm_tst/com/dbcreate.csh mumps 5
setenv tst_jnl_str "$tst_jnl_str,epoch=2"
$gtm_tst/com/jnl_on.csh
#$MUPIP set -journal="enable,on,before,epoch=2" -reg "*" >&! set_jnl_on.out
if (! $?count) setenv count 1
echo "#################### Test $count ##############################"
# No need for dbcheck.csh as it is called by check.csh, which is called by the caller of init.csh.
