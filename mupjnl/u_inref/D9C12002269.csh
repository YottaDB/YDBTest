#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$gtm_tst/com/dbcreate.csh -block_size=1024 -allocation=2048 -global_buffer_count=64 -ext=100 -record_size=4000
#
$MUPIP set -journal="enable,on,before,auto=16384,alloc=2048,exten=1024" -reg "*"
#
$GTM << EOF
 	d ^d002269
EOF
$MUPIP reorg
$MUPIP reorg -fill=80
$gtm_tst/com/db_extract.csh data1.glo
#
# note down the database size
set dsize=`ls -l mumps.dat | $tst_awk '{split($0,items," "); print items[5]}'`
# save all the original database files
mkdir ./save
cp mumps.* ./save
#
echo "Applying all journal files ......"
rm mumps.dat
$MUPIP create
# jnlprevgener.csh gives list of journal files starting from latest generation mumps.mjl upto the earliest generation
# we want the files in exactly the other order so use file_reverse.awk # BYPASSOK
set fileset=`$gtm_tst/com/jnl_prevlink.csh -all -f mumps.mjl | $tst_awk -f $gtm_tst/com/file_reverse.awk`
foreach mfile ($fileset)
  $MUPIP journal -recover -for $mfile >>& rec_for.log
  set stat=$status
  if ($stat != 0) then
	echo "D9C12-002269 TEST FAILED"
	cat rec_for.log
	exit 1
  endif
end
$gtm_tst/com/db_extract.csh data2.glo
echo "diff data1.glo data2.glo"
$tst_cmpsilent data1.glo data2.glo
if ($status) echo "TEST falied in MUPIP recover"
#
echo "Applying all journal files in larger alloc size......"
rm mumps.dat
$GDE change -segment DEFAULT -alloc=$dsize
$MUPIP create
foreach mfile ($fileset)
  $MUPIP journal -recover -for $mfile >>& rec_for2.log
  set stat=$status
  if ($stat != 0) then
	echo "D9C12-002269 TEST FAILED"
	cat rec_for2.log
	exit 1
  endif
end
$gtm_tst/com/db_extract.csh data3.glo
echo "diff data1.glo data3.glo"
$tst_cmpsilent data1.glo data3.glo
if ($status) echo "TEST falied in MUPIP recover"
#
$gtm_tst/com/dbcheck.csh
