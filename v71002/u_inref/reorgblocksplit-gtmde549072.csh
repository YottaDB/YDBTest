#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Note that this test is similar to and partially derived from
# v71000/inplaceconv_V6toV7-gtmf13547.
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE549072 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-DE549072)

MUPIP REORG correctly handles block splits at the index level which are caused by a reorg-related block split at a lower-level index or data block. Previously, GT.M would sometimes fail to split these blocks, which prevented the original lower data- or index-level split from taking place. Together, these could prevent REORG from enforcing the provided fill factor and/or reserved bytes setting; a failure which persisted on all subsequent attempts, or until the database structure has changed as a result of new updates. As a workaround, users of previous releases can address a subset of the failures-to-split by passing a slightly different -fill_factor, provided that reserved bytes are disabled. (GTM-DE549072)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"

echo "### Test MUPIP REORG correctly splits blocks according to fill factor in a single pass"
echo "### Note that this test is not a complete test case for the release note, since it was determined"
echo "### that an exact test case would be too time-consuming to come up with, per the thread at:"
echo "### https://gitlab.com/YottaDB/DB/YDBTest/-/issues/685#note_2517977770"
echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log
echo "# Fill 500-543 global nodes with data"
$gtm_dist/mumps -run %XCMD 'for i=1:2:500+$random(43) for j=1:1:100 set ^x(i,j)=$j(i_j,25)'
echo "# Run MUPIP REORG with -index_fill_factor to 50% multiple times, then check the results with MUPIP INTEG"
foreach i (`seq 1 1 5`)
	$gtm_dist/mupip reorg -index_fill_factor=50 -reg "*" >>& reorg.log
	$gtm_dist/mupip integ -reg "*" >>& integ.log
end

echo "# Confirm that 1 block was split on the first pass only"
echo "# Prior to V7.2-002, 0 blocks would be split over an indefinite number of passes."
grep -E "Blocks split +: " reorg.log
echo "# Confirm that less than 50% of the index is used on the first and all subsequent passes."
echo "# Prior to V7.2-002, upwards of 90% of the index would be used over an indefinite number of passes,"
echo "# despite -index_fill_factor being set to 50."
grep Index integ.log | tr -s ' ' | cut -f 4 -d " " | cut -f 1 -d "." | awk '{sum += $1; count += 1} END {if ((sum/count) < 50) print "PASS"; else print "FAIL"}'

$gtm_tst/com/dbcheck.csh >& dbcheck.log
