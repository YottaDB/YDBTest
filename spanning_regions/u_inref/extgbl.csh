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

$gtm_tst/com/dbcreate.csh mumps 1

# Create another global directory with [aA]* is mapped to AREG and everything else going to DEFAULT
setenv gtmgbldir a.gld
cat << EOF > a.gde
add -name a* -region=AREG
add -name A* -region=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a.dat
EOF
$GDE @a.gde >&! agld.out
$MUPIP create -region=AREG >&! dbcreateagld.out

# Restore original global directory
setenv gtmgbldir mumps.gld

$gtm_exe/mumps -run per2953

$gtm_tst/com/dbcheck.csh
