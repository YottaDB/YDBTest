#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test exercises MUPIP and MUMPS functionality pertaining to relink control file rundown.

# We do not want autorelink-enabled directories that have been randomly assigned by the test system because we are explicitly
# testing the autorelink functionality, as opposed to the rest of the test system which may be testing it implicitly.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

# With count validations and process suicides we do not want to affect concurrently running tests.
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_linktmpdir gtm_linktmpdir .

$gtm_tst/com/dbcreate.csh mumps
echo

cat > a.m <<eof
a
 quit
eof

set save_gtmroutines = "$gtmroutines"
echo "gtmroutines = $gtmroutines" > gtmroutines.outx

echo "1. MUPIP RUNDOWN -RELINKCTL . on a used relinkctl file with no routines."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*" zsystem "$gtm_dist/mupip rundown -relinkctl . >&! mupip_rundown_rctl1.logx"'
cat mupip_rundown_rctl1.logx
echo

echo "2. MUPIP RUNDOWN -RELINKCTL . on a used relinkctl file with no autorelinked routines."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*" do ^a zsystem "$gtm_dist/mupip rundown -relinkctl . >&! mupip_rundown_rctl2.logx"'
cat mupip_rundown_rctl2.logx
echo

echo "3a. MUMPS on a directory whose relinkctl file has not been run down due to a crash."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*" write:($zsigproc($job,9)) "TEST-E-FAIL, Suicide (pid "_$job_") failed.",! hang 30 write "TEST-E-FAIL, Process "_$job_" did not die in 30 seconds",!'
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*"' >&! mumps_rctl3a.logx
cat mumps_rctl3a.logx
echo

echo "3b. MUMPS on a directory whose relinkctl file has not been run down due to a crash but shared memory removed."
$gtm_tst/$tst/u_inref/rundown_rctl_shms.csh . mupip_rctldump3b.logx
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*"' >&! mumps_rctl3b.logx
cat mumps_rctl3b.logx
echo

echo "3c. MUPIP RUNDOWN -RELINKCTL . on an unused relinkctl file with no routines."
$gtm_dist/mupip rundown -relinkctl . >&! mupip_rundown_rctl3c.logx
cat mupip_rundown_rctl3c.logx
echo

echo "4a. MUMPS on a directory whose relinkctl file has not been run down due to a crash."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*" do ^a write:($zsigproc($job,9)) "TEST-E-FAIL, Suicide (pid "_$job_") failed.",! hang 30 write "TEST-E-FAIL, Process "_$job_" did not die in 30 seconds",!'
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*"' >&! mumps_rctl4a.logx
cat mumps_rctl4a.logx
echo

echo "4b. MUMPS on a directory whose relinkctl file has not been run down due to a crash but shared memory removed."
$gtm_tst/$tst/u_inref/rundown_rctl_shms.csh . mupip_rctldump4b.logx
$gtm_dist/mumps -run %XCMD 'set $zroutines=".*" do ^a' >&! mumps_rctl4b.logx
cat mumps_rctl4b.logx
echo

echo "4c. MUPIP RUNDOWN -RELINKCTL . on an unused relinkctl file with routines."
$gtm_dist/mupip rundown -relinkctl . >&! mupip_rundown_rctl4c.logx
cat mupip_rundown_rctl4c.logx
echo

setenv gtmroutines ".* dir* $gtmroutines"
echo "gtmroutines = $gtmroutines" >> gtmroutines.outx

mkdir dir
cp a.m dir/b.m

echo "5. MUPIP RUNDOWN -RELINKCTL on used relinkctl files with no routines."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*" zsystem "$gtm_dist/mupip rundown -relinkctl >&! mupip_rundown_rctl5.logx"'
cat mupip_rundown_rctl5.logx
echo

echo "6. MUPIP RUNDOWN -RELINKCTL on used relinkctl files with no autorelinked routines."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*" do ^a do ^b zsystem "$gtm_dist/mupip rundown -relinkctl >&! mupip_rundown_rctl6.logx"'
cat mupip_rundown_rctl6.logx
echo

echo "7a. MUMPS on directories whose relinkctl files have not been run down due to a crash."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*" write:($zsigproc($job,9)) "TEST-E-FAIL, Suicide (pid "_$job_") failed.",! hang 30 write "TEST-E-FAIL, Process "_$job_" did not die in 30 seconds",!'
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*"' >&! mumps_rctl7a.logx
cat mumps_rctl7a.logx
echo

echo "7b. MUMPS on directories whose relinkctl files have not been run down due to a crash but shared memory removed."
$gtm_tst/$tst/u_inref/rundown_rctl_shms.csh " " mupip_rctldump7b.logx
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*"' >&! mumps_rctl7b.logx
cat mumps_rctl7b.logx
echo

echo "7c. MUPIP RUNDOWN -RELINKCTL on unused relinkctl files with no routines."
$gtm_dist/mupip rundown -relinkctl >&! mupip_rundown_rctl7c.logx
cat mupip_rundown_rctl7c.logx
echo

echo "8a. MUMPS on directories whose relinkctl files have not been run down due to a crash."
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*" do ^a do ^b write:($zsigproc($job,9)) "TEST-E-FAIL, Suicide (pid "_$job_") failed.",! hang 30 write "TEST-E-FAIL, Process "_$job_" did not die in 30 seconds",!'
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*" do ^a do ^b' >&! mumps_rctl8a.logx
cat mumps_rctl8a.logx
echo

