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
# Tests the Update Process operates correctly when a trigger issues a NEW $ZGBLDIR
# while performing updates on other unreplicated instances
#
$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
$MSR START INST1 INST2
cat > trigx.trg <<EOF
+^a(:) -name=a0 -commands=S -xecute="do trigx^gtm8789"
EOF

cat > trigmumps.trg <<EOF
+^a(:) -name=a0 -commands=S -xecute="do trig^gtm8789"
EOF
set curdir=`pwd`
$MSR RUN INST1 "$MUPIP trigger -trigg=$curdir/trigmumps.trg" >& hide.txt
$MSR RUN INST3 "$MUPIP trigger -trigg=$curdir/trigx.trg" >& hide.txt
$MSR RUN INST4 "$MUPIP trigger -trigg=$curdir/trigx.trg" >& hide.txt
set d3=`cat msr_instance_config.txt |& $grep INST3 |& $grep DBDIR |& $tst_awk '{print $3}'`
echo $d3
set d4=`cat msr_instance_config.txt |& $grep INST4 |& $grep DBDIR |& $tst_awk '{print $3}'`
echo $d4

$MSR RUN INST1 "echo $d3 >>& newdir.txt" >& hide.txt
$MSR RUN INST2 "echo $d4 >>& newdir.txt" >& hide.txt

$MSR RUN INST1 '$ydb_dist/mumps -run gtm8789'


# Dump globals on primary and secondary side
echo "Dumping globals on primary side"; echo "--------------------------------"; $ydb_dist/mumps -run dump^gtm8789
sleep 1 # to ensure stuff is replicated across to secondary
echo "Dumping globals on secondary side"; echo "--------------------------------"; $sec_shell "$sec_getenv; cd $SEC_SIDE; $ydb_dist/mumps -run dump^gtm8789"

