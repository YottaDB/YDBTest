#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2013 Fidelity Information Services, Inc	#
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
#
echo ENTERING ONLINE1
#
#
setenv gtmgbldir online.gld
setenv bkp_dir "`pwd`/online1"
setenv bkp_dir_2 "`pwd`/online2"
setenv long_dir "`pwd`/extremely_very_very_long_directory_name_for_testing/another_medium_sized_directory_name/online1"
mkdir -p $bkp_dir $bkp_dir_2 $long_dir
chmod 777 $bkp_dir $bkp_dir_2 $long_dir
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set grepit = 'BACKUP|DB file'
else
	set grepit = 'BACKUP|backed up'
endif
alias trcount '$tst_awk '"'"'/Transactions up to/ {tot=tot+strtonum($4)} END{ print "Total number of transactions backed up: ",tot}'"'"' $1'
#
#
# ================================== Basic Backup ================================== #
#
#
$gtm_tst/com/dbcreate.csh online 4 125 700 1536 100 256
#
# ------------- comprehensive record onine ----------------- #
#
$GTM << aaaa
w "Do fill1^myfill(""set"")",!
d fill1^myfill("set")
h
aaaa
# Journaling might be enabled or disabled randomly (by dbcreate.csh).
# So redirect the output and grep only for the relevant lines
# Sort the output, since it is a multi-region output

$MUPIP backup -c -rec -o DEFAULT $bkp_dir >&! backup_default.out
if ( $status != 0 ) then
    echo ERROR
    exit 1
endif
$grep -E "$grepit" backup_default.out |& sort -f

echo "This should error:"
$MUPIP backup -c -rec -o DEFAULT $bkp_dir
echo "This should error:"
# The below output will have YDB-E-FILEEXISTS and YDB-E-MUNOACTION.
# To prevent errorcatching mechanism from reporting at the end, lets redirect it to outx.
# Since the entire contents of the file is printed here, it is safe to redirect it to outx
$MUPIP backup -c -o "*" $bkp_dir >&! backup_star_error.outx
sort -f backup_star_error.outx
echo "This should REPLACE:"
$MUPIP backup -replace -c -o "*" $bkp_dir >&! backup_star.out
$grep -E "$grepit" backup_star.out |& sort -f
trcount backup_star.out

