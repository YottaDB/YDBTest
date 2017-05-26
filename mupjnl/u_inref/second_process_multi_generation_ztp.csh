#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# use  with same_user.csh (same user) or other_user.csh (gtmtest1) to run an arbitrary M routine (specified in $4)

echo $*
echo "User Name          : " `whoami`
echo "Version            : " $1
echo "Image              : " $2

source $gtm_com/gtm_cshrc.csh
source $gtm_test/T990/com/remote_getenv.csh $3
version $1 $2
echo $gtm_exe
setenv GTM "$gtm_exe/mumps -direct"
cd $3
pwd
setenv gtmgbldir "mumps.gld"

$GTM << \USER2
w "$ZV = GTM_TEST_DEBUGINFO ",$ZV,!
w "start...",!
w "$H = ",$H,!
s fn="secondpid"_+$ztrnlnm("gtm_test_jobid")_".mjo" o fn u fn w "PID ",$J,! c fn u $P
ZTS
s (^aact1,^bact1,^cact1,^dact1)="ACTIVE ZTP"
w "in active ztp...",!
w "$H = ",$H,!
view "JNLFLUSH"
zsystem "mupip set -journal=""enable,on,before,file=mumps2.mjl"" -file mumps.dat"
s (^aact2,^bact2,^cact2,^dact2)="ACTIVE ZTP. more sets"
s ^sema1="done"
view "JNLFLUSH"
for i=1:1:240 quit:$data(^done)  h 1
if i=240 w "TEST-E-TIMEOUT: Timed out: user1 has not set ^done ",$H,!
w "end..."
w "$H = ",$H,!
ZTC
s ^sema2=1
h
\USER2
echo "The date is: "`date`
echo "End of second_process job!"
