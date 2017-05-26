#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/namelevelorder.cmd'")'
$GDE @gdenamelevelorder.cmd

@ value = 1
while($value <= 8)
	$MUPIP create >& $value.out
	echo "# Testing $value^namelevelorder"
	$gtm_exe/mumps -run namelevelorder ${value}
	@ value++
	$gtm_tst/com/backup_dbjnl.csh bak${value} "*.dat" mv
end
