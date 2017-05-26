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

# Test that $VIEW("REGION") as well as various db operations touch the correct # of regions in case of spanned globals

$GDE << GDE_EOF
rename -reg DEFAULT DFLT
change -segment DEFAULT -file=mumps.dat
add -name a -region=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a
add -region BREG -dyn=BSEG
add -segment BSEG -file=b
add -region CREG -dyn=CSEG
add -segment CSEG -file=c
add -name a(1) -reg=BREG
add -name a(1,2) -reg=CREG
add -name a(1,2,3) -reg=DFLT
change -region AREG -std
change -region BREG -std
change -region CREG -std
change -region DFLT -std
GDE_EOF

$MUPIP create

$gtm_exe/mumps -run viewregionandgvstats
