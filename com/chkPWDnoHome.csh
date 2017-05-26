#!/usr/local/bin/tcsh -f

if (`echo $PWD | $tst_awk -F/ '$2 ~/gtc/ || $2 ~/usr/ || $3 ~/gtc/ {print "1"}'` || ($PWD == $HOME)) then
	echo "TEST-E-DIR1 Will not execute the command"
	echo "Please specify a non-/gtc/ non-/usr/ directory to run the tests"
	exit 6
endif
