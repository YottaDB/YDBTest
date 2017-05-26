########################################
### C9D03-002246 - $ZTEXIT ISV tests ###
########################################
#
echo '$ZTEXIT tests START....'
setenv zte_subtest_list "errorint manyints multintr nesttp nointrpt refniosv smpltp snglintp tpwint"
# define env var that contains SIGUSR1 value on all platforms
if (($HOSTOS == "OSF1") || ($HOSTOS == "AIX")) then
    setenv sigusrval 30
else if (($HOSTOS == "SunOS") || ($HOSTOS == "HP-UX")) then
    setenv sigusrval 16
else if ($HOSTOS == "Linux") then
    setenv sigusrval 10
endif
#
#
echo "--------------------------------------------------------------------"
echo "errorint tests start....."
source $gtm_tst/$tst/u_inref/errorint.csh >&! errorint.log

echo "errorint tests completed...."
echo "--------------------------------------------------------------------"
#
echo "manyints tests start....."
source $gtm_tst/$tst/u_inref/manyints.csh >&! manyints.log
echo "manyints tests completed....."
echo "--------------------------------------------------------------------"
#
echo "nesttp tests start....."
source $gtm_tst/$tst/u_inref/nesttp.csh >&! nesttp.log
echo "nesttp tests completed...."
echo "--------------------------------------------------------------------"
#
echo "multintr tests start....."
source $gtm_tst/$tst/u_inref/multintr.csh >&! multintr.log
echo "multintr tests completed...."
echo "--------------------------------------------------------------------"
#
echo "nointrpt tests start....."
source $gtm_tst/$tst/u_inref/nointrpt.csh >&! nointrpt.log
echo "nointrpt tests completed....."
echo "--------------------------------------------------------------------"
#
echo "refniosv tests start....."
source $gtm_tst/$tst/u_inref/refniosv.csh >&! refniosv.log
echo "refniosv tests completed....."
echo "--------------------------------------------------------------------"
#
echo "restarts tests start....."
source $gtm_tst/$tst/u_inref/restarts.csh >&! restarts.log
echo "restarts tests complteted...."
echo "--------------------------------------------------------------------"
#
echo "smpltp tests start....."
source $gtm_tst/$tst/u_inref/smpltp.csh >&! smpltp.log
echo "smpltp tests completed..."
echo "--------------------------------------------------------------------"
#
echo "snglintp tests start....."
source $gtm_tst/$tst/u_inref/snglintp.csh >&! snglintp.log
echo "snglintp tests completed..."
echo "--------------------------------------------------------------------"
#
echo "tpwint tests start....."
source $gtm_tst/$tst/u_inref/tpwint.csh >&! tpwint.log
echo "tpwint tests completed...."
echo "--------------------------------------------------------------------"
#
#
foreach zte_subtest ($zte_subtest_list)
	\cp $gtm_tst/$tst/outref/$zte_subtest.txt .
	\mv $zte_subtest.txt $zte_subtest.cmp
	\diff $zte_subtest.cmp $zte_subtest.log >&! $zte_subtest.diff
	if ($status != 0 ) then
	    echo FAIL from $zte_subtest. Please check $zte_subtest.diff
	else
	    echo PASS from $zte_subtest.
       endif
end
#
echo '$ZTEXIT tests DONE....'
