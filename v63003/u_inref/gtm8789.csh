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
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
cat > trigx.trg <<EOF
+^a(:) -name=a0 -commands=S -xecute="do trigx^gtm8789"
EOF

cat > trigmumps.trg <<EOF
+^a(:) -name=a0 -commands=S -xecute="do trig^gtm8789"
EOF

# Setup primary
#rm -f *.gld *.dat *.mjl* *.log* *.repl*
echo "setup primary"
setenv gtmgbldir x.gld
$GDE change -segment DEFAULT -file=x.dat
$MUPIP create
$MUPIP trigger -noprompt -trigg=trigx.trg
$MUPIP set -replication=on -reg "*"
setenv gtmgbldir mumps.gld
$GDE change -segment DEFAULT -file=mumps.dat
#setenv gtm_repl_instance mumps.repl; $MUPIP replicate -instance -name=INSTA
$MUPIP set -replication=on -reg "*"
#@ port = 5001
#$MUPIP replic -source -start -secondary=${HOST}:$port -log=source.log -buf=1 -instsecondary=INSTB -jnlfileonly

echo "# Setup secondary"
#rm -rf tmp; mkdir tmp
#cp gtm8789.m trigmumps.trg trigx.trg tmp # Copy some stuff over to secondary side too
#cd tmp
#rm -f *.gld *.dat *.mjl* *.log* *.repl*
#setenv gtmgbldir x.gld; gde change -segment DEFAULT -file=x.dat; $MUPIP create; $MUPIP trigger -noprompt -trigg=trigx.trg
#setenv gtmgbldir mumps.gld; gde change -segment DEFAULT -file=mumps.dat; $MUPIP create
#setenv gtm_repl_instance mumps.repl; $MUPIP replicate -instance -name=INSTB
#$MUPIP set -replication=on -reg "*"
#$MUPIP replic -source -start -passive -log=passive_source.log -buf=1 -instsecondary=INSTA
#$MUPIP replic -receiv -start -listen=$port -log=receiver.log -buf=2097152
#cd ..



# Back to primary side
$MUPIP trigger -noprompt -trigg=trigmumps.trg
$ydb_dist/mumps -run gtm8789

# Dump globals on primary and secondary side
echo "Dumping globals on primary side"; echo "--------------------------------"; $ydb_dist/mumps -run dump^gtm8789
sleep 1 # to ensure stuff is replicated across to secondary
echo "Dumping globals on secondary side"; echo "--------------------------------"; $sec_shell "$sec_getenv; cd $SEC_SIDE; $ydb_dist/mumps -run dump^gtm8789"

