#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

setenv start_time `cat start_time` # start_time is used in naming conventions
setenv srcLog "SRC_$start_time.log"
setenv portno `$sec_shell "$sec_getenv ; source $gtm_tst/com/portno_acquire.csh"`

echo "# Shut down source server and set regions to different NULL Collation"
$gtm_tst/com/SRC_SHUT.csh "." < /dev/null >>&! $PRI_SIDE/NULLCOLL_SHUT1.out
$MUPIP SET -REGION "DEFAULT" -NOSTDNULLCOLL
$MUPIP SET -REGION "AREG" -STDNULLCOLL
echo ''

echo "# Restart source server (expecting NULLCOLLDIFF error)"
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! NULLCOLL_RESTART1.outx

$grep "NULLCOLL" $srcLog
echo ''

echo "# Shut down source server and set regions back to the same NULL Collation"
$MUPIP SET -REGION "DEFAULT" -STDNULLCOLL
$MUPIP SET -REGION "AREG" -STDNULLCOLL
echo ''

echo "# Restart source server (expecting no error)"
$gtm_tst/com/SRC.csh "." $portno $start_time >>&! NULLCOLL_RESTART2.out
echo ''
