#!/usr/local/bin/tcsh -f
#
echo ENTERING ONLINE8

setenv TMPDIR `pwd`
setenv gtmgbldir online8.gld
setenv bkp_dir "`pwd`/online8"
mkdir $bkp_dir
chmod 777 $bkp_dir
$gtm_tst/com/dbcreate.csh online8 1 125 700 1536 100 256
cp online8.gld $bkp_dir

$GTM << \startjobs
d fill9^myfill("init","00")
Job fill9^myfill("set","AA"):(err="online8A.err":out="online8A.log")
Job fill9^myfill("set","BB"):(err="online8B.err":out="online8B.log")
Job fill9^myfill("set","CC"):(err="online8C.err":out="online8C.log")
Job fill9^myfill("set","DD"):(err="online8D.err":out="online8D.log")
Job fill9^myfill("set","EE"):(err="online8E.err":out="online8E.log")
Job fill9^myfill("set","FF"):(err="online8F.err":out="online8F.log")
Job fill9^myfill("set","GG"):(err="online8G.err":out="online8G.log")
Job fill9^myfill("set","HH"):(err="online8H.err":out="online8H.log")
h
\startjobs

$MUPIP backup -o "*" ./online8 >&! online8backup.log

$GTM << \jobsfinished
s ^config("backupdone")="TRUE"
f i=0:1:60  q:^config("finished")=8  h 1
i i=60  w !,"Waited too long.",!
h
\jobsfinished

$gtm_tst/com/dbcheck.csh

cd $bkp_dir
$MUPIP integ -r "*" >&! online8.mupip
grep "No errors" online8.mupip
$GTM << \verify
d fill9^myfill("ver")
h
\verify

echo LEAVING ONLINE8
