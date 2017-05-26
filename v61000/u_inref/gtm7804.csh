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

$gtm_tst/com/dbcreate.csh mumps 1 >& dbcre.out

$MUPIP set -file mumps.dat -mutex_slots=64
# Set flush timer to 1 hour in order to avoid premature grab_crits caused by flush timers
$DSE change -fileheader -flush_time=1:0:0:0

echo "# do launchjobs^gtm7804"
$gtm_exe/mumps -run launchjobs^gtm7804
echo "# do letgo^gtm7804"
$gtm_exe/mumps -run letgo^gtm7804 >& letgo.out
echo "# Mutex queue should not be filled up"
if ("" != `$DSE dump -f -a |& tee dse.out | $grep "Mutex Queue full"`) then
    echo "TEST-E-FAILED mutex queue is full."
endif
$gtm_tst/com/dbcheck.csh
