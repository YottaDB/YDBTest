#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "# Have span.gld with the mappings below - to be used by all the test cases below"
echo "# GBL -> REG1 ; GBL(1) -> REG1 ; GBL(2) -> REG2"
setenv gtmgbldir span.gld
$GDE >&! spangld.out << GDE_EOF
template -region -stdnullcoll
change -region DEFAULT -stdnullcoll
add -region REG1 -dyn=SEG1
add -region REG2 -dyn=SEG2
add -region REG3 -dyn=SEG3
add -segment SEG1 -file=file1.dat
add -segment SEG2 -file=file2.dat
add -segment SEG3 -file=file3.dat
add -name NAME1 -reg=REG1
add -name NAME2 -reg=REG2
add -name NAME3 -reg=REG3
add -name GBL -reg=REG1
add -name GBL(1) -reg=REG1
add -name GBL(2) -reg=REG2
add -name GBL(3,1) -reg=REG1
add -name GBL(3,2) -reg=REG2
GDE_EOF

$MUPIP create >&! mupip_create.out
cat >&! gblname1.trg << CAT_EOF
+^GBL(1) -commands=set -xecute="do ^nothing" -name=gblname1
CAT_EOF

cat >&! gblname2.trg << CAT_EOF
+^GBL(2) -commands=set -xecute="do ^nothing" -name=gblname1
CAT_EOF

$gtm_tst/com/backup_dbjnl.csh emptydb '*.dat' cp nozip

$echoline
echo "# Test 1 :"
echo "# Install a trigger with name gblname1 using a nonspanning gld pointing GBL to REG3"
echo "# Using spanning gld that has REG3 but GBL does not span to REG3, install a different trigger with same name"
echo "# Expect it to error out since a different trigger with same name already exisits in one of the regions"
echo "# Have nonspan.gld with GBL -> REG3"
setenv gtmgbldir nonspan.gld
$GDE >&! nonspangld1.out << GDE_EOF
add -region REG3 -dyn=SEG3
add -segment SEG3 -file=file3.dat
add -name GBL -reg=REG3
GDE_EOF

echo "# Using nonspan.gld install a trigger for ^GBL with the name gblname1"
setenv gtmgbldir nonspan.gld
$MUPIP trigger -noprompt -triggerfile=gblname1.trg

echo "# Using span.gld, try intalling the same trigger with the same name"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -triggerfile=gblname2.trg
echo "" |& $MUPIP trigger -select

$gtm_tst/com/backup_dbjnl.csh testcase1 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
echo "# Test 2 :"
echo "# Same as Test 1 above, but install the exact same trigger with spanning regions"
echo "# Expect it to work this time, as the trigger signature is the same"
cp emptydb/* .
echo "# Using nonspan.gld install a trigger for ^GBL with the name gblname1"
setenv gtmgbldir nonspan.gld
$MUPIP trigger -noprompt -triggerfile=gblname1.trg

echo "# Using span.gld, try intalling the same trigger with the same name"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -triggerfile=gblname1.trg
echo "" |& $MUPIP trigger -select

$gtm_tst/com/backup_dbjnl.csh testcase2 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
echo "# Test 3 :"
echo "# With ^GBL spanning REG1,REG2 in span.gld and ^GBL mapped to REG2 in nonspan.gld"
echo "# Install T1 using span.gld and a different trigger T2 using nonspan.gld"
echo "# Do sets to see if the triggers are fired properly"
cp emptydb/* .
setenv gtmgbldir nonspan.gld
rm -f nonspan.gld	# remove nonspan.gld that maps GBL to REG3
$GDE >&! nonspangld1.out << GDE_EOF
add -region REG2 -dyn=SEG2
add -segment SEG2 -file=file2.dat
add -name GBL -reg=REG2
GDE_EOF

cat >&! span.trg << CAT_EOF
+^GBL(1:3) -commands=SET,KILL -xecute="write ""This is spanning trigger - T1"",!" -name=T1
CAT_EOF

cat >&! nonspan.trg << CAT_EOF
+^GBL(1:3) -commands=SET,KILL -xecute="write ""This is non-spanning trigger - T2"",!" -name=T2
CAT_EOF

echo "# Install different set triggers for ^GBL(1:3) using span.gld and nonspan.gld"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -triggerfile=span.trg
setenv gtmgbldir nonspan.gld
$MUPIP trigger -noprompt -triggerfile=nonspan.trg
setenv gtmgbldir span.gld
echo "# Using span.gld set ^GBL(1), which maps to REG1 - Expect only T1 to be fired"
$gtm_exe/mumps -run %XCMD 'write $VIEW("REGION","^GBL(1)"),! set ^GBL(1)=1'
echo "# Using span.gld set ^GBL(2), which maps to REG2 - Expect both T1 and T2 to be fired"
$gtm_exe/mumps -run %XCMD 'write $VIEW("REGION","^GBL(2)"),! set ^GBL(2)=2' >&! set2.out
# Sort the output since the order of T1,T2 is non-deterministic
sort set2.out
echo "# Using span.gld set ^GBL(3,1-2), which does not have any triggers defined"
$gtm_exe/mumps -run %XCMD 'set ^GBL(3,1)=31 set ^GBL(3,2)=32'

$gtm_tst/com/backup_dbjnl.csh testcase3 '*.dat *.trg *.gld' cp

$echoline
echo "# Test 4:"
echo "# With the same setup, do different KILLs and check if the right triggers are fired"
setenv gtmgbldir span.gld
echo "# Using span.gld kill ^GBL(1), which maps to REG1 - Expect only T1 to be fired"
$gtm_exe/mumps -run %XCMD 'write $VIEW("REGION","^GBL(1)"),! kill ^GBL(1)'
echo "# Using span.gld kill ^GBL(2), which maps to REG2 - Expect both T1 and T2 to be fired"
$gtm_exe/mumps -run %XCMD 'write $VIEW("REGION","^GBL(2)"),! kill ^GBL(2)' >&! kill2.out
# sort the output since the order of T1,T2 is non-deterministic
sort kill2.out
echo "# Using span.gld kill ^GBL(3), which maps to both REG1 and REG2 - Expect T1 to be fired for REG1 and T1,T2 for REG2"
$gtm_exe/mumps -run %XCMD 'write $VIEW("REGION","^GBL(3)"),! kill ^GBL(3)' >&! kill3.out
sort kill3.out
