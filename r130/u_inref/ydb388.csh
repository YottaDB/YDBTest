#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that csd->flush_time is correctly auto upgraded and endian converted"
echo "## Test DB auto upgrade issue described at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/696#note_1411319099"
echo "## Test MUPIP ENDIANCVT issue described at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/696#note_1411333276"

echo "# Choose a random prior (including current version) GT.M or YottaDB version"
set prior_ver = `$gtm_tst/com/random_ver.csh -type any`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
echo "$prior_ver" > priorver.txt
echo "# Randomly chosen prior version is : GTM_TEST_DEBUGINFO [$prior_ver]"

echo "# Switch to prior version"
source $gtm_tst/com/switch_gtm_version.csh $prior_ver "pro"

echo "# Creating database using prior V5 version"
\rm -f *.o >& rm1.out	# remove .o files (for .m files) created by current version (in case the format is different)
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate_priorver.out

echo "# Verify DSE DUMP -FILE with prior version shows flush timer is 1 second"
$DSE dump -file |& grep "Flush timer"

echo "# Run MUPIP ENDIANCVT to convert LITTLE endian db (mumps.dat) to BIG endian db (mumps_bigendian.dat)"
yes | $MUPIP endiancvt -override -outdb=mumps_bigendian.dat mumps.dat >& endiancvt1.log

echo "# Switch to current version"
\rm -f *.o >& rm2.out	# remove .o files created by current version (in case the format is different)
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

echo "# Run MUPIP ENDIANCVT to convert BIG endian db (mumps_bigendian.dat) back to LITTLE endian db (mumps_v7.dat)"
yes | $MUPIP endiancvt -override -outdb=mumps_v7.dat mumps_bigendian.dat >& endiancvt2.log

echo "# Create v7.gld to point to mumps_v7.dat"
setenv gtmgbldir v7.gld
$GDE change -segment DEFAULT -file=mumps_v7.dat >& gde.out

echo "# Verify DSE DUMP -FILE with current version still shows flush timer is 1 second"
$DSE dump -file |& grep "Flush timer"

