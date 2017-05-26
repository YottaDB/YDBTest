#! /usr/local/bin/tcsh -f
echo ENTERING C9C11002163
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << setupconfiguration
s ^config("hostname")="$tst_org_host"
s ^config("delim")=\$C(65)
d ^c002163
w "Actual port assinged by system:",^realport,!
h
setupconfiguration

# The below section is a test for TR D9I06-002687 - TCP Read uses lots of CPU
# The routine c002163 would have done a sleep of 30 seconds
# and print ps -fp output in checkTIME_psout.out. Check that file to see if the TIME
# value is less than say 5 seconds
set cputime = `$tst_awk '/mumps/ {print $7}' checkTIME_psout.out |& $tst_awk -F : '{print $NF}' |& $tst_awk -F . '{print $1}'`
if (6 < $cputime) then
	echo "TEST-E-CPUSPIN was found to occur. Check the time in checkTIME_psout.out and the routine c002163.m"
	echo "CPU time for the server process was $cputime (for a sleep of 30 seconds)"
endif

$gtm_tst/com/dbcheck.csh -extract mumps
echo LEAVING C9C11002163 