echo "Clean up"
rm $bkp_dir/*
echo "Backup again:"
$MUPIP backup -c -o "*" $bkp_dir >&! backup_again.out
if ( $status != 0 ) then
    echo ERROR
    exit 1
endif
$grep -E "$grepit" backup_again.out |& sort -f
trcount backup_again.out

echo "This should error:"
# The below output will have YDB-E-FILEEXISTS and YDB-E-MUNOACTION.
# to prevent errorcatching mechanism from reporting at the end, lets redirect it to outx
# since the entire contents of the file is printed here, it is safe to redirect it to outx
$MUPIP backup -c -o "*" $bkp_dir >&! backup_again_error.outx
sort -f backup_again_error.outx
echo "This should REPLACE:"
$MUPIP backup -c -o -REPLACE "*" $bkp_dir >&! backup_again_replace.out
$grep -E "$grepit" backup_again_replace.out |& sort -f
trcount backup_again_replace.out

$gtm_tst/com/dbcheck.csh

#Tests related to code changes done for -replace option
rm $bkp_dir/*
echo "Target does not exist and replace qualifier NOT specified"
$MUPIP backup -c -rec -o DEFAULT $bkp_dir >&! backup_default.out
$grep -E "$grepit" backup_default.out |& sort -f
rm $bkp_dir/*
echo "Target does not exist and replace qualifier specified. Ignore bkp_dir_2"
$MUPIP backup -c -rec -o -replace DEFAULT $bkp_dir,$bkp_dir_2 >&! backup_default.out
$grep -E "$grepit" backup_default.out |& sort -f
echo "Target exists and replace qualifier NOT specified"
$MUPIP backup -c -rec -o DEFAULT $bkp_dir >&! backup_default.out
sort -f  backup_default.out
echo "Target exists and replace qualifier specified"
$MUPIP backup -c -rec -o -replace DEFAULT $bkp_dir >&! backup_default.out
$grep -E "$grepit" backup_default.out |& sort -f

rm $bkp_dir/*
echo "Target does not exist and individual files specified. No replace qualifier"
$MUPIP backup -c -rec -o AREG,BREG $bkp_dir/a.dat,$bkp_dir/b.dat >&! backup_all.out
$grep -E "$grepit" backup_all.out |& sort -f
echo "Target exists and individual files specified. No replace qualifier"
$MUPIP backup -c -rec -o AREG,BREG $bkp_dir/a.dat,$bkp_dir/b.dat >&! backup_all.outx
sort -f backup_all.outx
echo "Target exists and individual files specified. replace qualifier specified"
$MUPIP backup -c -rec -o -replace AREG,BREG $bkp_dir/a.dat,$bkp_dir/b.dat >&! backup_all.out
$grep -E "$grepit" backup_all.out |& sort -f

rm $bkp_dir/*
echo "Target does not exist, region is * and replace qualifier NOT specified"
$MUPIP backup -c -rec -o "*" $bkp_dir >&! backup_star.out
$grep -E "$grepit" backup_star.out |& sort -f
echo "Target exists, region is * and replace qualifier NOT specified"
$MUPIP backup -c -rec -o "*" $bkp_dir >&! backup_star.out
sort -f backup_star.out
echo "Target exists, region is * and replace qualifier specified"
$MUPIP backup -c -rec -o -replace "*" $bkp_dir >&! backup_star.out
$grep -E "$grepit" backup_star.out |& sort -f
trcount backup_star.out

rm $bkp_dir/*
echo "Target does not exist and is a combination of files/directories"
$MUPIP backup -c -rec -o AREG,BREG,CREG $bkp_dir/a.dat,$bkp_dir >&! backup_all.out
$grep -E "$grepit" backup_all.out |& sort -f
echo "Target exists and is a combination of files/directories"
$MUPIP backup -c -rec -o AREG,BREG,CREG $bkp_dir/a.dat,$bkp_dir >&! backup_all.out
sort -f backup_all.out
echo "Target exists and is a combination of files/directories and replace qualifier specified"
$MUPIP backup -replace -c -rec -o AREG,BREG,CREG $bkp_dir/a.dat,$bkp_dir >&! backup_all.out
$grep -E "$grepit" backup_all.out |& sort -f

echo "Target exists and duplicates in target list"
$MUPIP backup -c -rec -o AREG,BREG,CREG $bkp_dir/a.dat,$bkp_dir/a.dat,$bkp_dir/a.dat >&! backup_all_1.outx
$gtm_tst/com/do_m_filtering.csh "do ^sortdbregs" backup_all_1.outx >&! sorted_regs_1.outx
sort -f sorted_regs_1.outx

rm $bkp_dir/*
echo "Target does not exist and duplicates in target list"
$MUPIP backup -c -rec -o AREG,BREG,CREG $bkp_dir/a.dat,$bkp_dir/a.dat,$bkp_dir/a.dat >&! backup_all_2.outx
$gtm_tst/com/do_m_filtering.csh "do ^sortdbregs" backup_all_2.outx >&! sorted_regs_2.outx
sort -f sorted_regs_2.outx

echo "Target does not exist and duplicates in target list and replace qualifier specified"
$MUPIP backup -replace -c -rec -o AREG,BREG,CREG $bkp_dir/a.dat,$bkp_dir/a.dat,$bkp_dir/a.dat >&! backup_all_3.outx
$gtm_tst/com/do_m_filtering.csh "do ^sortdbregs" backup_all_3.outx >&! sorted_regs_3.outx
sort -f sorted_regs_3.outx

echo "Target does not exist but path contains a very long directory name"
$MUPIP backup -c -rec -o AREG,BREG,CREG $long_dir/a.dat,$long_dir/a.dat,$long_dir/a.dat >&! longdir_bkp.outx
$gtm_tst/com/do_m_filtering.csh "do ^sortdbregs" longdir_bkp.outx >&! sorted_regs_4.outx
sort -f sorted_regs_4.outx

$gtm_tst/com/dbcheck.csh -nosprgde
