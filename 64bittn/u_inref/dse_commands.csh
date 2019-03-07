#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2005, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
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

echo "====================   DSE DUMP -BLOCK   ===================="
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$DSE change -fileheader -current_tn=123456789ABF
$GTM << gtm_eof
set ^x=1
halt
gtm_eof

$DSE dump -block=1 -header						# the output should have V6 as version and 0 as transaction number
$DSE dump -block=2 -header						# the output should have V6 as version and 123456789ABF  as transaction number
$DSE dump -fileheader |& $tst_awk '/Current transaction/ { print $1,$2,$3}'

$MUPIP integ -tn_reset mumps.dat
$MUPIP reorg -downgrade -region DEFAULT

$DSE dump -block=1 -header						# the output should have V4 as version
$DSE dump -block=2 -header						# the output should have V4 as version

$gtm_tst/com/dbcheck.csh -noonline
$gtm_tst/com/backup_dbjnl.csh dse_dump_block

echo "====================   DSE CHANGE -BLOCK   ===================="
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << gtm_eof
set ^x=1
halt
gtm_eof

$DSE change -block=4 -tn=abCdEf123456789
$DSE dump -block=4 -header						# TN should be ABCDEF123456789
$DSE change -block=4 -tn=fedcba
$MUPIP reorg -downgrade -region DEFAULT
$DSE << dse_eof
change -block=4 -tn=abCdEf123456789
dump -block=4 -header
quit
dse_eof
$DSE dump -block=4 -header						# TN should be "0x23456789"

echo "=================== Section moved from v44003/u_inref/D9D07002349.csh ========================"
echo ""
$DSE << dse_eof
change -block=0 -tn=0
dump -block=0 -header
change -block=0 -tn=1
dump -block=0 -header
change -block=0 -tn=7fffffff
dump -block=0 -header
change -block=0 -tn=80000000
dump -block=0 -header
change -block=0 -tn=ffffffff80000001
dump -block=0 -header
change -block=0 -tn=fffffffffffffffe
dump -block=0 -header
change -block=0 -tn=ffffffffffffffff
dump -block=0 -header
dse_eof
echo "=================== Section from v44003/u_inref/D9D07002349.csh ends ========================="

$gtm_tst/com/dbcheck.csh -noonline
$gtm_tst/com/backup_dbjnl.csh dse_change_block

echo "====================   DSE CHANGE -FILEHEADER   ===================="
echo ""
echo "====================   BLKS_TO_UPGRADE   ===================="
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$DSE change -fileheader -blks_to_upgrade=abCdEf12
$DSE dump -fileheader |& $tst_awk '/Blocks to Upgrade/ { print $5,$6,$7,$8}'		#Blocks to Upgrade should be ABCDFE12
$DSE change -fileheader -blks_to_upgrade=0


echo "====================   CERT_DB_VER   ===================="
echo ""
$DSE change -fileheader -cert_db_ver="V4"
$DSE dump -fileheader |&  $tst_awk '/Certified for Upgrade to/ { print $4,$5,$6,$7,$8}'	# should be V4
$DSE change -fileheader -cert_db_ver="V6"
$DSE dump -fileheader |&  $tst_awk '/Certified for Upgrade to/ { print $4,$5,$6,$7,$8}'	# should be V6
$DSE change -fileheader -cert_db_ver="V7"  						# should issue an error since only accepted value is V4 or V6
$DSE change -fileheader -cert_db_ver="V3"  						# should issue an error since only accepted value is V4 or V6
$DSE dump -fileheader |&  $tst_awk '/Certified for Upgrade to/ { print $4,$5,$6,$7,$8}'	# should be V6


echo "====================   DB_WRITE_FMT   ===================="
echo ""
$DSE dump -fileheader |&  $tst_awk '/Desired DB Format/ { print $5,$6,$7,$8}'	# should be V6
$DSE change -fileheader -db_write_fmt="V4"
$DSE dump -fileheader |&  $tst_awk '/Desired DB Format/ { print $5,$6,$7,$8}'	# should be V4
$DSE change -fileheader -db_write_fmt="V6"
$DSE dump -fileheader |&  $tst_awk '/Desired DB Format/ { print $5,$6,$7,$8}'	# should be V6
$DSE change -fileheader -db_write_fmt="V7"					# Should issue error message since only accepted values is V4 or V6
$DSE change -fileheader -db_write_fmt="V3"					# Should issue error message since only accepted values is V4 or V6

