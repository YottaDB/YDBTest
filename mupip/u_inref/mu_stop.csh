#! /usr/local/bin/tcsh -f
#
########################################
### mu_stop.csh  test for mupip stop ###
########################################
#
#
echo MUPIP STOP
#
#
setenv gtmgbldir stop.gld
$gtm_tst/com/dbcreate.csh stop
#
#
($gtm_exe/mumps -r h300s &) >&! my_stop.log.ns
#
#
$GTM << \aaaa
f  q:$d(^a)  h 1
f i=0:1:300  q:'$d(^a(i))
s ^startat=i
w !,"JOB started"
s cmd="$MUPIP stop "_^procid
w !,cmd,!
zsy cmd
h 1
w !,cmd,!
zsy cmd
h 1
f i=0:1:300  q:'$d(^a(i))
s ^endat=i
i $GET(^stopack)=1  w !,"TEST-E-MUPIP Stop, Stop issued too late...",!
s delta=^endat-^startat
i delta>3  w !,"Test Passed but took too long.",delta," Seconds to Stop",!
s ^stop=1
h
\aaaa
#
#
cat my_stop.log.ns 
echo check database integrity
$gtm_tst/com/dbcheck.csh
#
#
######################
# END of mu_stop.csh #
######################
