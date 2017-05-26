#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Fundamental features of M language are tested using spanning nodes, such as $query, $order etc.
# This test is organized by record size. Because different M code require different max record sizes

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
setenv gtm_test_sprgde_exclude_reglist BREG	# BREG disables nullsubscripts and there are globals with nullsubscripts

# Use multiple regions for initial tests
echo "#############RECORD SIZE 4000#############"
$gtm_tst/com/dbcreate.csh mumps 4 255 4000 1024
$DSE <<EOF
change -fileheader -null_subscripts=always -stdnull=TRUE
find -reg=BREG
change -fileheader -null_subscripts=never
find -reg=CREG
change -fileheader -null_subscripts=always -stdnull=TRUE
find -reg=DEFAULT
change -fileheader -null_subscripts=always -stdnull=TRUE
EOF
echo '#Start $query test'
$gtm_exe/mumps -run %XCMD 'do tquery^dollarquery("^a","^c")' > dollarquery.out
diff dollarquery.out $gtm_tst/$tst/outref/dollarquery.txt
echo '#End $query test'
echo '#Start "merge" command duplication test'
$gtm_exe/mumps -run %XCMD 'zwrite ^a' > a.txt
$gtm_exe/mumps -run %XCMD 'zwrite ^c' > c.txt
sed 's/\^c/\^a/' c.txt > filtered.txt
echo '#There should be only one diff here:> ^a("merge")=1'
diff a.txt filtered.txt
$gtm_exe/mumps -run merge
echo '#End "merge" command duplication test'
echo "#Start small get/set test"
$gtm_exe/mumps -run getset
echo "#End small get/set test"
echo '#Start $order/$next test'
$gtm_exe/mumps -run dollarorder
echo '#End $order/$next test'
$gtm_tst/com/dbcheck.csh
# Back up gld and dat files for forensic analysis
$gtm_tst/com/backup_dbjnl.csh set1 "" mv

echo "#############RECORD SIZE 10000#############"
# Switching back to single region
$GDE change -region DEFAULT -null_subscripts=always -stdnull -rec=10000
$gtm_exe/mupip create
echo '#Start $query with larger values test'
$gtm_exe/mumps -run dollarquerylarge > dollarquerylarge.out
diff dollarquerylarge.out $gtm_tst/$tst/outref/dollarquerylarge.txt
echo '#End $query with larger values test'
echo '#Start $data test'
$gtm_exe/mumps -run dollardata
echo '#End $data test'
echo "#Start zwrite test"
$gtm_exe/mumps -run zwrite
echo "#End zwrite test"
echo "#Start zprevious test"
$gtm_exe/mumps -run zprev
echo "#End zprevious test"
$gtm_exe/mupip integ -region "*"
mkdir set2
mv mumps.dat set2/
mv mumps.gld set2/

echo "#############RECORD SIZE 10000 without -stdnull. This used to fail.#############"
$GDE change -region DEFAULT -rec=10000
$gtm_exe/mupip create
echo "#Start zwrite test"
$gtm_exe/mumps -run zwrite
echo "#End zwrite test"
mkdir set3
mv mumps.dat set3/
mv mumps.gld set3/

echo "#############RECORD SIZE 3000#############"
$GDE change -segment DEFAULT -block_size=1024 -file=mumps.dat
$GDE change -region DEFAULT -null_subscripts=always -stdnull -rec=3000 -key=255
$gtm_exe/mupip create
echo "#Start zshow"
$gtm_exe/mumps -run zshow
echo "#End zshow"
echo "#Generating random keys and values with varying sizes (justkeys.txt,justvalues.txt)."
$gtm_exe/mumps -run randomkeyvalue
echo "#Putting key-value pairs in database (global ^tmpgbl)."
$gtm_exe/mumps -run putfileindb
echo "#Comparing values in database against the file. Killing successfully compared key-value pairs."
$gtm_exe/mumps -run checkandkill
$gtm_exe/mupip integ -reg "*" |& $grep "No errors detected by integ."
echo "#Start references"
$gtm_exe/mumps -run references
echo "#End references"
echo "#Start zdata"
$gtm_exe/mumps -run zdata
echo "#End zdata"
mkdir set4
mv mumps.dat set4/
mv mumps.gld set4/

echo "#############RECORD SIZE 0#############"
echo "Make sure max recordsize can be set to 0"
$GDE change -region DEFAULT -null_subscripts=always -stdnull -rec=0 -key=255

echo "#############RECORD SIZE 1MB#############"
# Define 0.5 GB space for global buffers
$GDE change -segment DEFAULT -g=65536
$GDE change -region DEFAULT -rec=1048576
$gtm_exe/mupip create
echo '#Start $increment'
$GTM <<EOF
set ^long=\$justify(" ",10000)
write \$increment(^long)
if ^long'=1 write "ERROR1: Increment did not set the correct value to ^long",!
set ^long=\$justify("abc",10000)
write \$increment(^long)
if ^long'=1 write "ERROR2: Increment did not set the correct value to ^long",!
set ^long="123"_\$justify("abc",10000)
write \$increment(^long)
if ^long'=124 write "ERROR3: Increment did not set the correct value to ^long",!
EOF
echo '#End $increment'
$gtm_exe/mupip integ -region "*"
