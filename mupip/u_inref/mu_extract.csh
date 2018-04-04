#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
# 'go' format is not supported in UTF-8 mode
# Since the intent of the subtest is explicitly check extract in zwr, go and binary format, it is forced to run in M mode
$switch_chset M >&! switch_chset.out
echo "======"
echo "Part 1"
echo "======"

$gtm_tst/com/dbcreate.csh "mumps" 1 125 700
$GTM << xyz
s ^dupkey("one")="1"
h
xyz
$DSE << xyz
add -key ="^dupkey(""one"")" -data="1" -bl=3 -rec=2
q
xyz
$gtm_tst/com/dbcheck.csh -extr
sleep 1
$MUPIP integ -r "*"
$MUPIP extract extr1.zwr
$tail -n +3 extr1.zwr
###
###
echo "======"
echo "Part 2"
echo "======"
$gtm_tst/com/dbcreate.csh "mumps" 1 125 700
$GTM << xyz
s ^dupkey("one")="1"
h
xyz
$DSE << xyz
add -key ="^dupkey(""one"")" -data="1" -bl=3 -rec=2
q
xyz
$DSE << xyz
add -key ="^dupkey(""one1"")" -data="2" -bl=3 -rec=2
q
xyz
$gtm_tst/com/dbcheck.csh -extr
sleep 1
$MUPIP integ -r "*"
echo "### -format=zwr ###"
$MUPIP extract extr2.zwr
$tail -n +3 extr2.zwr
echo "### -format=go ###"
$MUPIP extract -format=go extr2.go
$tail -n +3 extr2.go
echo "### -format=bin ###"
$MUPIP extract extr2.bin -format=bin
\rm *.dat
$MUPIP create
echo "MUPIP load extr2.bin -format=bin"
$MUPIP load extr2.bin -format=bin
$GTM << xyz
if ^dupkey("one")'="1" w "LOAD FAILED",!
zwr ^dupkey
h
xyz
$MUPIP integ -r "*"
echo "======"
echo "Part 3"
echo "======"
$gtm_tst/com/dbcreate.csh "mumps" 1 125 700
$GTM << xyz
for i=1:5:2000  s ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)=i
for i=851:5:926  K ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)
h
xyz
$DSE << xyz
add -key ="^var(""ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv"",467)" -data="1" -bl=3 -rec=AA
q
xyz
$gtm_tst/com/dbcheck.csh -extr
$MUPIP integ -r "*"
echo "### -format=zwr ###"
$MUPIP extract extr3.zwr
$tail -n +3 extr3.zwr
echo "### -format=go ###"
$MUPIP extract -format=go extr3.go
$tail -n +3 extr3.go
echo "### -format=bin ###"
$MUPIP extract extr3.bin -format=bin
\rm *.dat
$MUPIP create
echo "MUPIP load extr3.bin -format=bin"
$MUPIP load extr3.bin -format=bin
$GTM << aa
zwr ^var
aa

echo "======"
echo "Part 4"
echo "======"
echo "# mupip extract of spanning global might not be in sequential order in extract file"
echo '# [GTM-7856] Secondary db is out of sync with primary in case one side uses standard null collation and other does not'
echo "# Create mumps.gld with ^a going to AREG (a.dat) and ^a(1:6) going to DEFAULT (mumps.dat)"
echo '# Set standard null collation only for the primary side'
setenv gtmgbldir mumps.gld
setenv gtm_test_spanreg 0	# A specific spanning regions config is manually created in this section
$gtm_tst/com/dbcreate.csh "mumps" 2 -null=TRUE
$GDE << GDE_EOF >&! gde_part4.out
add -name a(1:6) -region=DEFAULT
change -reg areg -std
change -reg DEFAULT -std
GDE_EOF

echo "# With mumps.gld : set ^a(1-10)=mumps.gld_i"
$gtm_exe/mumps -run %XCMD 'for i=1:1:10 set ^a(i)="mumps.gld"_i'

echo '# set ^b("")=1'
$gtm_exe/mumps -run %XCMD 'set ^b("")=1'

echo "# Create second.gld where ^a(1-10) goes to DEFAULT (mumps.dat) and set ^a(6-10)=second.gld_i"
setenv gtmgbldir second.gld
$GDE exit
$gtm_exe/mumps -run %XCMD 'for i=6:1:10 set ^a(i)="second.gld"_i'

echo "# With mumps.gld do a zwrite ^a"
setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run %XCMD 'zwrite ^a'

if ($?test_replic) then
	$gtm_tst/com/RF_sync.csh
	echo "# On the secondary side do a zwrite ^b"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_exe/mumps -run %XCMD 'zwrite ^b'"
endif

