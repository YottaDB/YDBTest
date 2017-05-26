#!/usr/local/bin/tcsh 
#
# D9902-001105 Close the disabling Control-C hole on Unix 
# 

set expectpath = `which expect`
if ("$expectpath" != "") then 
	setenv TERM xterm
	expect -f $gtm_tst/$tst/u_inref/ctrlc.exp $gtm_dist >&! ctrlc.out
endif

set numfound = `$grep -c GTM-I-CTRLC ctrlc.out`
# Should only see GTM-I-CTRLC once (when gtm_nocenable is not set)
if (1 == $numfound) then
	set ctrlclinenum = `$grep -n GTM-I-CTRLC ctrlc.out| cut -d: -f1`
	set nocenablelinenum = `$grep -n "unsetenv gtm_nocenable" ctrlc.out| cut -d: -f1`
#	Should see GTM-I-CTRLC after gtm_nocenable is unset
	if (`expr "$ctrlclinenum" \> "$nocenablelinenum"`) then
		echo "PASS"
		exit
	endif
endif
# Otherwise the test failed
echo "FAIL"
