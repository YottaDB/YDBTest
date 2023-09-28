#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
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

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# This test does a bunch of SETs and creates AIMG records (using DSE MAPS -FREE) and replays them all using
# MUPIP JOURNAL RECOVER -BACKWARD -SINCE. Since backward journal recovery by default applies AIMG records and
# since the total blocks counter is very different between when YottaDB did the SETs vs when backward journal recovery
# does the same updates when ydb_test_4g_db_blks is enabled (due to the giant HOLE), the block numbers allocated for the
# updates end up being very different in the two cases. This means that applying an AIMG record (which captures the physical
# block contents based on the first block layout) in the journal backward recovery case could result in additional integrity
# errors (which show up as "Incorrectly marked free" and "Incorrectly marked busy" integrity errors in different bitmap blocks).
# Therefore the greater than 4Gi db blocks scheme is disabled in this test.
setenv ydb_test_4g_db_blks 0
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP INTEG output
##################################
echo "##########"
echo "First Part"
echo "##########"
unsetenv test_replic
$gtm_tst/com/dbcreate.csh mumps 1 255 1010 1536
$MUPIP set -journal=enable,on,before -reg "*"
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
sleep 1
$GTM << EOF
f i=1:1:1200 s ^a(i,"STR"_i)=\$j(i,800)
h
EOF
cat > dse_maps_cmds.txt << CAT_EOF
maps -block=20 -free
maps -block=22 -free
maps -block=210 -free
maps -block=211 -free
maps -block=211 -busy
maps -block=212 -free
maps -block=410 -free
maps -block=411 -free
quit
CAT_EOF

$DSE < dse_maps_cmds.txt
\mkdir ./bak1; \cp -f *.dat *.mjl* ./bak1
echo ""
echo "Integ for corrupted bitmap"
$MUPIP integ -r "*"
echo ""
echo "$MUPIP journal -recov -backward mumps.mjl -NOAPPLY_AFTER_IMAGE -since=time1"
$MUPIP journal -recov -backward mumps.mjl -NOAPPLY_AFTER_IMAGE -since=\"$time1\"
echo "No Integ Error Expected"
$MUPIP integ -r "*"
if $status exit
\cp ./bak1/* .
echo "$MUPIP journal -recov -backward mumps.mjl -since=time1"
$MUPIP journal -recov -backward mumps.mjl -since=\"$time1\"
echo "Integ Error Expected"
$MUPIP integ -r "*"
\rm -f *.dat
$MUPIP crea
\cp ./bak1/*.mjl* .
echo "Forward recovery does not apply AIMG by default"
echo "$MUPIP journal -recov -forward mumps.mjl"
$MUPIP journal -recov -forward mumps.mjl
echo "No Integ Error Expected"
$MUPIP integ -r "*"
if $status exit
\mv *.mjl* ./bak1
###########################################################
echo "##########"
echo "Second Part"
echo "##########"
source $gtm_tst/com/dbcreate.csh mumps 1 255 1010 1536
$MUPIP set -journal=enable,on,before -reg "*"
$GTM << EOF
f i=1:1:1200 s ^a(i,"STR"_i)=\$j(i,800)
h
EOF
$DSE < dse_maps_cmds.txt
echo ""
echo "Integ for corrupted bitmap"
$MUPIP integ -r "*"
$DSE << EOF
map -res
quit
EOF
\mkdir ./bak2; \cp -f *.dat *.mjl* ./bak2
echo ""
echo "Integ after map -restore"
echo "No Integ Error Expected"
$MUPIP integ -r "*"
if $status exit
$GTM << EOF
d ^verify3
EOF
echo "$MUPIP journal -extract=dsemap.mjf -forward -detail mumps.mjl"
$MUPIP journal -extract=dsemap.mjf -forward -detail mumps.mjl
$MUPIP extract extr1.glo
$tail -n +3  extr1.glo >! data1.glo
echo "$MUPIP journal -recov -back mumps.mjl"
$MUPIP journal -recov -back mumps.mjl
echo "No Integ Error Expected"
$MUPIP integ -r "*"
if $status exit
$MUPIP extract extr2.glo
$tail -n +3  extr2.glo >! data2.glo
diff data1.glo data2.glo
echo "No Integ Error Expected"
$MUPIP integ -r "*"
if $status exit
\rm -f *.dat
$MUPIP crea
\cp ./bak2/*.mjl* .
echo "$MUPIP journal -recov -forward mumps.mjl -APPLY_AFTER_IMAGE"
$MUPIP journal -recov -forward mumps.mjl -APPLY_AFTER_IMAGE
echo "No Integ Error Expected"
$MUPIP integ -r "*"
if $status exit
$MUPIP extract extr3.glo
$tail -n +3  extr3.glo >! data3.glo
diff data1.glo data3.glo
$gtm_tst/com/dbcheck.csh
