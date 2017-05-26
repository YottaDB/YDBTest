#!/usr/local/bin/tcsh -f
setenv gtmgbldir gtmgbldir.gld
$GDE << \xyz
exit
\xyz
#
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

$MUPIP create
#
$GTM << \xyz
s ^val("one")=1
h
\xyz
#
setenv gtmgbldir ""
$GTM << \xyz
s ^val("two")=2
h
\xyz
#
unsetenv gtmgbldir 
$GTM << \xyz
s ^val("three")=3
h
\xyz
#
setenv gtmgbldir gtmgbldir.gld
$GTM << \xyz
s ^val("four")=4
set $zgbldir="foo.gld"
s ^val("five")=5
h
\xyz
#
setenv gtmgbldir foo.gld
$GTM << \xyz
s ^val("six")=6
set $zgbldir="gtmgbldir.gld"
s ^val("seven")=7
h
\xyz
#
setenv gtmgbldir gtmgbldir.gld
$GTM << \xyz
zwr ^val
h
\xyz
#
echo "Now test mupip functions:"
echo "setenv gtmgbldir foo.gld"
setenv gtmgbldir foo.gld
$MUPIP backup DEFAULT bak.dat
$MUPIP integ -reg "*"
$MUPIP freeze -on "*"
$MUPIP rundown -reg "*"
$MUPIP set -journal=enable,on,before -reg "*"   
#
echo "unsetenv gtmgbldir"
unsetenv gtmgbldir
$MUPIP backup DEFAULT bak.dat
$MUPIP integ -reg "*"
$MUPIP freeze -on "*"
$MUPIP rundown -reg "*"
$MUPIP set -journal=enable,on,before -reg "*"   
