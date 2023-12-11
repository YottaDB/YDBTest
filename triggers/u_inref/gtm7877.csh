#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

# span1.csh from tunittest
setenv gtmgbldir nospan.gld
echo "# Create a single region gld and save it as nospan.gld"
$GDE exit

setenv gtmgbldir span.gld
echo "# Create a spanning global from gtm7877span.gde and save it as span.gld"
$GDE @$gtm_tst/$tst/inref/gtm7877span.gde

$echoline
echo "# Test case 1 "
echo "# Create database"
$MUPIP create >&! mupip_create_1.out

cat > nospan.trg << CAT_EOF
+^A(0) -commands=SET -xecute="do A^symmetry"
CAT_EOF

cat > span.trg << CAT_EOF
+^A(1) -commands=SET -xecute="do A^symmetry"
CAT_EOF

echo "# Use nonspan.gld and load trigger ^A(0)"
setenv gtmgbldir nospan.gld
$MUPIP trigger -noprompt -trigg=nospan.trg

echo "# Use span.gld and load trigger ^A(1)"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -trigg=span.trg

echo "# Trigger extract using span.gld should show both the ^A triggers in DEFAULT region"
$MUPIP trigger -select testcase1trigselect.out
cat testcase1trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase1 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
# span2.csh from tunittest
echo "# Test case 2 "
echo "# Do the same as Test case 1, but with a named trigger"

echo "# Create database"
setenv gtmgbldir span.gld
$MUPIP create >&! mupip_create_2.out

cat > nospan.trg << CAT_EOF
+^A(0) -commands=SET -xecute="do A^symmetry" -name=a0
CAT_EOF

cat > span.trg << CAT_EOF
+^A(1) -commands=SET -xecute="do A^symmetry" -name=a0
CAT_EOF

echo "# Use nonspan.gld and load trigger ^A(0) with name a0"
setenv gtmgbldir nospan.gld
$MUPIP trigger -noprompt -trigg=nospan.trg

echo "# Use span.gld and load trigger ^A(1) with name a0 - This should error out with trigger a0 already exists"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -trigg=span.trg

echo "# Trigger extract using span.gld should show ^A(0) in reg DEFAULT, loaded using nonspan.gld"
$MUPIP trigger -select testcase2trigselect.out
cat testcase2trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase2 '*.dat *.trg *.gld' mv

$echoline
# span3.csh from tunittest
echo "# Test case 3 "
echo "# Same as Test case 2, but with the same trigger signature"

foreach file (a b c mumps)
	echo "# $file.gld : maps DEFAULT region to $file.dat"
	setenv gtmgbldir $file.gld
	$GDE << GDE_EOF >&! ${file}_gde.out
	change -segment DEFAULT -file=$file.dat
GDE_EOF

end

echo "# span.gld : ^A is spanned across all 4 regions"
setenv gtmgbldir span.gld
$GDE @$gtm_tst/$tst/inref/gtm7877span.gde >&! span.gde_gde.out

$MUPIP create >&! mupip_create_3.out

cat > nospan.trg << CAT_EOF
+^A(0) -commands=SET -xecute="do A^symmetry" -name=a0
CAT_EOF

cat > span.trg << CAT_EOF
+^A(0) -commands=SET -xecute="do A^symmetry" -name=a0
CAT_EOF

echo "# Use a.gld and load trigger ^A(0) with name a0, which would go to a.dat"
setenv gtmgbldir a.gld
$MUPIP trigger -noprompt -trigg=nospan.trg

echo "# Use c.gld and load trigger ^A(0) with name a0, which would go to c.dat"
setenv gtmgbldir c.gld
$MUPIP trigger -noprompt -trigg=nospan.trg

echo "# Use span.gld and load trigger ^A(0)"
echo "# This should error in regions where the trigger is already loaded, but should load in the other regions"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -trigg=span.trg

echo "# Trigger extract using span.gld should show ^A(0) in all 4 regions"
$MUPIP trigger -select testcase3trigselect.out
cat testcase3trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase3 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
# span4.csh from tunittest
echo "# Test case : 4"
echo "# Same as test case 3, but with a delete trigger for the spanning case"

setenv gtmgbldir span.gld
$MUPIP create >&! mupip_create_4.out

cat > nospan.trg << CAT_EOF
+^A(0) -commands=SET -xecute="do A^symmetry" -name=a0
CAT_EOF

cat > span.trg << CAT_EOF
-^A(0) -commands=SET -xecute="do A^symmetry" -name=a0
CAT_EOF