echo "# With mumps.gld do mupip extract"
$MUPIP extract a.zwr
cat a.zwr
# Not passing -extract to dbcheck as the extracts will be different and will fail
$gtm_tst/com/dbcheck.csh

if (! $?test_replic) then
	# Below section is disabled for replication because it needs database with different null collation order.
	# Starting replication servers with that setup would error with:
	# %YDB-E-NULLCOLLDIFF, Null collation order must be the same for all regions
	echo "======"
	echo "Part 5"
	echo "======"
	echo "# [GTM-7990] MUPIP EXTRACT now accepts -R[EGION] qualifier with comma separated region names to extract globals"
	echo "# mapped to those specific regions."

	echo "# Create the database"
	setenv test_specific_gde $gtm_tst/$tst/inref/gtm7990.gde
	$gtm_tst/com/dbcreate.csh mumps 4

	echo "# set ^a(1-15)=i"
	$gtm_exe/mumps -run %XCMD 'for i=1:1:15 set ^a(i)=i'

	echo "# set ^b(1-5)=i, set ^c(1-5)=i and set ^d(1-5)=i"
	$gtm_exe/mumps -run %XCMD 'for i=1:1:5 set (^b(i),^c(i),^d(i))=i'

	echo "# 1. Run the following to unit test the addition of new -REGION qualifier in mupip_cmd.c"
	echo "# 1a. mupip extract mext1a.zwr -region (prompt for region(s))"
	echo "AREG" |& $MUPIP extract mext1a.zwr -region
	echo "# 1b. mupip extract mext1b.zwr -region=AREG (accept a value for region qualifier)"
	$MUPIP extract mext1b.zwr -region=AREG
	echo "# 1c. mupip extract mext1c.zwr -region=AREG,CREG (accept comma seperated region list)"
	$MUPIP extract mext1c.zwr -region=AREG,CREG
	echo "# 1d. mupip extract mext1d.zwr -region=NOREG (Show error, region not found)"
	$MUPIP extract mext1d.zwr -region=NOREG
	echo "# 1e. mupip extract mext1e.zwr -region BREG (Show error, Too many parameters)"
	$MUPIP extract mext1e.zwr -region BREG

	echo "# 2. Run the following to test the extracted file"
	echo "# 2a. mupip extract mext2a.zwr (file have all the globals extracted)"
	$MUPIP extract mext2a.zwr && cat mext2a.zwr
	echo "# 2b. mupip extract mext2b.zwr -region=AREG (file will only have global ^a(1:5))"
	$MUPIP extract mext2b.zwr -region=AREG && cat mext2b.zwr
	echo "# 2c. mupip extract mext2c.zwr -region=brEG,CReg (file will have global ^b, ^a(6:10) and ^c)"
	$MUPIP extract mext2c.zwr -region=brEG,CReg && cat mext2c.zwr
	echo "# 2d. mupip extract mext2d.zwr -region=BREG,AREG,DEFAULT (file will have global all the values in global ^a(1:15), ^b and ^d)"
	$MUPIP extract mext2d.zwr -region=BREG,AREG,DEFAULT && cat mext2d.zwr
	echo "# 2e. mupip extract mext2e.go -region=BREG,CREG -format=go (file will have global ^b, ^a(6:10) and ^c)"
	$MUPIP extract mext2e.go -region=BREG,CREG -format=go && cat mext2e.go

	echo "# 3. Run the following to test the 'same null collation check' for binary format only for selected regions."
	echo "#    Note: Region CREG is having Std Null Coll set to N unlike all other regions."
	echo "# 3a. mupip extract mext3a.bin -format=bin (Show error, Null collation order must be the same for all regions)"
	$MUPIP extract mext3a.bin -format=bin
	echo "# 3b. mupip extract mext3b.bin -format=bin -region=BREG,CREG (Show error, Null collation order must be the same"
	echo "#     for all regions)"
	$MUPIP extract mext3b.bin -format=bin -region=BREG,CREG
	echo "# 3c. mupip extract mext3c.bin -format=bin -region=AREG,BREG (file will be generated successfully, further load"
	echo "#     the file into new database and check its content)"
	$MUPIP extract mext3c.bin -format=bin -region=AREG,BREG
	ls mext3c.bin
	$gtm_tst/com/dbcheck.csh
	unsetenv test_specific_gde
	echo "# create a new database"
	$gtm_tst/com/dbcreate.csh mumps 4
	echo "# load the mext3c.bin file to new database"
	$MUPIP load -format=bin mext3c.bin
	echo "# extract the data from new database and print the content on stderr"
	$MUPIP extract -format=zwr mext3c.zwr && cat mext3c.zwr
	$gtm_tst/com/dbcheck.csh
endif
echo "=== End of mu_extract ==="