echo "====================   MBM_SIZE   ===================="
echo ""
$DSE dump -fileheader |&  $tst_awk '/Master Bitmap Size/ { print $1,$2,$3,$4}'	# should display 64
$DSE change -fileheader -mbm_size=abe0						# should issue "%YDB-E-CLIERR, Unrecognized value: abe0, Decimal number expected"
$DSE dump -fileheader |&  $tst_awk '/Master Bitmap Size/ { print $1,$2,$3,$4}'	# should display 64
$DSE change -fileheader -mbm_size=32
$DSE dump -fileheader |&  $tst_awk '/Master Bitmap Size/ { print $1,$2,$3,$4}'	# should display 32


echo "====================   MAX_TN and WARN_MAX_TN in V6 mode   ===================="
echo ""
$DSE dump -fileheader |& $grep "Maximum TN"		# should be 0xFFFFFFFFDFFFFFFF and 0xFFFFFFFF5FFFFFFF
$DSE change -fileheader -max_tn=FFFFFFFFF0000000	# should not issue "MAX_TN specified is too large" message
$DSE change -fileheader -max_tn=FFFFFFFF		# shoule issue "MAX_TN cannot be lesser than WARN_MAX_TN"
$DSE dump -fileheader |& $grep "Maximum TN"		# should be 0xFFFFFFFFF0000000 and 0xFFFFFFFF5FFFFFFF
$DSE change -fileheader -max_tn=FFFFFFFFEFFFFFFF
$DSE change -fileheader -current_tn=FFFFFFFD00000000
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be 0xFFFFFFFF00000000(cur), 0xFFFFFFFFEFFFFFFF(max) and 0xFFFFFFFF5FFFFFFF(warn)
$DSE change -fileheader -max_tn=FFFFFFF000000000	# Should issue "MAX_TN cannot be lesser than WARN_MAX_TN"
$DSE change -fileheader -current_tn=1
$DSE change -fileheader -max_tn=FFFFFFF000000000	# Should issue "MAX_TN cannot be lesser than WARN_MAX_TN"
$DSE change -fileheader -warn_max_tn=FFFFFFE000000000
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be 0x0000000000000001(cur), 0xFFFFFFFFEFFFFFFF(max) and 0xFFFFFFE000000000(warn)
$DSE change -fileheader -max_tn=FFFFFFDFFFFFFFFF	# should still issue "MAX_TN cannot be lesser than WARN_MAX_TN"
$DSE change -fileheader -max_tn=FFFFFFE000000000	# should work fine without any issues
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be 0x00000000 00000001(cur), 0xFFFFFFE0 00000000(max) and 0xFFFFFFE0 00000000(warn)

$DSE change -file -warn_max_tn=FFFFFFE000000001		# should issue "WARN_MAX_TN cannot be greater than MAX_TN"
$DSE change -file -current_tn=FFFFFFE000000000		# should work fine without any errors
$DSE change -file -warn_max_tn=FFFFFFDFFFFFFFFF		# should issue "WARN_MAX_TN cannot be lesser than CURR_TN"
$DSE change -file -current_tn=FFFFFFD000000000		# should work fine without any errors
$DSE change -file -warn_max_tn=FFFFFFD000000001
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be 0xFFFFFFDO 00000000(cur), 0xFFFFFFE0 00000000(max) and 0xFFFFFFDO 00000001(warn)
$DSE change -file -current_tn=FFFFFFD000000002		# should issue "CURR_TN cannot be greater than WARN_MAX_TN"
$DSE change -file -warn_max_tn=FFFFFFD000000000
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be 0xFFFFFFDO 00000000(cur), 0xFFFFFFE0 00000000(max) and 0xFFFFFFDO 00000000(warn)

