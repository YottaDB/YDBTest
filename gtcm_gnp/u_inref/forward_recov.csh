#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set files = $1
$MUPIP journal -recover -forward $files >& recover_forward.out
set stat1 = $status
$grep successful recover_forward.out
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "$MUPIP journal -recover -forward $files filed"
	$gtm_tst/com/ipcs -a
	$ps
	exit
endif
