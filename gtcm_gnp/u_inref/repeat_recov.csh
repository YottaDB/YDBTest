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

setenv gtm_test_since_time `cat  gtm_test_since_time.txt`
echo "DEBUG:since = $gtm_test_since_time" >>& since_time.log
@ i = 1
while ($i <= 2 )
	mkdir ./save{$i} ; \cp {*.dat,*.mjl*} ./save{$i}
	$MUPIP journal -recover -backward "*" -since=\"$gtm_test_since_time\" >& recover_back{$i}.out
	set stat1 = $status
	$grep successful recover_back{$i}.out
	set stat2 = $status
	if ($stat1 != 0 || $stat2 != 0) then
		echo " $MUPIP journal -recover -backward * -since=$gtm_test_since_time failed"
		$gtm_tst/com/ipcs -a
		$ps
		exit
	endif
	$gtm_tst/com/dbcheck_base_filter.csh
	@ i = $i + 1
end
