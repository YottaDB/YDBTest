#!/usr/local/bin/tcsh -f
if ($#argv != 2 ) then
	echo "number of parameters :: $#argv"
	echo "configure_nct_and_col.csh expects exactly two parameters: nct, act"
	echo "for example: configure_nct_and_col.csh 1 1 ==> turns on nct and set collation to 1"
	echo "             configure_nct_and_col.csh 0 1 ==> turns off nct and set collation to 1"
	exit 1
endif

rm -f init.m >&! /dev/null
rm -f init.o >&! /dev/null

echo "	set nct=$1" > init.m
echo "	set act=$2" >> init.m
echo "	q" >> init.m

cat init.m

# The caller (col_nct_with_chn.csh) invokes the script (both in the primary and the secondary) at a point where the mumps.repl
# is not yet created. Furthermore, if $gtm_custom_errors is set, then the below global references tries to initialize journal pool
# at which point it encounters FTOKERR/ENO2 errors due to non-existent mumps.repl file. So, unset gtm_custom_errors. No need to
# restore the value since the parent script "executes" this script and so the environment mods are not reflected back.
unsetenv gtm_custom_errors
$GTM << \aaa
d ^init
w "nct is requested to be set to ",nct,!
w "act is requested to be set to ",act,!
set enabled=$$set^%GBLDEF("^a",nct,act)
w "The return code from set of %GBLDEF :: ",enabled,!
w "Global ^a is configured to :: ",$$get^%GBLDEF("^a"),!
set enabled=$$set^%GBLDEF("^A",nct,act)
w "The return code from set of %GBLDEF :: ",enabled,!
w "Global ^A is configured to :: ",$$get^%GBLDEF("^A"),!
h
\aaa