$GTM << gtm_eof
set ^x=1
halt
gtm_eof
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be 0xFFFFFFDO 00000001(cur), 0xFFFFFFE0 00000000(max) and 0xFFFFFFD8 00000000(warn)
$DSE change -file -max_tn=FFFFFFF000000000
$DSE change -file -warn_max_tn=FFFFFFEFFFFFFFFF
$DSE change -file -current_tn=FFFFFFEFFFFFFFFF
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be FFFFFFEFFFFFFFFF(cur), FFFFFFF000000000(max) and FFFFFFEFFFFFFFFF(warn)
$GTM <<gtm_eof
set ^x=1
halt
gtm_eof
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"	# should be 0xFFFFFFF0 00000000(cur), 0xFFFFFFF0 00000000(max) and 0xFFFFFFF0 00000000(warn)
$GTM <<gtm_eof
set ^x=1
halt
gtm_eof
	#should issue YDB-E-TNTOOLARGE error

$gtm_tst/com/dbcheck.csh -noonline
$gtm_tst/com/backup_dbjnl.csh dse_change_fileheader

echo "====================   MAX_TN and WARN_MAX_TN in Compatibility mode   ===================="
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$DSE change -fileheader -db_write_fmt="V4"
$DSE dump -fileheader |& $grep "Maximum TN"			# should be 0xFFFFFFFFDFFFFFFF and 0xFFFFFFFF5FFFFFFF
$MUPIP set -region DEFAULT -version=V4
$DSE dump -fileheader |& $grep "Maximum TN"			# should be 0x00000000F7FFFFFF and 0x00000000D7FFFFFF
$DSE change -file -warn_max_tn=00000000F7FFFFFF
$DSE change -fileheader -current_tn=00000000F7FFFFFF
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# All the three values should be 0x00000000 F7FFFFFF
$GTM << gtm_eof
set ^x=1
halt
gtm_eof
	# should issue YDB-E-TNTOOLARGE error

$DSE change -fileheader -current_tn=00000000F5FFFFFF
$DSE change -fileheader -warn_max_tn=00000000F5FFFFFF
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"

$GTM << gtm_eof
set ^x=1
halt
gtm_eof
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"
$DSE change -fileheader -current_tn=00000000F6FFFFFF

$GTM << gtm_eof
set ^x=1
halt
gtm_eof
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"

$DSE change -fileheader -max_tn=00000000F77FFFFE			# should issue "MAX_TN cannot be lesser than WARN_MAX_TN"
$DSE change -fileheader -max_tn=FFFFFFFFFFFFFFFF			# should work fine without any errors

$gtm_tst/com/dbcheck.csh -noonline
$gtm_tst/com/backup_dbjnl.csh max_tn_comp_mode

echo "====================   MAX_TN, WARN_MAX_TN and CURRENT_TN mixed in the same command line   ===================="
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$DSE change -fileheader -current_tn=FFFFFFFF74000000
$DSE change -fileheader -current_tn=100 -warn_max_tn=59 -max_tn=10
$DSE change -fileheader -current_tn=FFFFFFFFFFFFFFFF -max_tn=1
	#should issue error in all the cases
$MUPIP set -version=v4 -region "*"
$DSE change -fileheader -warn_max_tn=F7FFFFF0
$DSE change -fileheader -current_tn=F7FFFFF0
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x00000000 F7FFFFF0(cur) 0x00000000 F7FFFFF0(max) 0x00000000 F7FFFFFF(warn)

$gtm_tst/com/dbcheck.csh -noonline
$gtm_tst/com/backup_dbjnl.csh max_tn_same_command

echo "====================   DSE CHANGE -FILEHEADER transaction fields  ===================="
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$DSE change -fileheader -current_tn=fedcba1FEDCBA35
$DSE change -fileheader -zqgblmod_tn=edcba1FEDCBA35
$DSE change -fileheader -zqgblmod_seqno=dcba1FEDCBA35
$DSE change -fileheader -b_bytestream=cba1FEDCBA35
$DSE change -fileheader -b_database=ba1FEDCBA35
$DSE change -fileheader -b_record=fffffff7FEDCBA35
$DSE dump -fileheader >&! dse_dump.txt
$tst_awk '/Current transaction/ { print $1,$2,$3}' dse_dump.txt
$tst_awk '/Zqgblmod Trans/ { print $4,$5,$6}' dse_dump.txt
$tst_awk '/Zqgblmod Seqno/ { print $1,$2,$3}' dse_dump.txt
$tst_awk '/Last Bytestream Backup/ { print $1,$2,$3,$4}' dse_dump.txt
$tst_awk '/Last Database Backup/ { print $1,$2,$3,$4}' dse_dump.txt
$tst_awk '/Last Record Backup/ { print $1,$2,$3,$4}' dse_dump.txt

