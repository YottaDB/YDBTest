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

# TODO add description

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/population.cmd'")'

$GDE @gdepopulation.cmd

$GDE show -all