echo "# Use a.gld and load trigger ^A(0) with name a0, which would go to a.dat"
setenv gtmgbldir a.gld
$MUPIP trigger -noprompt -trigg=nospan.trg

echo "# Use c.gld and load trigger ^A(0) with name a0, which would go to c.dat"
setenv gtmgbldir c.gld
$MUPIP trigger -noprompt -trigg=nospan.trg

echo "# Use span.gld and delete trigger ^A(0)"
echo "# This should delete trigger in regions AREG and CREG and should say does not exist for the other regions"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -trigg=span.trg

echo "# Trigger extract using span.gld - Should be empty"
$MUPIP trigger -select testcase4trigselect.out
cat testcase4trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase4 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
# span5.csh from tunittest
echo "# Test case : 5"
echo "# Same as test case 3, but with a different -commands= for the spanning case"

setenv gtmgbldir span.gld
$MUPIP create >&! mupip_create_5.out

cat > nospan.trg << CAT_EOF
+^A(0) -commands=SET,KILL -xecute="do A^symmetry" -name=a0
CAT_EOF

cat > span.trg << CAT_EOF
+^A(0) -commands=SET -xecute="do A^symmetry" -name=a0
CAT_EOF

echo "# Use a.gld and load SET,KILL trigger ^A(0) with name a0, which would go to a.dat"
setenv gtmgbldir a.gld
$MUPIP trigger -noprompt -triggerfile=nospan.trg

echo "# Use c.gld and load SET,KILL trigger ^A(0) with name a0, which would go to c.dat"
setenv gtmgbldir c.gld
$MUPIP trigger -noprompt -triggerfile=nospan.trg

echo "# Use span.gld and load SET trigger ^A(0)"
echo "# This should load the two SET triggers in the regions that do not already have SET,KILL triggers"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -triggerfile=span.trg

echo "# Trigger extract using span.gld - Should have 2 S triggers and 2 S,K triggers"
$MUPIP trigger -select testcase5trigselect.out
cat testcase5trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase5 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
# span6.csh from tunittest
echo "# Test case : 6"
echo "# Same as test case 5, but with a different SET and KILL delete trigger for the spanning case"

setenv gtmgbldir span.gld
$MUPIP create >&! mupip_create_6.out

cat > nospan.trg << CAT_EOF
+^A(0) -commands=SET,KILL -xecute="do A^symmetry" -name=a0
CAT_EOF

cat > span.trg << CAT_EOF
-^A(0) -commands=SET -xecute="do A^symmetry"
-^A(0) -commands=KILL -xecute="do A^symmetry"
CAT_EOF

echo "# Use a.gld and load SET,KILL trigger ^A(0) with name a0, which would go to a.dat"
setenv gtmgbldir a.gld
$MUPIP trigger -noprompt -triggerfile=nospan.trg

echo "# Use c.gld and load SET,KILL trigger ^A(0) with name a0, which would go to c.dat"
setenv gtmgbldir c.gld
$MUPIP trigger -noprompt -triggerfile=nospan.trg

echo "# Use span.gld and try -^A(0) once with SET command and once with KILL command"
echo "# The first trigger should modify existing triggers in AREG/CREG. The next should delete them"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -triggerfile=span.trg

echo "# Trigger extract using span.gld - Should be empty"
$MUPIP trigger -select testcase6trigselect.out
cat testcase6trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase6 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
# span7.csh from tunittest
echo "# Test case : 7"

setenv gtmgbldir span.gld
$MUPIP create >&! mupip_create_7.out

cat > nospan.trg << CAT_EOF
+^A(0) -commands=KILL -xecute="do A^symmetry"
+^A(0) -commands=SET  -xecute="do A^symmetry" -delim="c"
+^A(0) -commands=SET  -xecute="do A^symmetry" -delim="d"
CAT_EOF

cat > span.trg << CAT_EOF
+^A(0) -commands=SET -xecute="do A^symmetry"
+^A(1) -commands=KILL -xecute="do A^symmetry"
-^A(0) -commands=SET -xecute="do A^symmetry"
-^A(1) -commands=KILL -xecute="do A^symmetry"
CAT_EOF

echo "# Use a.gld and load nonspan.trg"
setenv gtmgbldir a.gld
$MUPIP trigger -noprompt -triggerfile=nospan.trg

echo "# Use c.gld and load nonspan.trg"
setenv gtmgbldir c.gld
$MUPIP trigger -noprompt -triggerfile=nospan.trg

echo "# Use span.gld and load span.trg"
setenv gtmgbldir span.gld
$MUPIP trigger -noprompt -triggerfile=span.trg

