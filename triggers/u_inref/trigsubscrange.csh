#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TRIGSUBSCRANGE: THIS TEST IS A NEAR COPY of trigcol and should match nearly 100%
#
# Trigger subscript range collation test.
#
# Trigger subscript collation can have two effects:
#  1. The subscript ranges in the triggers themselves.
#  2. The order of triggers in the trigger name xref stored in the default directory.
#
# This subtest tests the 4 possible combinations of the above:
#  1. Standard trigger subscript collation, standard default region collation
#  2. Alternate trigger subscript collation, standard default region collation
#  3. Standard trigger subscript collation, alternate default region collation
#  4. Alternate trigger subscript collation, alternate default region collation
#

#
# Trigger files to use - one forward collation, one reverse. Depends on which way collation
# is being used in the trigger subscripts as to which trigger file is used. Failure to use
# correct file results in trigger subscript range error.
#
# To get the trigsubscrange error I swapped the fwd and rev, compared to trigcol
cat >> trigcollaterev.trg << EOF
+^collrange(sub="A":"G") -commands=set -xecute="Set ^range(sub)=\$ZTValue" -name=trigcolupper
+^collrange(sub="h":"p") -commands=set -xecute="Set ^range(sub)=\$ZTValue" -name=trigcollower
EOF
cat >> trigcollatefwd.trg << EOF
+^collrange(sub="G":"A") -commands=set -xecute="Set ^range(sub)=\$ZTValue" -name=trigcolupper
+^collrange(sub="p":"h") -commands=set -xecute="Set ^range(sub)=\$ZTValue" -name=trigcollower
EOF

#
# Set up collation library for (some) tests below to use. Use standard "reverse" collation
# routines defined in com directory. Note also installs local var reverse collation.
#
source $gtm_tst/com/cre_coll_sl_reverse.csh 1
if ($?test_replic == 1) then
        $rcp libreverse.* "$tst_remote_host":$SEC_SIDE/
endif

####################################################################################
#
# 1. Test standard trigger subscript collation, standard default region collation
#
$echoline
echo "1. Test standard trigger subscript collation, standard default region collation"
cat >> gdecoltmp1.com <<EOF
add -name collrange -region=trigcol1a
add -name range -region=trigcol1b
add -region trigcol1a -dynamic_segment=trigcol1a
add -region trigcol1b -dynamic_segment=trigcol1b
add -segment trigcol1a -file=trigcol1a.dat
add -segment trigcol1b -file=trigcol1b.dat
change -segment DEFAULT -file=mumps1.dat
EOF
$convert_to_gtm_chset gdecoltmp1.com
#
# Create multi-region collation critter..
setenv test_specific_gde $tst_working_dir/gdecoltmp1.com
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps1 1
$load trigcollatefwd.trg
#
# Run test
$gtm_dist/mumps -run trigcoldrv
#
# Verify databases
$gtm_tst/com/dbcheck.csh -extract
#
# List triggers used (verify collation of trigger xref in default region)
$show
#
# Move old GLD and DAT files out of the way
set bak=bak1
$gtm_tst/com/backup_dbjnl.csh $bak "*.dat *.gld" mv
#
####################################################################################
#
# 2. Alternate trigger subscript collation, standard default region collation
#
$echoline
echo "2. Alternate trigger subscript collation, standard default region collation"
cat >> gdecoltmp2.com << EOF
add -name collrange -region=trigcol2a
add -name range -region=trigcol2b
add -region trigcol2a -collation_default=1 -dynamic_segment=trigcol2a
add -region trigcol2b -collation_default=1 -dynamic_segment=trigcol2b
add -segment trigcol2a -file=trigcol2a.dat
add -segment trigcol2b -file=trigcol2b.dat
change -segment DEFAULT -file=mumps2.dat
EOF
$convert_to_gtm_chset gdecoltmp2.com
#
# Create multi-region collation critter..
setenv test_specific_gde $tst_working_dir/gdecoltmp2.com
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps2 1
$load trigcollaterev.trg
#
# Run test
$gtm_dist/mumps -run trigcoldrv
#
# Verify databases
$gtm_tst/com/dbcheck.csh -extract
#
# List triggers used (verify collation of trigger xref in default region)
$show
#
# Move old GLD and DAT files out of the way
set bak=bak2
$gtm_tst/com/backup_dbjnl.csh $bak "*.dat *.gld" mv
#
####################################################################################
#
# 3. Standard trigger subscript collation, alternate default region collation
#
$echoline
echo "3. Standard trigger subscript collation, alternate default region collation"
cat >> gdecoltmp3.com << EOF
add -name collrange -region=trigcol3a
add -name range -region=trigcol3b
add -region trigcol3a -dynamic_segment=trigcol3a
add -region trigcol3b -dynamic_segment=trigcol3b
add -segment trigcol3a -file=trigcol3a.dat
add -segment trigcol3b -file=trigcol3b.dat
change -region DEFAULT -collation_default=1
change -segment DEFAULT -file=mumps3.dat
EOF
$convert_to_gtm_chset gdecoltmp3.com
#
# Create multi-region collation critter..
setenv test_specific_gde $tst_working_dir/gdecoltmp3.com
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps3 1
$load trigcollatefwd.trg
#
# Run test
$gtm_dist/mumps -run trigcoldrv
#
# Verify databases
$gtm_tst/com/dbcheck.csh -extract
#
# List triggers used (verify collation of trigger xref in default region)
$show
#
# Move old GLD and DAT files out of the way
set bak=bak3
$gtm_tst/com/backup_dbjnl.csh $bak "*.dat *.gld" mv
#
####################################################################################
#
# 4. Alternate trigger subscript collation, alternate default region collation
#
$echoline
echo "4. Alternate trigger subscript collation, alternate default region collation"
cat >> gdecoltmp4.com << EOF
add -name collrange -region=trigcol4a
add -name range -region=trigcol4b
add -region trigcol4a -collation_default=1 -dynamic_segment=trigcol4a
add -region trigcol4b -collation_default=1 -dynamic_segment=trigcol4b
add -segment trigcol4a -file=trigcol4a.dat
add -segment trigcol4b -file=trigcol4b.dat
change -region DEFAULT -collation_default=1
change -segment DEFAULT -file=mumps4.dat
EOF
$convert_to_gtm_chset gdecoltmp4.com
#
# Create multi-region collation critter..
setenv test_specific_gde $tst_working_dir/gdecoltmp4.com
setenv gtm_test_sprgde_id "ID4"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps4 1
$load trigcollaterev.trg
#
# Run test
$gtm_dist/mumps -run trigcoldrv
#
# Verify databases
$gtm_tst/com/dbcheck.csh -extract
#
# List triggers used (verify collation of trigger xref in default region)
$show
#


