#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/func1.cmd'")'
$GDE @gdefunc1.cmd
# Create a dummy nothing.m routine
echo "nothing	; exit"	> nothing.m

$MUPIP create

echo '#### Make sure triggers work with spanning regions ####'
cat << cat_eof >> func1.trg
+^z -command=SET -xecute="do ^nothing"
+^y -command=SET -xecute="do ^nothing"
+^x -command=SET -xecute="do ^nothing"
+^a -command=SET -xecute="do ^nothing"
+^b -command=SET -xecute="do ^nothing"
+^c -command=SET -xecute="do ^nothing"
cat_eof

$MUPIP trigger -triggerfile=func1.trg
$MUPIP trigger -select

cat << cat_eof >> func2.trg
-*
cat_eof

$MUPIP trigger -triggerfile=func2.trg -noprompt
$MUPIP trigger -select

echo '#### Test $data() with spanning regions ####'
$gtm_exe/mumps -run dollardata

echo '#### Test $order() with spanning regions ####'
$gtm_exe/mumps -run dollarorderquery

echo '#### using a .gld with a different global mapping where one subscript is accessible and the other is not ####'
echo '#### set $zgbldir clears naked reference if gbldir gets switched and does not clear if not switched ####'
setenv gtmgbldir alt.gld
$GDE exit
$GTM << gtm_eof
write \$data(^a("a"))
write \$data(^a(1))
set \$zgbldir="mumps.gld"
write ^a("a")
set \$zgbldir="mumps.gld"
write \$get(^(1))
set \$zgbldir="alt.gld"
write \$get(^(1))
gtm_eof

setenv gtmgbldir mumps.gld
echo '#### GTM-7853 : MUPIP INTEG -SUBSCRIPTS terminates with SIG-11 if null-subscripts are specified'
$MUPIP integ -subscript='"^a("""")":"^a(31)"' -reg "*" >&! integ_subscripts.out
if ($status) then
	echo "mupip integ -subscript failed. Check integ_subscripts.out"
else
	# the order of regions in a multi-region output is not deterministic
	$grep -E "^Data" integ_subscripts.out |& sort
endif

echo '#### Test DSE find -key scenarios with spanning regions ####'
echo '#### Create a second global directory and set ^a(1) in mumps.dat ####'
setenv gtmgbldir alt.gld
$gtm_exe/mumps -run %XCMD 'set ^a(1)="atl.gld"'
setenv gtmgbldir mumps.gld

$DSE << dse_eof
find -key=^b(1)
find -key=^x(1)
find -key=^x(1) -nogbldir
find -key=^a(100)
find -key=^a(100) -nogbldir
find -key=^a(40,5,6)
find -region=REG3
find -key=^a(40,5,6)
find -key=^a(40,5,7)
find -key=^b(1)
find -key=^b(1) -nogbldir
find -key=^a(40,5)
find -region=REG2
find -key=^a(40,5)
find -key=^a(40,5,7)
find -region=DEFAULT
find -key=^a(1)
find -key=^a(1) -nogbldir
dse_eof

