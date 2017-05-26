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

$gtm_exe/mumps -r '%XCMD' 'do lsocpassmulti^lsocpassmulti("'"$randhost"'",'"$portno"')'

cat lsocaccept.out
cat ball.out

$gtm_tst/com/portno_release.csh

echo Done.
