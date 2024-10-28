#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

#
# Tests the Update Process operates correctly when a trigger issues a NEW $ZGBLDIR
# while performing updates on other unreplicated instances
#
$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps 1 -gld_has_db_fullpath>>& dbcreate.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate.out
	exit -1
endif
$MSR START INST1 INST2
# Uploading triggers, trig will occur on instance 1 (and will be replicated by instance 2), trigx will occur on instance 3 and 4
cat > trigx.trg <<EOF
+^a(:) -name=a0 -commands=S -xecute="do trigx^ydb293"
EOF

cat > trigmumps.trg <<EOF
+^a(:) -name=a0 -commands=S -xecute="do trig^ydb293"
EOF
set curdir=`pwd`
$MSR RUN INST1 "$MUPIP trigger -trigg=$curdir/trigmumps.trg" >& hide.txt
$MSR RUN INST3 "$MUPIP trigger -trigg=$curdir/trigx.trg" >& hide.txt
$MSR RUN INST4 "$MUPIP trigger -trigg=$curdir/trigx.trg" >& hide.txt
set d3=`cat msr_instance_config.txt |& $grep INST3 |& $grep DBDIR |& $tst_awk '{print $3}'`
set d4=`cat msr_instance_config.txt |& $grep INST4 |& $grep DBDIR |& $tst_awk '{print $3}'`
# Giving Instance 1 and Instance 2 a way to access the .gld file of Instance 3 and Instance 4
$MSR RUN INST1 "echo $d3 >>& newdir.txt" >& hide.txt
$MSR RUN INST2 "echo $d4 >>& newdir.txt" >& hide.txt
if ("ENCRYPT" == "$test_encryption" ) then
	set d2=`cat msr_instance_config.txt |& $grep INST2 |& $grep DBDIR |& $tst_awk '{print $3}'`
	head -n -3 $gtmcrypt_config > $gtmcrypt_config.merged
	foreach inst (INST2 INST3 INST4)
		echo "        }," >> $gtmcrypt_config.merged
		$MSR RUN $inst "cat $gtmcrypt_config" | tail -6 | head -3 >> $gtmcrypt_config.merged
	end
	tail -n 3 $gtmcrypt_config >> $gtmcrypt_config.merged
	mv $gtmcrypt_config $gtmcrypt_config.orig
	mv $gtmcrypt_config.merged $gtmcrypt_config
	mv $d2/$gtmcrypt_config $d2/$gtmcrypt_config.orig
	cp $gtmcrypt_config $d2
endif
echo ""
$MSR RUN INST1 '$ydb_dist/mumps -run ydb293'


# Dump globals on primary and secondary side
echo "Dumping globals on primary side"; echo "--------------------------------"; $ydb_dist/mumps -run dump^ydb293

$MSR SYNC INST1 INST2 # to ensure stuff is replicated across to secondary before dumping globals on secondary side
echo "Dumping globals on secondary side"; echo "--------------------------------"; $sec_shell "$sec_getenv; cd $SEC_SIDE; $ydb_dist/mumps -run dump^ydb293"

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck.out
	exit -1
endif

