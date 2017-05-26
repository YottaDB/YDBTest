#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# do rundown if needed before requiring standalone access

echo "\cp -f ./$bkupdir1/*.dat* ."
\cp -f ./$bkupdir1/*.dat* .
foreach db (`ls *.dat*`)
	ls ./$bkupdir2/$db >& /dev/null
	if ($status == 0) then
		echo "$MUPIP restore $db ./$bkupdir2/$db"
		$MUPIP restore $db ./$bkupdir2/$db
	else
		echo "Incremental backup did not create ./$bkupdir2/$db"
	endif
end

$MUPIP integ -reg "*"
if ($status) then
	$gtm_tst/com/ipcs -a
	exit
endif
$MUPIP extract tmp.glo >>& extract.out
$tail -n +3  tmp.glo >! mupip_restore.glo
\rm -f tmp.glo
