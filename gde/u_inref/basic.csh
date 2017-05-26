#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Encryption cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
cp $gtm_tst/$tst/inref/*.com .
setenv gtmgbldir gdetst.gld
$GTM << xyz
do ^GDE
quit
h
xyz
setenv gtmgbldir gdetst.gld
touch gdetst.gld
\rm gdetst.*
echo "make GDE get sick and die" > gdetst.gld
$convert_to_gtm_chset gdetst.gld "BINARY"
$GTM << xxyz
do ^GDE
xxyz
\rm gdetst.gld
$GTM << xyyz
write "# test that setting subscripted variables inside mumps BEFORE invoking GDE results in COLLDATAEXISTS error"
set x(1)=1
do ^GDE
write "# kill x and expect the below GDE invocation to work"
kill x
zwrite
do ^GDE
exit
zwrite
write "# test that we are able to resume processing inside mumps AFTER exiting GDE"
if \$incr(i)
zwrite
xyyz

source $gtm_tst/com/cre_coll_sl_reverse.csh 1
$GTM << gtm_eof
set msg="# test that after setting a different local variable alternate collation,null collation,numeric collation"
write msg,!,"# GDE invocation exits gracefully and does not error with GDE-E-INPINTEG"
write \$\$set^%LCLCOL(1,0,1)
set a("a")="a"
do ^GDE
gtm_eof

$GTM << xyzz
write "# test that we are able to set unsubscripted variables inside mumps BEFORE invoking GDE"
if \$incr(i)
zwrite
do ^GDE
@gdebastst.com
quit
write "# test that we are able to resume processing inside mumps AFTER quitting GDE"
if \$incr(i(3))
zwrite
halt
xyzz
\rm -f *.gld *.dat
set tests="gdemaptst dmi tnt its"
foreach i ($tests)
	echo "	** $i"
	$GTM << xyyz > /dev/null
	do ^GDE
	@$i.com
	halt
xyyz

# Testing for the gde 'command' qualifier: starts

	$GTM << abc >& /dev/null
	do ^GDE
	show -command -file="$i.cmd"
	show -command
	quit
abc
	$GTM << abc >& /dev/null
	do ^GDE
	log -on="oldgde$i.log"
	show -all
	log -off
	quit
abc
	mv $gtmgbldir $i.gld.old
	$GTM << abc >& "command_$i.log"
	do ^GDE
	@$i.cmd
	ex
abc
	$GTM << abc >& /dev/null
	do ^GDE
	log -on="newgde$i.log"
	show -all
	log -off
	quit
abc
	echo "gdeshowdiff.csh oldgde$i.log newgde$i.log"
	$gtm_tst/com/gdeshowdiff.csh oldgde$i.log newgde$i.log
	if ( $status ) then
		echo "-command failed to create identical global directory for $i. Exiting ..."
		exit 1
	else
		echo "show -command is successful for $i" > $i.success
	endif
# Testing for the gde 'command' qualifier: ends


if("ENCRYPT" == $test_encryption) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
	$GTM << xxy > /dev/null
	do ^GDE
	log -on=reload.log
	show -all
	ex
xxy
	$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk reload.log $gtm_tst/$tst/outref/$i.log >$i.cmp
	mv reload.log $i.log
	echo "gdeshowdiff.csh $i.cmp $i.log"
	$gtm_tst/com/gdeshowdiff.csh $i.cmp $i.log
	if ($status) echo "TEST-E-DIFF there was a diff for $i"
	$MUPIP create
	source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
	source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
	if ((1 == $?acc_meth) && ("MM" == $acc_meth))then
	    $MUPIP set -region "*" -access_method=MM > & /dev/null
	endif
	$GTM << xyzz
	do ^fullgd
	h
xyzz
        mv gdetst.gld $i.gld
end

# Test MM/ENCRYPT mutual exclusion

setenv gtmgbldir cryptmm
$GDE << gde_eof
change -segment DEFAULT -ACCESS_METHOD=MM
change -segment DEFAULT -ENCRYPTION
exit
quit
gde_eof

