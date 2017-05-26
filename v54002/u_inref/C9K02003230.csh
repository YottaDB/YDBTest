#!/usr/local/bin/tcsh -f

# Verify that backward recover does not use an excessive number of mallocs.
# A build with the problem showed >23,000 mallocs. A build with the fix showed >220. 
# 1000 is picked as a discriminator so that if additional valid mallocs are added
# we don't have to revisit the test.
set max_mallocs = 1000

\cp $gtm_tst/$tst/inref/c003230.m .

echo "Create a multiregion global directory"
$GDE << EOF >>& log.out
change -segment DEFAULT -file=mumps.dat
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a
exit
EOF

echo "Create a multiregion database and turn journalling on" 
$MUPIP create >>& log.out
$MUPIP set -journal="enable,on,before" -reg "*" >>& log.out

echo "Create 100000 multiregion TP transactions"
$gtm_exe/mumps -run c003230 >>& log.out

echo "Extract the journal"
$MUPIP journal -extract -noverify -detail -for -fences=none mumps.mjl >>& log.out

echo "Determine the start and end of the transactions"
# find time of first set
set first_set_time = `$head mumps.mjf | $grep " SET" | $tail -n 1 | $tst_awk -F\\ '{print $2}' | $tst_awk -F, '{print $2}'`
# find time of last journal record
set EOF_time = `$tail mumps.mjf | $grep "EOF" | $tail -n 1 | $tst_awk -F\\ '{print $2}' | $tst_awk -F, '{print $2}'`
set delta_time = `expr $EOF_time - $first_set_time`  

echo "Request malloc stats"
setenv gtmdbglvl 2

echo "Recover backwards from start to end of transactions"
$MUPIP journal -recover -back -lost=x.los -since=\"0 00:00:$delta_time\" "*" -verbose >& jnlrecbak.txt 

echo "Turn off request for malloc stats"
unsetenv gtmdbglvl 

echo "Determine if we have an appropriate number of mallocs"
set num_mallocs = `$grep "Total mallocs" jnlrecbak.txt | $tst_awk '{print $3}' | $tst_awk -F"," '{print $1}'`
if ($num_mallocs > $max_mallocs) then
	echo "Maximum allowable mallocs(1000) exceeded ($num_mallocs): Test FAILED"
else
	echo "Test PASSED"
endif
