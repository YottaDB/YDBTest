#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2007, 2013 Fidelity Information Services, Inc	#
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
#
# This is unicode version of mupip_backup subtest
#
@ bno = 0
setenv cur_dir `pwd`
@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
#
echo "MUPIP BACKUP and SET JOURNAL .."
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
set dbbase="αβγδε"
setenv gtmgbldir $dbbase.gld
source $gtm_tst/com/dbcreate.csh $dbbase 3 200 1000
$MUPIP set -journal=enable,nobefore -reg "*" |& sort -f
$GTM << bkup
d in1^pfill("set",2)
h
bkup

# In case of spanning regions filter out Transaction numbers which are non-deterministic;
# To be sure check the total number of transactions. Note that the total might be off by 1
# in case the spanning regions mapping distribution (which is chosen randomly) is so even
# that mumps.dat does not need to extend (and hence one transaction # fewer there).
# Hence the check for 4521 or 4522 total tn#.
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set filterit = '%YDB-I-BACKUPTN, Transactions from'
else
	set filterit = 'NOTHINGTOFILTEROUT'
endif
alias trcount '$tst_awk '"'"'/%YDB-I-BACKUPTN, Transactions from/ {tot=tot+strtonum($6)} END{if ( (tot != 4521) && (tot != 4522) ) {print "TEST-E-TNCOUNT Total # of transactions backed up were expected to be 4521 or 4522, but it was ",tot}}'"'"' '
#
echo "============================================================="
#
echo Test Case 44
# NEWJNLFILES is default with mupip backup command
#
echo "NEWJNLFILES option"
$MUPIP backup "*" $bkp_dir >&! mupip_backup_TC44.out
sort mupip_backup_TC44.out |& $grep -v "$filterit"
trcount mupip_backup_TC44.out
$MUPIP << mytag >& header_dump1.txt
journal -show=header -forward αβγδε.mjl
mytag
set prev_jnl = `$tst_awk '/Prev journal file name/ {print $5}' header_dump1.txt`
if ($prev_jnl == "") then
	echo "Prev journal file should not be empty"
endif
#
@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -newjnlfiles "*" $bkp_dir >&! mupip_backup_newjnlfiles_${bno}.out
sort mupip_backup_newjnlfiles_${bno}.out |& $grep -v "$filterit"
trcount mupip_backup_newjnlfiles_${bno}.out

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -newjnlfiles=prevlink "*" $bkp_dir >&! mupip_backup_newjnlfiles_${bno}.out
sort mupip_backup_newjnlfiles_${bno}.out |& $grep -v "$filterit"
trcount mupip_backup_newjnlfiles_${bno}.out

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -newjnlfiles=noprevlink "*" $bkp_dir >&! mupip_backup_newjnlfiles_${bno}.out
sort mupip_backup_newjnlfiles_${bno}.out |& $grep -v "$filterit"
trcount mupip_backup_newjnlfiles_${bno}.out

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP journal -show=header -forward αβγδε.mjl
echo "============================================================="
#
echo Test Case 45
#
echo "NO_NEWJNLFILES"
$MUPIP backup -nonewjnlfiles "*" $bkp_dir >&! mupip_backup_TC45.out
sort mupip_backup_TC45.out |& $grep -v "$filterit"
trcount mupip_backup_TC45.out

echo "============================================================="
#
echo Test Case 46
#
# Note V43001 has a bug of printing same file name for this qualifier. Please change reference file after S/W fix. Layek - 4/25/02
echo "BKUPDBJNL qualifier"
@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -bkupdbjnl="ＡＢＣＤ" "*" $bkp_dir
@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -bkupdbjnl="DISABLE,OFF" "*" $bkp_dir

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -bkupdbjnl="DISABLE" "*" $bkp_dir >&!  mupip_backup_TC46_{$bno}.out
sort mupip_backup_TC46_${bno}.out |& $grep -v "$filterit"
trcount mupip_backup_TC46_${bno}.out

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -bkupdbjnl="OFF" "*" $bkp_dir >&! mupip_backup_TC46_{$bno}.out
sort mupip_backup_TC46_${bno}.out |& $grep -v "$filterit"
trcount mupip_backup_TC46_${bno}.out

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
#
$MUPIP backup -noon -bkupdbjnl="ＡＢＣＤ" "*" $bkp_dir
@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -noon -bkupdbjnl="DISABLE,OFF" "*" $bkp_dir

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -noon -bkupdbjnl="DISABLE" "*" $bkp_dir >&!  mupip_backup_TC46_{$bno}.out
sort mupip_backup_TC46_${bno}.out |& $grep -v "$filterit"
trcount mupip_backup_TC46_${bno}.out

@ bno = $bno + 1; \mkdir $cur_dir/αβγδε我能吞{$bno} ; setenv bkp_dir "$cur_dir/αβγδε我能吞{$bno}"
$MUPIP backup -noon -bkupdbjnl="OFF" "*" $bkp_dir >&!  mupip_backup_TC46_{$bno}.out
sort mupip_backup_TC46_${bno}.out |& $grep -v "$filterit"
trcount mupip_backup_TC46_${bno}.out

$GTM << bkup
d in1^pfill("ver",2)
h
bkup
echo "============================================================="
$gtm_tst/com/dbcheck.csh
