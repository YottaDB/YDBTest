#! /usr/local/bin/tcsh -f
#
# This subtest covers test case 14 from
# MUPIP Set Journal Test Plan
# This subtest verifies Journal state switching 
# based on journal qualifiers
#
echo "Journal state switching subtest"
source $gtm_tst/com/dbcreate.csh . 1
# Initally Journal State state is DISABLED
echo "================================================"
echo "Transition from Journal state 0 to other states"
$MUPIP set -journal=off,nobefore -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" | $tst_awk '{print $3}'`
echo "Journal state (expected DISABLED):$jnl_state"
#
$MUPIP set -journal=on,nobefore -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected DISABLED):$jnl_state"
#
$MUPIP set -journal=enable,off -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected OFF):$jnl_state"
#
# Go back to state 0
$MUPIP set -journal=disable -file mumps.dat
#
$MUPIP set -journal=enable,on,nobefore -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $4}'`
echo "Journal state (expected ON):$jnl_state"
#
# Go back to state 0
#
$MUPIP set -journal=disable -file mumps.dat
#
$MUPIP set -journal=disable -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected DISABLED):$jnl_state"
#
# Now from Journal state 1 to other state
echo "================================================"
echo "From Journal state 1 to other states"
$MUPIP set -journal=enable,off -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected OFF):$jnl_state"
#
$MUPIP set -journal=off -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected OFF):$jnl_state"
#
$MUPIP set -journal=enable,off -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected OFF):$jnl_state"
#
$MUPIP set -journal=on,nobefore -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $4}'`
echo "Journal state (expected ON):$jnl_state"
#
$MUPIP set -journal=off -file mumps.dat
$MUPIP set -journal=enable,on,nobefore -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $4}'`
echo "Journal state (expected ON):$jnl_state"
#
# Go back to Journal state 1
$MUPIP set -journal=off -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected DISABLED):$jnl_state"
#
# From Journal state 2 to other states
echo "================================================"
echo "From Journal state 2 to other states"
$MUPIP set -journal=enable,nobefore -file mumps.dat
$MUPIP set -journal=on,nobefore -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $4}'`
echo "Journal state (expected ON):$jnl_state"
#
$MUPIP set -journal=enable,on,nobefore -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $4}'`
echo "Journal state (expected ON):$jnl_state"
#
$MUPIP set -journal=off -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected OFF):$jnl_state"
#
$MUPIP set -journal=on,nobefore -file mumps.dat
$MUPIP set -journal=enable,off -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected OFF):$jnl_state"
#
$MUPIP set -journal=on,nobefore -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
set jnl_state = `$DSE dump -fileheader |& grep "Journal State" |awk '{print $3}'`
echo "Journal state (expected DISABLED):$jnl_state"

$gtm_tst/com/dbcheck.csh 
#
