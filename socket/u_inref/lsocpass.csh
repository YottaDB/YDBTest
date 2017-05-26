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

set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
source $gtm_tst/com/portno_acquire.csh >>& portno.out

$gtm_exe/mumps -r '%XCMD' 'do lsocpass^lsocpass("'"$randhost"'",'"$portno"')'

foreach i ( {lsocaccept.out} )
	echo
	echo ${i}:
	cat ${i}
end
echo
#$grep -E 'IPv|TCP|unix' {pass,accept}_lsof.out
if ("$gtm_test_os_machtype" !~ HOST_HP-UX*) then
	$gtm_tst/com/check_error_exist.csh lsocaccept_abad.out "PEERPIDMISMATCH"
	$gtm_tst/com/check_error_exist.csh lsocaccept_pbad.out "TEST-E-NOTPASSED"
	mv lsocaccept_pbad.err lsocaccept_pbad.xerr
endif
$gtm_tst/com/check_error_exist.csh lsocaccept_to.out "accept timeout in accepter"

$gtm_tst/com/portno_release.csh

echo Done.
