#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Generate the required gld commands file and triggers files"
cat > agld.cmd << CAT_EOF
add -name a* -region=AREG
add -name A* -region=AREG
add -name b* -region=AREG
add -name B* -region=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a.dat
CAT_EOF

cat > bgld.cmd << CAT_EOF
add -name a* -region=BREG
add -name A* -region=BREG
add -name b* -region=BREG
add -name B* -region=BREG
add -region BREG -dyn=BSEG
add -segment BSEG -file=b.dat
CAT_EOF

cat > 3reggld.cmd << CAT_EOF
add -name a* -region=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a.dat
add -name b* -region=BREG
add -region BREG -dyn=BSEG
add -segment BSEG -file=b.dat
CAT_EOF

cat > agld.trg << CAT_EOF
+^a -commands=set -xecute="do ^trigger(""agld.trg"")" -name=trig
+^A -commands=set -xecute="do ^trigger(""AGLD.TRG"")" -name=TRIG
+^auto -commands=set -xecute="do ^trigger(""agld.trg"")"
CAT_EOF

cat > bgld.trg << CAT_EOF
+^b -commands=set -xecute="do ^trigger(""bgld.trg"")" -name=trig
+^B -commands=set -xecute="do ^trigger(""BGLD.TRG"")" -name=TRIG
+^auto -commands=set -xecute="do ^trigger(""bgld.trg"")"
CAT_EOF

cat > trigger.m << CAT_EOF
trigger(file)	;
	write "trigger "_file_" executed",!
	quit
CAT_EOF

echo "# Create a.gld, b.gld and 3reg.gld using the respective gde command files"
setenv gtmgbldir a.gld
$GDE @agld.cmd >&! agld.out

setenv gtmgbldir b.gld
$GDE @bgld.cmd >&! bgld.out

setenv gtmgbldir 3reg.gld
$GDE @3reggld.cmd >&! 3reggld.out

echo "# Create the database files"
$MUPIP create >&! mucreate.out

echo "# Install triggers using a.gld and agld.trg"
setenv gtmgbldir a.gld
$MUPIP trigger -triggerfile=agld.trg >&! install_agldtrg.out

echo "# Install triggers using b.gld and bgld.trg"
setenv gtmgbldir b.gld
$MUPIP trigger -triggerfile=bgld.trg >&! install_bgldtrg.out

echo "# Run zprint.m - The entire test output is the output of this routine"
$gtm_exe/mumps -run zprint

