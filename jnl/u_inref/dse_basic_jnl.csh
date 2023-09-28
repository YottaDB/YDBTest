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
unsetenv test_replic
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP INTEG and DSE output

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

$gtm_tst/com/dbcreate.csh mumps 1 255 1010 1536
$MUPIP set -journal=enable,on,before,epoch=30 -reg "*"
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
$GTM << EOF
f i=1:1:4 s ^a(i)="PRE"_\$j(i,10)_"POSR"
h
EOF
$DSE << EOF
f -bl=3
rem -rec=3
d -bl=3
add -rec=3 -key="^a(""NewKey"")" -data="New Record Added"
d -bl=3
q
EOF
$MUPIP integ -reg "*"
$DSE << EOF
f -bl=3
rem -rec=4
d -bl=3
q
EOF
$MUPIP integ -reg "*"
$MUPIP journal -extract=dse.mjf -forward -detail mumps.mjl
$GTM << EOF
w "Analyzing detailed journal extract",!
d ^jnlext("PBLK","TN",8,"dse.mjf")
d ^jnlext("PBLK","BLOCK ID",6,"dse.mjf")
d ^jnlext("PBLK","SIZE",7,"dse.mjf")
d ^jnlext("AIMG","TN",3,"dse.mjf")
d ^jnlext("AIMG","BLOCK ID",6,"dse.mjf")
d ^jnlext("AIMG","SIZE",7,"dse.mjf")
h
EOF
echo "mupip journal -recov -noverify -back mumps.mjl -since=time1"
$MUPIP journal -recov -noverify -back mumps.mjl -since=\"$time1\"
$DSE << EOF
d -bl=3
q
EOF
$gtm_tst/com/backup_dbjnl.csh backup "*.dat" mv
$MUPIP crea
echo "mupip journal -recov -forward mumps.mjl -APPLY_AFTER_IMAGE"
$MUPIP journal -recov -forward mumps.mjl -APPLY_AFTER_IMAGE |& $grep -v MUJNLPREVGEN
$DSE << EOF
d -bl=3
q
EOF

echo "The end of dse_basic_jnl"
$gtm_tst/com/dbcheck.csh
