#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
\touch NOT_DONE.EXTRACT
$GTM << aaa
for  h 1  q:\$GET(^lasti(2,^instance))>3
for  h 1  q:\$GET(^lasti(3,^instance))>3
for  h 1  q:\$GET(^lasti(4,^instance))>3
aaa
@ cnt = 1
while ($cnt <= 10)
	$MUPIP extract extr_${cnt}.glo
	if ($status) then
		echo "TEST-E-Extract FAILED"
		break
	endif
        @ cnt = $cnt + 1
end
# Make sure no one else runs integ at the same time
# Running integ -reg "*" on same global directory has some issues
# So this is the only place to do integ
$gtm_tst/com/dbcheck_base_filter.csh -nosprgde
#
########################
\rm -f NOT_DONE.EXTRACT
