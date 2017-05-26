#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

@ case = 1
$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/misc.cmd'")'
cp gdemisc.cmd gdemisc.cmd_orig
sed 's/\$/\\\$/' gdemisc.cmd_orig >&! gdemisc.cmd

echo "$GDE << gde_eof"	>>&! misc_script.csh
cat gdemisc.cmd		>>&! misc_script.csh
echo "gde_eof"		>>&! misc_script.csh

chmod +x misc_script.csh

./misc_script.csh

mv mumps.gld mumps.gld_$case
@ case++

cat >> control_chars.csh << cat_eof
$GDE << gde_eof
add -name A -reg=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a.dat -acc=BG
change -region DEFAULT -inst
change -reg AREG -inst
change -region DEFAULT -journal=file_name=default.mjl
show -region
show -segment
show -map
add -name GBL -reg=BREG
add -region BREG -dyn=BSEG -journal=(before,auto=16384,exten=4096)
add -segment BSEG -file=b.dat
gde_eof
cat_eof

chmod +x control_chars.csh

./control_chars.csh

echo "# Expect GTM-I-JNLALLOCGROW below and not an assert failure"
$MUPIP create
$MUPIP set -journal=enable,on,nobefore -reg "*" >&! jnl_on.out
echo "# While the vaule of allocation in the gde settings was not changed, expect it to be higher due to JNLALLOCGROW above"
$MUPIP journal -show -forw b.mjl |& $grep "Jnlfile"

mv mumps.gld mumps.gld_$case
@ case++

echo "# Test case to check for LOCK SPACE max check and the new GDE command for mutex queue slots. Move it to a better place if one exists"

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/locksmutexres.cmd'")'

echo "$GDE << gde_eof"			>>&! locksmutexres_script.csh
cat gdelocksmutexres.cmd			>>&! locksmutexres_script.csh
echo "gde_eof"				>>&! locksmutexres_script.csh

chmod +x locksmutexres_script.csh
./locksmutexres_script.csh

echo "# GDE show -segments shoud reflect the modified values of lockspace, mutex slots and reserved bytes"
$GDE show -segment
$GDE show -commands -file=locksmutexrescommand.com
echo "# GDE show -commands should have the correct values of lockspace, mutex slots and reserved bytes"
$grep -E "LOCK_SPACE|MUTEX_SLOTS|RESERVED_BYTES|ACCESS_METHOD" locksmutexrescommand.com
echo "# DSE dump should reflect the modified values of lockspace, mutex slots and reserved bytes"
$MUPIP create
$DSE all -dump |& $grep -E "^Region|Mutex Queue Slots|Reserved Bytes"

mv mumps.gld mumps.gld_$case
@ case++

echo "# Test case to check if a change to template and subsequent rename of DEFAULT segment, shows the right commands in show -command output"
$GDE @$gtm_tst/$tst/inref/chtemplate.cmd
mv mumps.gld mumps.gld_orig_$case
$GDE @chtemplate.com
$GDE show -segment

mv mumps.gld mumps.gld_$case
@ case++

echo "# Test case to check for + or - E with no number following it"
$GTM << gtm_eof
write 1E-
write 1E+
write 1E-
write 1E-0000
write 1E+000
write 1E00
write 1E02
write +"1E"
write +"1E+"
write +"1E-"
write +"1E-0000"
write +"1E+000"
write +"1E00"
write +"1E02"
gtm_eof
