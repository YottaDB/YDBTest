#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

echo '# MUPIP SET {-FILE|-REGION} accepts -TRIGGER_FLUSH=n and -WRITES_PER_FLUSH=n qualifiers; previously only DSE supported these qualifiers'
echo '# Also, the trigger_flush value appears in MUPIP DUMPFHEAD as flush_trigger_top (original GTM was trigger_flush_top) and acts as a stable limit; previously GT.M tended to lose any user supplied value as it made adjustments intended to improve performance'

$gtm_tst/com/dbcreate.csh mumps

echo '# Setting -TRIGGER_FLUSH=777 on -reg "*"'
$gtm_dist/mupip set -trigger_flush=777 -reg "*"
echo '# Setting -WRITES_PER_FLUSH=42 on -reg "*"'
$gtm_dist/mupip set -WRITES_PER_FLUSH=42 -reg "*"

echo '# Greping MUPIP DUMPFHEAD for flush_trigger_top should be set to 777'
$gtm_dist/mupip dumpfhead -reg "*" | grep "flush_trigger_top"

$gtm_tst/com/dbcheck.csh
