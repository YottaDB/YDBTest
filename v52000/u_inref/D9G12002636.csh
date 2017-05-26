#!/usr/local/bin/tcsh -f

if (-X expect) then
	#$switch_chset M >&! /dev/null
	setenv TERM xterm
	echo "Beginning Job Interrupt and terminal testing"
	$gtm_tst/com/dbcreate.csh mumps
	echo "Now call the expect script"
	expect -f $gtm_tst/$tst/u_inref/D9G12002636.exp
	$gtm_tst/com/dbcheck.csh
	echo "Done..."
else
	echo "No expect in PATH, please install"
endif