$DSE change -fileheader -b_incremental=1FEDCBA35
$DSE change -fileheader -b_comprehensive=a1FEDCBA35
$DSE dump -fileheader >&! dse_dump_2.txt
$tst_awk '/Last Bytestream Backup/ { print $1,$2,$3,$4}' dse_dump_2.txt
$tst_awk '/Last Database Backup/ { print $1,$2,$3,$4}' dse_dump_2.txt

$DSE change -fileheader -db_write_fmt="V4"
$DSE change -fileheader -current_tn=FFFFFFFF
$DSE change -fileheader -zqgblmod_tn=FFFFFFFF
$DSE change -fileheader -zqgblmod_seqno=FFFFFFFF
$DSE change -fileheader -b_bytestream=FFFFFFFF
$DSE change -fileheader -b_database=FFFFFFFF
$DSE change -fileheader -b_record=FFFFFFFF
$DSE change -fileheader -b_incremental=FFFFFFFF
$DSE change -fileheader -b_comprehensive=FFFFFFFF
$DSE dump -fileheader >&! dse_dump_3.txt
$tst_awk '/Current transaction/ { print $1,$2,$3}' dse_dump_3.txt
$tst_awk '/Zqgblmod Trans/ { print $4,$5,$6}' dse_dump_3.txt
$tst_awk '/Zqgblmod Seqno/ { print $1,$2,$3}' dse_dump_3.txt
$tst_awk '/Last Bytestream Backup/ { print $1,$2,$3,$4}' dse_dump_3.txt
$tst_awk '/Last Database Backup/ { print $1,$2,$3,$4}' dse_dump_3.txt
$tst_awk '/Last Record Backup/ { print $1,$2,$3,$4}' dse_dump_3.txt

$DSE change -fileheader -current_tn=0000000100000000
$DSE change -fileheader -zqgblmod_tn=0000000100000001
$DSE change -fileheader -zqgblmod_seqno=00000FFFFFFFFFFF
$DSE change -fileheader -b_bytestream=0000FFFFFFFFFFFF
$DSE change -fileheader -b_database=000FFFFFFFFFFFFF
$DSE change -fileheader -b_record=00FFFFFFFFFFFFFF
$DSE change -fileheader -b_incremental=0FFFFFFFFFFFFFFF
$DSE change -fileheader -b_comprehensive=FFFFFFFFFFFFFFFF
$DSE dump -fileheader >&! dse_dump_4.txt
$tst_awk '/Current transaction/ { print $1,$2,$3}' dse_dump_4.txt
$tst_awk '/Zqgblmod Trans/ { print $4,$5,$6}' dse_dump_4.txt
$tst_awk '/Zqgblmod Seqno/ { print $1,$2,$3}' dse_dump_4.txt
$tst_awk '/Last Bytestream Backup/ { print $1,$2,$3,$4}' dse_dump_4.txt
$tst_awk '/Last Database Backup/ { print $1,$2,$3,$4}' dse_dump_4.txt
$tst_awk '/Last Record Backup/ { print $1,$2,$3,$4}' dse_dump_4.txt


echo "====================   DSE EVAL   ===================="
echo ""
$DSE eval -number=FFFFFFFFFFFFFFFF |& $grep Hex
$DSE eval -decimal -number=FFFFFFFFFFFFFFFF			# should issue "Error: cannot convert ffffffffffffffff string to number."
$DSE eval -hex -number=FFFFFFFFFFFFFFFF |& $grep Hex
$DSE eval -number=0000000FFFFFFFFF |& $grep Hex
$DSE eval -number=0000FFFFFFFFFFFF |& $grep Hex

$gtm_tst/com/dbcheck.csh -noonline
