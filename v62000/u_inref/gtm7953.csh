#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_spanreg     0       # Test requires traditional global mappings, so disable spanning regions

## set keysize to max possible
set key=1019

cat << CAT_EOF > gtm7953.gde
add -reg areg -dyn=aseg
add -segment aseg -file=a
add -name x(1,2) -reg=areg
change -reg DEFAULT -std
change -seg DEFAULT -blo=2048
change -reg DEFAULT -key=$key -rec=2048
change -reg areg -std
change -seg aseg -blo=2048
change -reg areg -key=$key -rec=2048
CAT_EOF

setenv test_specific_gde $PWD/gtm7953.gde
$gtm_tst/com/dbcreate.csh mumps 2

setenv gtmdbglvl 0x30
$GTM << GTM_EOF
	write "\$view(""REGION"",""^x(1)"")=",\$view("REGION","^x(1)"),!
        write \$zprevious(^x(1,"")),!
GTM_EOF

unsetenv gtmdbglvl

$gtm_tst/com/dbcheck.csh
