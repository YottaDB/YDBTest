#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
date
set before = `date +%s`
# The command is prepared in rolrec_bg_fg.csh, and passed here in the first argument
# the other arguments are passed in as the rest of the arguments
set command = "$1"
shift
$command "*" $argv
date
set after = `date +%s`
@ difftime = $after - $before
echo "The time the mupip command took: " $difftime
source $gtm_tst/$tst/u_inref/find_span.csh .
set rol_or_rec_log="$gtm_test_log_dir/${HOST:r:r:r}_${rol_or_rec}.log"
echo "MUPIP ${rol_or_rec} ${crash_stop} ${ztptp} ${no}:  $difftime $span ($tst_general_dir)" | tee -a ${HOST:r:r:r}_${rol_or_rec}.log >>&! $rol_or_rec_log
#Change permissions to group writable
chmod 664 $rol_or_rec_log >& /dev/null
