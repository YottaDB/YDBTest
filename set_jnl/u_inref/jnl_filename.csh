#! /usr/local/bin/tcsh -f
# This subtest covers from test case 16 to 22 
# from mupip set journal test plan
#
echo "Journal file name qualifier subtest"
#
echo Test Case 16
#
echo "===================================================="
echo single region and filename option
source $gtm_tst/com/dbcreate.csh . 1
# There is only one region
$MUPIP set -journal=enable,nobefore,filename="test1.mjl" -reg "*"
echo "===================================================="
#
echo Test Case 17
# Multiple region
echo multiple region and filename option
\rm *.dat
$GDE << GDE_EOF
add -name a* -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a_acn
GDE_EOF
$MUPIP create
$MUPIP set -journal=enable,nobefore,filename="test2.mjl" -reg "*" 
echo "===================================================="
#
echo Test Case 18
# Default journal filename
echo default journal filename
\rm *.dat
$GDE << GDE_EOF
add -name b* -region=breg
add -name B* -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=b.dat
add -name c* -region=creg
add -name C* -region=creg
add -region creg -dyn=cseg
add -segment cseg -file=c.d.tbls
GDE_EOF
$MUPIP create
$MUPIP set -journal=enable,nobefore -reg "*" |& sort -f 
$MUPIP set -journal=enable,nobefore -file mumps.dat
$MUPIP set -journal=enable,nobefore -file a_acn
$MUPIP set -journal=enable,nobefore -file b.dat
$MUPIP set -journal=enable,nobefore -file c.d.tbls
echo "===================================================="
#
echo Test Case 19
echo User specified journal filename
$MUPIP set -journal=enable,nobefore,filename="test3.mjl" -file mumps.dat
$MUPIP set -journal=enable,nobefore,filename="test3.mjl" -file mumps.dat
# Make sure there is a dummy.mjl file exists in test directory
\cp $gtm_tst/$tst/u_inref/dummy.mjl .
$MUPIP set -journal=enable,nobefore,filename="dummy.mjl" -file mumps.dat
# use an environent variable name as filename
setenv myjnlfile "abcd.mjl"
$MUPIP set -journal=enable,nobefore,filename=$myjnlfile -file mumps.dat
echo "===================================================="
#
echo Test Case 20
echo journal file rename 
@ count = 0
while ( $count < 20)
$MUPIP set -journal=enable,nobefore -file mumps.dat
@ count = $count + 1
end
echo "===================================================="
#
echo Test Case 21
echo Previous journal filename
echo Journal state 0 to 2
echo $MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
echo $MUPIP set -journal=enable,nobefore -file mumps.dat
$MUPIP set -journal=enable,nobefore -file mumps.dat
set prev_jnl_file = `$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal file name" | $tst_awk '{print $5}'`
if ($prev_jnl_file != "") then
	echo "TEST FAILED: previous journal file should be Empty, but it is $prev_jnl_file"
endif
#
echo Journal state 1 to 2
$MUPIP set -journal=off -file mumps.dat
$MUPIP set -journal=on,nobefore -file mumps.dat
set prev_jnl_file = `$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal file name" | $tst_awk '{print $5}'`
if ($prev_jnl_file != "") then
	echo "TEST FAILED: previous journal file should be Empty, but it is $prev_jnl_file"
endif
#
echo Journal state 2 to 2
$MUPIP set -journal=on,nobefore -file mumps.dat
set prev_jnl_file = `$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal file name" | $tst_awk '{print $5}'`
if ($prev_jnl_file == "") then
	echo "TEST FAILED: previous journal file should not be Empty"
endif
#
echo Switching between NOBEFORE and BEFORE image does have effect on prev jnl file name
$MUPIP set -journal=before -file mumps.dat
set prev_jnl_file = `$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal file name" | $tst_awk '{print $5}'`
if ($prev_jnl_file == "") then
	echo "TEST FAILED: previous journal file should not be Empty"
endif
#
echo "Replication on clears the previous link failed (2 to 2)"
$MUPIP set -replic=on -file mumps.dat
set prev_jnl_file = `$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal file name" | $tst_awk '{print $5}'`
if ($prev_jnl_file != "") then
	echo "TEST FAILED: previous journal file should be Empty, but it is $prev_jnl_file"
endif
#
echo First DISABLE journaling and then turn on replication
$MUPIP set -journal=disable -replic=off -file mumps.dat
$MUPIP set -replic=on -file mumps.dat
set prev_jnl_file = `$MUPIP journal -show=header -forward mumps.mjl |& $grep "Prev journal file name" | $tst_awk '{print $5}'`
if ($prev_jnl_file != "") then
	echo "TEST FAILED: previous journal file should be Empty, but it is $prev_jnl_file"
endif
echo "===================================================="
#
echo Test Case 22
echo Journal filename cycle
$MUPIP set -replic=off -file mumps.dat
$MUPIP set -journal=disable -file mumps.dat
$MUPIP set -journal=enable,nobefore,filename="j1.mjl" -file mumps.dat
$MUPIP set -journal=enable,nobefore,filename="j2.mjl" -file mumps.dat
$MUPIP set -journal=enable,nobefore,filename="j3.mjl" -file mumps.dat
$MUPIP set -journal=enable,nobefore,filename="j1.mjl" -file mumps.dat
echo "===================================================="
# 
$gtm_tst/com/dbcheck.csh 