echo "# Trigger extract using span.gld - Should have two triggers (delim=c, delim=d) in regions AREG and CREG"
$MUPIP trigger -select testcase7trigselect.out
cat testcase7trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase7 '*.dat *.trg *.gld' cp
rm *.dat


$echoline
# span8.csh from tunittest
echo "# Test case : 8"

setenv gtmgbldir span.gld
$MUPIP create >&! mupip_create_8.out

cat > nospan1.trg << CAT_EOF
+^A(0) -commands=KILL -xecute="do A^symmetry"
+^A(0) -commands=SET  -xecute="do A^symmetry" -delim="c"
+^A(0) -commands=SET  -xecute="do A^symmetry" -delim="d"
CAT_EOF

cat > nospan2.trg << CAT_EOF
+^A(0) -commands=KILL -xecute="do A^symmetry"
+^A(0) -commands=SET  -xecute="do A^symmetry" -delim="d"
+^A(0) -commands=SET  -xecute="do A^symmetry" -delim="c"
CAT_EOF

cat > nospan3.trg << CAT_EOF
+^A(0) -commands=KILL,ZKILL -xecute="do A^symmetry"
+^A(0) -commands=SET        -xecute="do A^symmetry" -delim="d"
+^A(0) -commands=SET        -xecute="do A^symmetry" -delim="c"
CAT_EOF

cat > span.trg << CAT_EOF
-^A(0) -commands=SET,KILL -xecute="do A^symmetry" -delim="d"
CAT_EOF

echo "# Use a.gld and load nospan1.trg"
setenv gtmgbldir  a.gld
$MUPIP trigger -noprompt -triggerfile=nospan1.trg
$MUPIP trigger -select testcase8_agld_trigselect.out
cat testcase8_agld_trigselect.out

echo "# Use b.gld and load nospan2.trg"
setenv gtmgbldir  b.gld
$MUPIP trigger -noprompt -triggerfile=nospan2.trg
$MUPIP trigger -select testcase8_bgld_trigselect.out
cat testcase8_bgld_trigselect.out

echo "# Use c.gld and load nospan3.trg"
setenv gtmgbldir  c.gld
$MUPIP trigger -noprompt -triggerfile=nospan3.trg
$MUPIP trigger -select testcase8_cgld_trigselect.out
cat testcase8_cgld_trigselect.out

echo "# Take a backup of database at this stage to be used by next test case"
$gtm_tst/com/backup_dbjnl.csh db8_nospantrig '*.dat' cp nozip

echo "# Use span.gld and load span.trg"
setenv gtmgbldir  span.gld
$MUPIP trigger -noprompt -triggerfile=span.trg
$MUPIP trigger -select testcase8_spangld_trigselect.out
cat testcase8_spangld_trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase8 '*.dat *.trg *.gld' cp
rm *.dat

$echoline
# span9.csh from tunittest
echo "# Test case : 9"

echo "# Copy db files from db8_nospantrig and continue test case 9"
cp db8_nospantrig/*.dat .

# Use the same nospan[123].trg. Crete new span.trg
cat > span.trg << CAT_EOF
+^A(0) -commands=SET,KILL -xecute="do A^symmetry" -delim="c" -name=newname
CAT_EOF

echo "# Use span.gld and load span.trg"
setenv gtmgbldir  span.gld
$MUPIP trigger -noprompt -triggerfile=span.trg
$MUPIP trigger -select testcase9trigselect.out
cat testcase9trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase9 '*.dat *.trg *.gld' cp
rm *.dat

# span10.csh from tunittest
echo "# Test case : 10"
echo "# Deleting triggers by auto-generated name for spanning globals"

echo "# Copy db files from db8_nospantrig and continue test case 10"
cp db8_nospantrig/*.dat .

# Use the same nospan[123].trg. Crete new span.trg
cat > span1.trg << CAT_EOF
+^A(0) -commands=SET,KILL -xecute="do A^symmetry" -delim="c" -name=newname
CAT_EOF

cat > span2.trg << CAT_EOF
-A#1
CAT_EOF

setenv gtmgbldir span.gld
echo "# Use span.gld and load span1.trg - newname cannot match two different triggers named A#1 and A#2 at the same time"
$MUPIP trigger -noprompt -triggerfile=span1.trg
echo "# Use span.gld and load span1.trg and span2.trg"
$MUPIP trigger -noprompt -triggerfile=span2.trg
$MUPIP trigger -select testcase10trigselect.out
cat testcase10trigselect.out

$gtm_tst/com/backup_dbjnl.csh testcase10 '*.dat *.trg *.gld' cp