echo "8b. MUMPS on directories whose relinkctl files have not been run down due to a crash but shared memory removed."
$gtm_tst/$tst/u_inref/rundown_rctl_shms.csh " " mupip_rctldump8b.logx
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir*" do ^a do ^b' >&! mumps_rctl8b.logx
cat mumps_rctl8b.logx
echo

echo "8c. MUPIP RUNDOWN -RELINKCTL on unused relinkctl files with routines."
$gtm_dist/mupip rundown -relinkctl >&! mupip_rundown_rctl8c.logx
cat mupip_rundown_rctl8c.logx
echo

setenv gtmroutines "$save_gtmroutines"
echo "gtmroutines = $gtmroutines" >> gtmroutines.outx

cat > suicide.m <<eof
suicide
 set \$zroutines=".*"
 do ^a
 write:(\$zsigproc(\$job,9)) "TEST-E-FAIL, Suicide (pid "_\$job_") failed.",!
 hang 30
 write "TEST-E-FAIL, Process "_\$job_" did not die in 30 seconds",!
eof

# When GT.M processes attached to relinkctl or rtnobj shared memory die, the attach count on those segments becomes
# incorrect. MUPIP RUNDOWN -RELINKCTL attempts to fix that whenever it detects that the count reported by the OS is
# different.
echo "9. MUPIP RUNDOWN -RELINKCTL on active relinkctl file with an incorrect attach count."
$gtm_dist/mumps -direct >&! mumps_direct9.log <<eof
set \$zroutines=".* "_\$zroutines
do ^a
set jobCount=\$random(5)+1
do ^job("suicide^suicide",jobCount,"""""")
zsystem "\$gtm_dist/mupip rundown -relinkctl . >&! mupip_rundown_rctl9.logx"
zsystem "\$gtm_dist/mupip rctldump >&! mupip_rctldump9.logx"
eof

$gtm_tst/com/ipcs -a > ipcs.logx

cat mupip_rundown_rctl9.logx

echo "Checking for left-over shared memory segments:"
set shmids = `$grep shmid: mupip_rctldump9.logx | $tst_awk -F'(shmid: |  shmlen)' '{print $2}'`
@ i = 1
@ found = 0
while ($i <= $#shmids)
	@ shmid = $shmids[$i]
	$grep -w $shmid ipcs.logx
	if (! $status) then
		@ found = 1
	endif
	@ i++
end
if (! $found) then
	echo "TEST-I-INFO, No left-over relinkctl IPCs found."
endif
echo

echo "10. MUPIP RUNDOWN -RELINKCTL abc on a non-existent directory."
$gtm_dist/mupip rundown -relinkctl abc
echo

setenv gtmroutines "$gtmroutines abc"
echo "gtmroutines = $gtmroutines" >> gtmroutines.outx

echo "11. MUPIP RUNDOWN -RELINKCTL on a non-existent directory."
$gtm_dist/mupip rundown -relinkctl
echo

setenv gtmroutines "$save_gtmroutines"
echo "gtmroutines = $gtmroutines" >> gtmroutines.outx

# Argumentless MUPIP RUNDOWN -RELINKCTL should not remove non-starred directories from $gtmroutines, which may actually have
# relinkctl stuff associated with them because some other process treats that directory as autorelink-enabled.
echo '12. MUPIP RUNDOWN -RELINKCTL on a directory that is non-autorelinked in $gtmroutines.'
$gtm_dist/mumps -run %XCMD 'set $zroutines=".* dir" do ^a zsystem "$gtm_dist/mupip rundown -relinkctl >&! mupip_rundown_rctl12.logx"'
cat mupip_rundown_rctl12.logx
echo

# This test has a direct-mode MUMPS process create relinkctl shared memory and another MUMPS process, optionally run by a different
# user, create rtnobj shared memory. Then, while the first process is still alive, the newly created rtnobj shared memory and,
# optionally, relinkctl shared memory is removed, upon which the first process atempts to execute a routine corresponding to those
# IPCs. That should cause appropriate errors.
echo "13. Live MUMPS process whose previously loaded relinkctl shared memory has been removed."

# Ensure identical settings on replay.
if (! $?gtm_test_replay) then
	set rand_nums = `$gtm_tst/com/genrandnumbers.csh 2 0 1`
	setenv r1 $rand_nums[1]
	setenv r2 $rand_nums[2]
	echo "Random options generated by the test:"	>> settings.csh
	echo "setenv r1 $r1"				>> settings.csh
	echo "setenv r2 $r2"				>> settings.csh
endif

# All commands are abbreviated below because of limits on the line length with heredocs.
$gtm_dist/mumps -direct >&! mumps_direct13.logx <<eof
S \$zroutines=".*"
S remote=$r1
S:remote rndwnCmd=\$S(${r2}:"\$gtm_tst/\$tst/u_inref/rundown_rctl_shms.csh . mupip_rctldump13b.logx relinkctl",1:"echo ""Not removing relinkctl shared memory""")
S:'remote rndwnCmd="\$gtm_tst/\$tst/u_inref/rundown_rctl_shms.csh . mupip_rctldump13.logx "_\$S(${r2}:"rtnobj; echo ""Not removing relinkctl shared memory""",1:"both")
ZSY:remote "\$gtm_tst/\$tst/u_inref/rundown_user2.csh; cat remote_rundown.log; "_rndwnCmd
ZSY:'remote "setenv gtmroutines "".*""; \$gtm_dist/mumps -run a; "_rndwnCmd
D ^a
eof

$grep -vE 'YDB>|^$' mumps_direct13.logx
echo

$gtm_tst/com/dbcheck.csh
