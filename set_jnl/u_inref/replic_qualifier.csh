#! /usr/local/bin/tcsh -f
# This subtest covers test cases 30 to 39
# from mupip set journal test plan
#
echo "Replication qualfier..."
source $gtm_tst/com/dbcreate.csh . 2

echo $MUPIP set -journal=enable,nobefore -file mumps.dat
$MUPIP set -journal=enable,nobefore -file mumps.dat
echo "========================================================="
#
echo Test Case 30
echo REPLICATION qualifier may be on or off but cannot be empty
echo $MUPIP set -journal=enable,before -replic -file mumps.dat
$MUPIP set -journal=enable,before -replic -file mumps.dat
echo $MUPIP set -journal=enable,before -replic=  -file mumps.dat
$MUPIP set -journal=enable,before -replic=  -file mumps.dat
echo $MUPIP set -journal=enable,before -replic=onoff -file mumps.dat
$MUPIP set -journal=enable,before -replic=onoff -file mumps.dat
echo $MUPIP set -journal=enable,before -replic=on -file mumps.dat
$MUPIP set -journal=enable,before -replic=on -file mumps.dat
echo $MUPIP set -journal=enable,before -replic=off -file mumps.dat
$MUPIP set -journal=enable,before -replic=off -file mumps.dat
echo "========================================================="
#
echo Test Case 31
echo Replication on makes journal state ON
echo $MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
echo $MUPIP set -REPLIC=on -reg "*" 
$MUPIP set -REPLIC=on -reg "*" |& sort -f 
#
$DSE << DSE_EOF >& dse_dump_1.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `$grep "Journal State " dse_dump_1.txt | $tst_awk '{print $4}'`
set repl_state = `$grep "Replication State " dse_dump_1.txt | $tst_awk '{print $3}'`
echo "Journal State:(expected ON) $jnl_state"
echo "Replication State:(expected ON) $repl_state"
#
#
echo "replication with file option"
$MUPIP set -replic=on -file mumps.dat
$DSE << DSE_EOF >& dse_dump_3.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `$grep "Journal State " dse_dump_3.txt | $tst_awk '{print $4}'`
set repl_state = `$grep "Replication State " dse_dump_3.txt | $tst_awk '{print $3}'`
echo "Journal State:(expected ON) $jnl_state"
echo "Replication State:(expected ON) $repl_state"
echo "========================================================="
#
echo Test case 32
echo Journaling cannot be disabled if replication is on
echo However journal=disable and replication=off can be specified together
#currently replication is on from previous test case
echo $MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
echo $MUPIP set -journal=disable -replic=off -file mumps.dat
$MUPIP set -journal=disable -replic=off -file mumps.dat
$DSE << DSE_EOF >& dse_dump_4.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `$grep "Journal State " dse_dump_4.txt | $tst_awk '{print $3}'`
set repl_state = `$grep "Replication State " dse_dump_4.txt | $tst_awk '{print $3}'`
echo "Journal State:(expected DISABLED) $jnl_state"
echo "Replication State:(expected OFF) $repl_state"
echo "========================================================="
#
echo Test Case 33-34
echo It is an error to try journal=off on a database for which REPLICATION is on
echo Or journal=off and replication=on in the same command
echo Journal=off and replication=off allowed
echo replication=off does change journal state unless replication and journal options
echo are specified in the same command
echo $MUPIP set -replic=on -file mumps.dat
$MUPIP set -replic=on -file mumps.dat
echo $MUPIP set -journal=off -file mumps.dat
$MUPIP set -journal=off -file mumps.dat
echo $MUPIP set -journal=off -replic=on -file mumps.dat
$MUPIP set -journal=off -replic=on -file mumps.dat
#make replication off
echo $MUPIP set -replic=off -file mumps.dat
$MUPIP set -replic=off -file mumps.dat
# check journal state ON and replication state closed
$DSE << DSE_EOF >& dse_dump_5.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `$grep "Journal State " dse_dump_5.txt | $tst_awk '{print $3}'`
set repl_state = `$grep "Replication State " dse_dump_5.txt | $tst_awk '{print $3}'`
echo "Journal State:(expected ON) $jnl_state"
echo "Replication State:(expected OFF) $repl_state"
# Try journal=off and replication=on together
echo $MUPIP set -journal=off -replic=on -file mumps.dat
$MUPIP set -journal=off -replic=on -file mumps.dat
#make replication on again
echo $MUPIP set -replic=on -file mumps.dat
$MUPIP set -replic=on -file mumps.dat
echo $MUPIP set -journal=off -replic=off -file mumps.dat
$MUPIP set -journal=off -replic=off -file mumps.dat
# Check journal state OFF and Replication state OFF
$DSE << DSE_EOF >& dse_dump_6.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `$grep "Journal State " dse_dump_6.txt | $tst_awk '{print $3}'`
set repl_state = `$grep "Replication State " dse_dump_6.txt | $tst_awk '{print $3}'`
echo "Journal State:(expected OFF) $jnl_state"
echo "Replication State:(expected OFF) $repl_state"
echo "========================================================="
#
echo Test Case 35
echo replication=on and journal=nobefore DOES NOT give error
echo $MUPIP set -replic=on -file mumps.dat
$MUPIP set -replic=on -file mumps.dat
echo $MUPIP set -journal=nobefore -file mumps.dat
$MUPIP set -journal=nobefore -file mumps.dat
# Now DISABLE journaling and trun replication off
echo $MUPIP set -journal=disable -replic=off -file mumps.dat
$MUPIP set -journal=disable -replic=off -file mumps.dat
echo $MUPIP set -journal=enable,nobefore -replic=on -file mumps.dat
$MUPIP set -journal=enable,nobefore -replic=on -file mumps.dat
$DSE << DSE_EOF >& dse_dump_6.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
set jnl_state = `$grep "Journal State " dse_dump_6.txt | $tst_awk '{print $3}'`
set repl_state = `$grep "Replication State " dse_dump_6.txt | $tst_awk '{print $3}'`
echo "Journal State:(expected [inactive]) $jnl_state"
echo "Replication State:(expected ON) $repl_state"
echo "========================================================="
#
echo Test Case 36
echo replication=on and other journal qualifiers
echo $MUPIP set -journal=enable,before,alignsize=4096,allocation=2048,autoswitchlimit=16448,bu=2308,EP=600,extension=100,filename=abcd.mjl,sync_io,yield_limit=1000 -replic=on -file mumps.dat
$MUPIP set -journal=enable,before,alignsize=4096,allocation=2048,autoswitchlimit=16448,bu=2308,EP=600,extension=100,filename="abcd.mjl",sync_io,yield_limit=1000 -replic=on -file mumps.dat
$DSE << DSE_EOF >& dse_dump_7.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_7.txt | $grep "Journal"
echo "========================================================="
#
echo Test Case 37
echo replication=off and other journal qualifiers
echo $MUPIP set -journal=enable,before,alignsize=4096,allocation=2048,autoswitchlimit=16448,bu=2308,EP=600,extension=100,filename=test_37.mjl,sync_io,yteld_limit=1000 -replic=off -file mumps.dat
$MUPIP set -journal=enable,before,alignsize=4096,allocation=2048,autoswitchlimit=16448,bu=2308,EP=600,extension=100,filename="test_37.mjl",sync_io,yield_limit=1000 -replic=off -file mumps.dat
$DSE << DSE_EOF >& dse_dump_8.txt
find -reg=DEFAULT
dump -fileheader
DSE_EOF
\cat dse_dump_8.txt | $grep "Journal"
echo "========================================================="
#
#
$gtm_tst/com/dbcheck.csh
#
#! END
#
