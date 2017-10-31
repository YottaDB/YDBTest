#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
\rm -f *.o *.gld *.dat *.ext *.out >&! /dev/null
#
# the "setbig" and "killbig" labels in upgrdtst.m rely on the fact that this is a 512 byte sized block.
# the extension size is set to 1 as dbcertify tests rely on this
#
# note that the record_size below is 16 less than block_size
#
cat > dbprepare.gde << GDE_EOF
change -segment DEFAULT -file=mumps.dat
change -region DEFAULT -record_size=496
change -segment DEFAULT -block_size=512
GDE_EOF

if ("32" == "$gtm_platform_size") then
	# randomly enable reverse-collation on the database.  give it a 50% chance
	if (! $?rand_collation ) then
		set rand_collation=`$gtm_exe/mumps -run rand 2`
	endif
else
	# There are lots of intermingled usage of V4 gtm and the latest gtm in the tests
	# Switching the libreverse shared library b/w 32 and 64 bit is impossible
	# hence disable reverse-collation in this case
	set rand_collation = 0
endif
echo "setenv rand_collation $rand_collation" >>! settings.csh
if ( 1 == $rand_collation) then
	# in case of x86_64 linux, we need to force 32bit sharedlib
	set mach_type = `uname -m`
	if ( "x86_64" == $mach_type && "linux" == "$gtm_test_osname" ) then
		setenv gtt_cc_shl_options "$gtt_cc_shl_options -m32"
		setenv gt_ld_shl_options "$gt_ld_shl_options -m32"
	endif
	source $gtm_tst/com/cre_coll_sl_reverse.csh 10
	echo "change -region default -collation_default=10" >>& dbprepare.gde
	echo "V4 database on reverse collation"
else
	echo "V4 database on normal collation"
endif
echo "exit" >>& dbprepare.gde
$GDE_SAFE @dbprepare.gde
$MUPIP create >&! mpcreate.out
#
# It is a bit tricky to create too-full blocks at both DATA and INDEX blocks.
# To achieve this, we create huge number of globals, extract them out and then separate them into two batches.
# One batch is loaded in alphabetical order and the other is loaded in reverse alphabetical order.
# The order of playing of the normal and reversed order data is also important in creating more number of too-full blocks
# Since more records are needed to create too-full index blocks, we take 90% of the extract file for this purpose.
# Since few records are enough to create too-full data level blocks, we take the remaining 10% of the extract file for this purpose.
#
# To create too-full INDEX DIRECTORY TREE blocks, we need to load the reverse sorted data first.
# To create too-full DATA  DIRECTORY TREE blocks, we need to load the normal  sorted data next.
#
# To create too-full INDEX GLOBAL VARIABLE TREE blocks, we need to load the normal  sorted data first.
# To create too-full DATA  GLOBAL VARIABLE TREE blocks, we need to load the reverse sorted data next.
#
# create dirt2.ext and dirt1_reverse.ext
$GTM << gtm_eof
set type="dirtrand",num=10000
do setdirt^upgrdtst
halt
gtm_eof
$MUPIP extract dirt.ext >& dirt.out
# split 10% 90% data from the extract output
$gtm_exe/mumps -run ten90 dirt >>& dirt.out
#
# create gvt1.ext and gvt2_reverse.ext
#
mv mumps.dat mumps.dat.dirt
# create gvt2.ext and gvt1_reverse.ext
$MUPIP create >&! mpcreate1.out
$GTM << gtm_eof
set type="gvtrand",num=50000
do setgvt^upgrdtst
halt
gtm_eof
$MUPIP extract gvt.ext >& gvt.out
# split 10% 90% data from the extract output
$gtm_exe/mumps -run ten90 gvt >>& gvt.out
#
mv mumps.dat mumps.dat.gvt

#This procedure initially ran with the smallest extension size=1 in order to ensure the database is 100% packed with data.
#But we ended up overflowing the system logs, so after months of testing we decided to remove the exten=1 condition for the DB
#if in future we need this particular attribute again to test things out, this is the place to add.

$MUPIP create >&! mpcreate2.out
$MUPIP load dirt1_reverse.ext >&! dirt1_reverse.log || echo "FAIL - see dirt1_reverse.log"
$MUPIP load dirt2.ext >&! dirt2.log || echo "FAIL - see dirt2.log"
$MUPIP load gvt2.ext >&! gvt2.log || echo "FAIL - see gvt2.log"
$MUPIP load gvt1_reverse.ext >&! gvt1_reverse.log || echo "FAIL - see gvt1_reverse.log"
$gtm_exe/mumps -run initbig^upgrdtst
#
if ( -e libreverse${gt_ld_shl_suffix} ) then
	setenv gt_ld_shl_suffix_saved ${gt_ld_shl_suffix}
	unsetenv gtm_collate_10
	unsetenv gtm_local_collate
endif
